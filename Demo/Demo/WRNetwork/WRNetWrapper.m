//
//  WRNetWrapper.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//


#import "WRNetWrapper.h"
#import <AFNetWorking/AFNetworking.h>
#import <AFNetWorking/AFNetworkActivityIndicatorManager.h>


static const NSTimeInterval WRRequestTimeOutInterval = 20;
static NSMutableArray *_allSessionTask;
static AFHTTPSessionManager *_sessionManager;
static dispatch_semaphore_t _semaphore;
static dispatch_time_t _overTime;


@implementation WRNetWrapper

#pragma mark - 初始化
+ (void)load {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)initialize {
    _sessionManager = [AFHTTPSessionManager manager];
    _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    _sessionManager.requestSerializer.timeoutInterval = WRRequestTimeOutInterval;
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    _semaphore = dispatch_semaphore_create(1);
    _overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
}

#pragma mark - 监测/获取当前网络状态
+ (BOOL)isNetworkReachable {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}
+ (BOOL)isNetworkReachableViaWWAN {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}
+ (BOOL)isNetworkReachableViaWIFI {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}
+ (void)setReachableStatusChangeBlock:(WRNetworkStatusChangeBlock)changeBlock {
    if (!changeBlock) return;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                changeBlock(WRNetworkStatusUnknown);
                break;
            case AFNetworkReachabilityStatusNotReachable:
                changeBlock(WRNetworkStatusNotReachable);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                changeBlock(WRNetworkStatusReachableViaWWAN);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                changeBlock(WRNetworkStatusReachableViaWIFI);
                break;
        }
    }];
}


#pragma mark - 取消 HTTP 请求
+ (void)cancelAllRequest {
    dispatch_semaphore_wait(_semaphore, _overTime);
    [[WRNetWrapper allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        [task cancel];
    }];
    [[WRNetWrapper allSessionTask] removeAllObjects];
    dispatch_semaphore_signal(_semaphore);
}
+ (void)cancelRequestWithURL:(NSString *)urlStr {
    if (!urlStr) return;
    dispatch_semaphore_wait(_semaphore, _overTime);
    [[WRNetWrapper allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.currentRequest.URL.absoluteString isEqualToString:urlStr]) {
            [task cancel];
            [[WRNetWrapper allSessionTask] removeObject:task];
            *stop = YES;
        }
    }];
    dispatch_semaphore_signal(_semaphore);
}


