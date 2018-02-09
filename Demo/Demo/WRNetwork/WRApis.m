//
//  WRApis.m
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import "WRApis.h"

@interface WRRequestor : WRNetWrapper <WRNetWrapperDataSource, WRNetWrapperInterceptor>
@property (nonatomic, copy)  NSString *requestName;
@property (nonatomic, copy)  NSDictionary *params;
@property (nonatomic, assign) WRNetWrapperHTTPMethod httpMethod;
@property (nonatomic, assign) BOOL isCache;
@property (nonatomic, assign) NSTimeInterval expiryTime;
@end

@implementation WRRequestor

// WRNetWrapperDataSource
- (NSString *)netWrapperBaseURLForApi:(WRNetWrapper *)manager {
    return @"http://v.juhe.cn/";
}
- (NSDictionary *)netWrapperParametersForApi:(WRNetWrapper *)manager {
    return _params;
}
- (NSString *)netWrapperRequestNameForApi:(WRNetWrapper *)manager {
    return _requestName;
}
- (WRNetWrapperHTTPMethod)netWrapperHttpMethodForApi:(WRNetWrapper *)manager {
    return _httpMethod;
}
- (BOOL)netWrapperIsCacheForApi:(WRNetWrapper *)manager {
    return _isCache;
}
- (NSTimeInterval)newWrapperCacheTimeForApi:(WRNetWrapper *)netWrapper {
    return _expiryTime;
}

// WRNetWrapperInterceptor
- (void)netWrapperInterceptorFailForApi:(WRNetWrapper *)manager {
    NSString *errorMessage = manager.errorMessage;
    NSLog(@"%@", errorMessage);
}
- (void)netWrapperInterceptorSuccessForApi:(WRNetWrapper *)manager {

}
@end



#pragma mark - 下面的所有 API 都需要经过这里

/// 创建请求对象，将多个请求对象加入数组（适用于批量请求/依赖请求）
WRNetWrapper *createRequest(WRNetWrapperHTTPMethod httpMethod, NSDictionary* params, NSString *requestName, BOOL isCache, NSTimeInterval cacheTime, NetCallBack callbake)
{
    WRRequestor* req = [[WRRequestor alloc] init];
    req.requestName = requestName;
    req.params = params;
    req.httpMethod = httpMethod;
    req.isCache = isCache;
    req.expiryTime = cacheTime;
    req.dataSource = req;
    req.delegate = callbake;
    req.interceptor = req;
    return req;
}

/// 创建请求对象后，立马发起请求
WRNetWrapper *sendRequest(WRNetWrapperHTTPMethod httpMethod, NSDictionary* params, NSString *requestName, BOOL isCache, NSTimeInterval cacheTime, NetCallBack callbake) {
    
    WRNetWrapper *req = createRequest(httpMethod, params, requestName, isCache, cacheTime, callbake);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [req loadRequest];
    });
    return req;
}

//////////////////////////////////////////////////////////////////////////
#pragma mark - ⬇️⬇️⬇️ 所有 API ⬇️⬇️⬇️
//////////////////////////////////////////////////////////////////////////









#pragma mark - 首页
/// 请求 a ⚠️ 这里是 createRequest
WRNetWrapper *req_test_a(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(0) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}

/// 请求 b
WRNetWrapper *req_test_b(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(1) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}

/// 请求 c
WRNetWrapper *req_test_c(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(2) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}

/// 请求 d
WRNetWrapper *req_test_d(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(3) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}

/// 请求 e
WRNetWrapper *req_test_e(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(4) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}

/// 请求 f
WRNetWrapper *req_test_f(NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(5) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return createRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 0, callBack);
}




#pragma mark - 发现
// xxx 请求接口
// xxx 请求接口
// xxx 请求接口




#pragma mark - 购物车
// xxx 请求接口
// xxx 请求接口
// xxx 请求接口




#pragma mark - 我的
/// 笑话列表
WRNetWrapper *req_wx_list(int pageIndex, NetCallBack callBack) {
    
    NSMutableDictionary *dictM = [NSMutableDictionary new];
    [dictM setValue:@(pageIndex) forKey:@"pno"];
    [dictM setValue:@(20) forKey:@"ps"];
    [dictM setValue:@"json" forKey:@"dtype"];
    [dictM setValue:@"6faa9998c4940a47e84954b343753505" forKey:@"key"];
    return sendRequest(WRNetWrapperHTTPMethodGET, dictM, @"weixin/query", YES, 10, callBack);
}