#pragma mark - 发起网络请求
- (void)loadRequest {
    if (![self.dataSource respondsToSelector:@selector(netWrapperParametersForApi:)]) return;
    if (![self.dataSource respondsToSelector:@selector(netWrapperBaseURLForApi:)]) return;
    if (![self.dataSource respondsToSelector:@selector(netWrapperRequestNameForApi:)]) return;
    if (![self.dataSource respondsToSelector:@selector(netWrapperHttpMethodForApi:)]) return;
    
    NSDictionary *parameters = [self.dataSource netWrapperParametersForApi:self];
    NSString *baseURL = [self.dataSource netWrapperBaseURLForApi:self];
    NSString *requestName = [self.dataSource netWrapperRequestNameForApi:self];
    WRNetWrapperHTTPMethod httpMethod = [self.dataSource netWrapperHttpMethodForApi:self];
    
    BOOL isCache = NO;
    if ([self.dataSource respondsToSelector:@selector(netWrapperIsCacheForApi:)]) {
        isCache = [self.dataSource netWrapperIsCacheForApi:self];
    }
    if (isCache && [self.dataSource respondsToSelector:@selector(newWrapperCacheTimeForApi:)]) {
        _cacheTime = [self.dataSource newWrapperCacheTimeForApi:self];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", baseURL, requestName];
    
    // 获取完整 url 赋值给 _requestURL
    [self getCompleteRequestURL:urlStr method:httpMethod parameters:parameters];
    
    [self requestWithURL:urlStr parameters:parameters httpMethod:httpMethod isCache:isCache cacheTime:_cacheTime cache:nil success:nil failure:nil];
}

- (WRNetWrapper *)requestWithURL:(NSString *)urlStr
                      parameters:(NSDictionary *)parameters
                      httpMethod:(WRNetWrapperHTTPMethod)httpMethod
                         isCache:(BOOL)isCache
                       cacheTime:(NSTimeInterval)cacheTime
                           cache:(WRNetWrapperGetCacheBlock)cache
                         success:(WRNetWrapperRequestDidSuccessBlock)success
                         failure:(WRNetWrapperRequestDidFailedBlock)failure {

    
    // 读取缓存 (这里必须要使用_requestURL)
    _cache = [WRCache getCacheWithURL:_requestURL];
    if (cache) cache(_cache);
    if ([_delegate respondsToSelector:@selector(netWrapperGetCacheDidFinished:)]) {
        [_delegate netWrapperGetCacheDidFinished:self];
    }

    // 处理没有网络的情况
    if (![WRNetWrapper isNetworkReachable]) {
        [self handleNoNetworkWithFailure:failure];
        return nil;
    }

    [WRNetWrapper showNetworkActivityIndicator:YES];
    if (httpMethod == WRNetWrapperHTTPMethodGET) {
        [self GET:urlStr parameters:parameters isCache:isCache success:success failure:failure];
    }
    else if (httpMethod == WRNetWrapperHTTPMethodPOST) {
        [self POST:urlStr parameters:parameters isCache:isCache success:success failure:failure];
    }
    else if (httpMethod == WRNetWrapperHTTPMethodPUT) {
        [self PUT:urlStr parameters:parameters isCache:isCache success:success failure:failure];
    }
    else if (httpMethod == WRNetWrapperHTTPMethodDELETE) {
        [self DELETE:urlStr parameters:parameters isCache:isCache success:success failure:failure];
    }
    else if (httpMethod == WRNetWrapperHTTPMethodHEAD) {
        [self HEAD:urlStr parameters:parameters success:success failure:failure];
    }
    else if (httpMethod == WRNetWrapperHTTPMethodPATCH) {
        [self PATCH:urlStr parameters:parameters isCache:isCache success:success failure:failure];
    }
    return self;
}

#pragma mark -  调用 AFN
- (__kindof NSURLSessionTask *)GET:(NSString *)urlStr
                        parameters:(NSDictionary *)parameters
                           isCache:(BOOL)isCache
                           success:(WRNetWrapperRequestDidSuccessBlock)success
                           failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager GET:urlStr
                             parameters:parameters
                               progress:nil
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    [self handleSuccessWithURL:urlStr parameters:parameters cache:isCache task:task response:responseObject success:success];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    [self handleFailureWithTask:task response:error failure:failure];
                                }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}
- (__kindof NSURLSessionTask *)POST:(NSString *)urlStr
                         parameters:(NSDictionary *)parameters
                            isCache:(BOOL)isCache
                            success:(WRNetWrapperRequestDidSuccessBlock)success
                            failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager POST:urlStr
                              parameters:parameters
                                progress:nil
                                 success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                     [self handleSuccessWithURL:urlStr parameters:parameters cache:isCache task:task response:responseObject success:success];
                                     
                                 }
                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     [self handleFailureWithTask:task response:error failure:failure];
                                 }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}
- (__kindof NSURLSessionTask *)PUT:(NSString *)urlStr
                         parameters:(NSDictionary *)parameters
                            isCache:(BOOL)isCache
                            success:(WRNetWrapperRequestDidSuccessBlock)success
                            failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager PUT:urlStr
                             parameters:parameters
                                success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                    [self handleSuccessWithURL:urlStr parameters:parameters cache:isCache task:task response:responseObject success:success];
                                }
                                failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                    [self handleFailureWithTask:task response:error failure:failure];
                                }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}
- (__kindof NSURLSessionTask *)DELETE:(NSString *)urlStr
                           parameters:(NSDictionary *)parameters
                              isCache:(BOOL)isCache
                              success:(WRNetWrapperRequestDidSuccessBlock)success
                              failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager DELETE:urlStr
                                parameters:parameters
                                   success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                       [self handleSuccessWithURL:urlStr parameters:parameters cache:isCache task:task response:responseObject success:success];
                                   }
                                   failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                       [self handleFailureWithTask:task response:error failure:failure];
                                   }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}
/*
 * HEAD方法与GET方法一样，都是向服务器发出指定资源的请求。
 * 但是，服务器在响应HEAD请求时不会回传资源的 body(响应主体), 只会获取到响应头信息。
 * HEAD方法常被用于客户端查看服务器的性能。
 * */
- (__kindof NSURLSessionTask *)HEAD:(NSString *)urlStr
                         parameters:(NSDictionary *)parameters
                            success:(WRNetWrapperRequestDidSuccessBlock)success
                            failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager HEAD:urlStr
                              parameters:parameters
                                 success:^(NSURLSessionDataTask * _Nonnull task) {
                                     [self handleSuccessWithURL:urlStr parameters:parameters cache:NO task:task response:nil success:success];
                                 }
                                 failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                     [self handleFailureWithTask:task response:error failure:failure];
                                 }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}
/*
 * PATCH 请求与 PUT 请求类似，同样用于资源的更新。二者有以下两点不同：
 *      1. PATCH一般用于资源的部分更新，而PUT一般用于资源的整体更新。
 *      2. 当资源不存在时，PATCH会创建一个新的资源，而PUT只会对已在资源进行更新。
 * */
- (__kindof NSURLSessionTask *)PATCH:(NSString *)urlStr
                          parameters:(NSDictionary *)parameters
                             isCache:(BOOL)isCache
                             success:(WRNetWrapperRequestDidSuccessBlock)success
                             failure:(WRNetWrapperRequestDidFailedBlock)failure
{
    _sessionTask = [_sessionManager PATCH:urlStr
                               parameters:parameters
                                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                      [self handleSuccessWithURL:urlStr parameters:parameters cache:isCache task:task response:responseObject success:success];
                                  }
                                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                      [self handleFailureWithTask:task response:error failure:failure];
                                  }];
    if (_sessionTask) [[WRNetWrapper allSessionTask] addObject:_sessionTask];
    return _sessionTask;
}

#pragma mark - 上传/下载文件
+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)urlStr
                                  parameters:(id)parameters
                                        name:(NSString *)name
                                    filePath:(NSString *)filePath
                                    progress:(WRNetWrapperProgress)progress
                                     success:(WRNetWrapperRequestDidSuccessBlock)success
                                     failure:(WRNetWrapperRequestDidFailedBlock)failure {
    
    NSURLSessionTask *sessionTask = [_sessionManager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        if (failure && error) failure(error);
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) progress(uploadProgress);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable data) {
        
        [[WRNetWrapper allSessionTask] removeObject:task];
        if (success) success(data);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[WRNetWrapper allSessionTask] removeObject:task];
        if (failure) failure(error);
    }];
    
    if (sessionTask) [[WRNetWrapper allSessionTask] addObject:sessionTask];
    return sessionTask;
}

+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)urlStr
                                       fileDir:(NSString *)fileDir
                                      progress:(WRNetWrapperProgress)progress
                                       success:(void(^)(NSString *))success
                                       failure:(WRNetWrapperRequestDidFailedBlock)failure {
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    __block NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) progress(downloadProgress);
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: (fileDir ? fileDir : @"Download")];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error && failure) failure(error);
        NSString *filePath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:filePath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[WRNetWrapper allSessionTask] removeObject:downloadTask];
        if (error) {
            if (failure) failure(error);
        } else {
            if (success) success(filePath.absoluteString);
        }
    }];
    
    [downloadTask resume];
    
    if (downloadTask) [[WRNetWrapper allSessionTask] addObject:downloadTask];
    return downloadTask;
}


#pragma mark - 请求成功或失败统一处理
- (void)handleSuccessWithURL:(NSString *)urlStr
                  parameters:(NSDictionary *)parameters
                       cache:(BOOL)isCache
                        task:(NSURLSessionDataTask * _Nonnull) task
                    response:(id  _Nullable)responseObject
                     success:(WRNetWrapperRequestDidSuccessBlock)success {

    [WRNetWrapper showNetworkActivityIndicator:NO];
    if (task) [[WRNetWrapper allSessionTask] removeObject:task];
    _data = responseObject;
    if ([_interceptor respondsToSelector:@selector(netWrapperInterceptorSuccessForApi:)]) {
        [_interceptor netWrapperInterceptorSuccessForApi:self];
    }
    if (success) success(responseObject);
    if ([_delegate respondsToSelector:@selector(netWrapperRequestDidSuccess:)]) {
        [_delegate netWrapperRequestDidSuccess:self];
    }
    if ([_mulitDelegate respondsToSelector:@selector(netWrapperRequestDidSuccess:)]) {
        [_mulitDelegate netWrapperRequestDidSuccess:self];
    }
    // 对数据进行异步缓存
    if (isCache) [WRCache addCacheWithData:responseObject URL:_requestURL cacheTime:_cacheTime];
}

- (void)handleFailureWithTask:(NSURLSessionDataTask * _Nonnull) task
                     response:(NSError * _Nonnull)error
                      failure:(WRNetWrapperRequestDidFailedBlock)failure {

    [WRNetWrapper showNetworkActivityIndicator:NO];
    if (task) [[WRNetWrapper allSessionTask] removeObject:task];
    [self parseError:error];
    if ([_interceptor respondsToSelector:@selector(netWrapperInterceptorFailForApi:)]) {
        [_interceptor netWrapperInterceptorFailForApi:self];
    }
    if (failure) failure(error);
    if ([_delegate respondsToSelector:@selector(netWrapperRequestDidFailed:)]) {
        [_delegate netWrapperRequestDidFailed:self];
    }
    if ([_mulitDelegate respondsToSelector:@selector(netWrapperRequestDidFailed:)]) {
        [_mulitDelegate netWrapperRequestDidFailed:self];
    }
}

- (void)handleNoNetworkWithFailure:(WRNetWrapperRequestDidFailedBlock)failure {
    // 可根据实际需求自行设置（_errorMessage、_error）
    _errorMessage = @"网络连接失败，请检查网络连接";
    _error = [[NSError alloc] initWithDomain:@"GBNetworkNotReachable" code:_statusCode userInfo:@{@"ErrorBody":_errorMessage}];
    if (failure) failure(_error);
    if ([_interceptor respondsToSelector:@selector(netWrapperInterceptorFailForApi:)]) {
        [_interceptor netWrapperInterceptorFailForApi:self];
    }
    if ([_delegate respondsToSelector:@selector(netWrapperRequestDidFailed:)]) {
        [_delegate netWrapperRequestDidFailed:self];
    }
}

#pragma mark - 解析 error
- (void)parseError:(NSError *)error {
    NSString *backendErrorDescription = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    NSData *jsonData = [backendErrorDescription dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    if (!dict) return;
    if ([dict.allKeys containsObject:@"status"]) {
        _statusCode = [dict[@"status"] intValue];
    }
    if ([dict.allKeys containsObject:@"error"]) {
        NSDictionary *errorDict = dict[@"error"];
        if (errorDict && [errorDict.allKeys containsObject:@"message"]) {
            _errorMessage = errorDict[@"message"];
        }
    }
}

#pragma mark - other
- (void)getCompleteRequestURL:(NSString *)urlStr method:(WRNetWrapperHTTPMethod)method parameters:(NSDictionary *)parameters {
    
    NSString *methodStr = @"";
    switch (method) {
        case WRNetWrapperHTTPMethodGET:    methodStr = @"GET";    break;
        case WRNetWrapperHTTPMethodPOST:   methodStr = @"POST";   break;
        case WRNetWrapperHTTPMethodPUT:    methodStr = @"PUT";    break;
        case WRNetWrapperHTTPMethodDELETE: methodStr = @"DELETE"; break;
        case WRNetWrapperHTTPMethodHEAD:   methodStr = @"HEAD";   break;
        case WRNetWrapperHTTPMethodPATCH:  methodStr = @"PATCH";  break;
    }
    
    NSError *error = nil;
    NSMutableURLRequest *request = [_sessionManager.requestSerializer requestWithMethod:methodStr URLString:urlStr parameters:parameters error:&error];
    if (!error) {
        _requestURL = request.URL.absoluteString;
    } else {
        _requestURL = urlStr;
    }
    NSLog(@"🚀🚀🚀:%@",_requestURL);
}

+ (void)showNetworkActivityIndicator:(BOOL)isShow {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = isShow;
}

- (void)dealloc {
    [WRNetWrapper cancelAllRequest];
}

+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}

@end



