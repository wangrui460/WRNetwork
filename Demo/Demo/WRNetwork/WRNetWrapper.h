//
//  WRNetWrapper.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "WRCache.h"
@class AFHTTPSessionManager;
@class WRNetWrapper;

typedef NS_ENUM (NSUInteger, WRNetWrapperHTTPMethod) {
    WRNetWrapperHTTPMethodGET = 0,
    WRNetWrapperHTTPMethodPOST,
    WRNetWrapperHTTPMethodPUT,
    WRNetWrapperHTTPMethodDELETE,
    WRNetWrapperHTTPMethodHEAD,
    WRNetWrapperHTTPMethodPATCH
};

typedef NS_ENUM(NSUInteger, WRNetworkStatus) {
    WRNetworkStatusUnknown = 0,         /// 未知网络
    WRNetworkStatusNotReachable,        /// 无网络
    WRNetworkStatusReachableViaWWAN,    /// 手机网络
    WRNetworkStatusReachableViaWIFI     /// WIFI网络
};

/// 请求成功/失败/获取缓存的Block
typedef void(^WRNetWrapperRequestDidSuccessBlock)(id data);
typedef void(^WRNetWrapperRequestDidFailedBlock)(NSError *error);
typedef void(^WRNetWrapperGetCacheBlock)(id cache);

/// 上传或下载的进度 (completedUnitCount:当前大小  totalUnitCount:总大小)
typedef void (^WRNetWrapperProgress)(NSProgress *progress);

/// 网络状态变更的Block
typedef void(^WRNetworkStatusChangeBlock)(WRNetworkStatus status);

/// api回调 (请求成功、失败、获取缓存)
@protocol WRNetWrapperRequestDelegate <NSObject>
@required
- (void)netWrapperRequestDidSuccess:(WRNetWrapper *)netWrapper;
- (void)netWrapperRequestDidFailed:(WRNetWrapper *)netWrapper;
@optional
- (void)netWrapperGetCacheDidFinished:(WRNetWrapper *)netWrapper;
@end

/// 数据源
@protocol WRNetWrapperDataSource <NSObject>
@required
- (NSDictionary *)netWrapperParametersForApi:(WRNetWrapper *)netWrapper;
- (NSString *)netWrapperBaseURLForApi:(WRNetWrapper *)netWrapper;
- (NSString *)netWrapperRequestNameForApi:(WRNetWrapper *)netWrapper;
- (WRNetWrapperHTTPMethod)netWrapperHttpMethodForApi:(WRNetWrapper *)netWrapper;
@optional
- (BOOL)netWrapperIsCacheForApi:(WRNetWrapper *)netWrapper;
- (NSTimeInterval)newWrapperCacheTimeForApi:(WRNetWrapper *)netWrapper;
@end

/// 拦截器
@protocol WRNetWrapperInterceptor <NSObject>
@optional
- (void)netWrapperInterceptorFailForApi:(WRNetWrapper *)netWrapper;
- (void)netWrapperInterceptorSuccessForApi:(WRNetWrapper *)netWrapper;
@end



@interface WRNetWrapper : NSObject

@property (nonatomic, weak) id<WRNetWrapperRequestDelegate> delegate;
@property (nonatomic, weak) id<WRNetWrapperRequestDelegate> mulitDelegate;
@property (nonatomic, weak) id<WRNetWrapperDataSource> dataSource;
@property (nonatomic, weak) id<WRNetWrapperInterceptor> interceptor;

@property (nonatomic, copy,   readonly) NSString  *requestURL;       // 请求的 url
@property (nonatomic, copy,   readonly) NSString  *errorMessage;     // 错误信息
@property (nonatomic, assign, readonly) NSInteger statusCode;        // http 状态码
@property (nonatomic, strong, readonly) NSError   *error;            // 请求失败返回的 error
@property (nonatomic, strong, readonly) id data;                     // 请求成功数据
@property (nonatomic, strong, readonly) id cache;                    // http chche
@property (nonatomic, assign, readonly) NSTimeInterval cacheTime;    // 缓存时长(0表示不过期)
@property (nonatomic, strong, readonly) NSURLSessionTask *sessionTask;

/// 是否有网络
+ (BOOL)isNetworkReachable;
/// 是否有网络并且是蜂窝移动网
+ (BOOL)isNetworkReachableViaWWAN;
/// 是否有网络并且是无线网
+ (BOOL)isNetworkReachableViaWIFI;
/// 实时获取网络状态
+ (void)setReachableStatusChangeBlock:(WRNetworkStatusChangeBlock)changeBlock;


/// 取消 HTTP 请求
+ (void)cancelAllRequest;
+ (void)cancelRequestWithURL:(NSString *)urlStr;


/// 发起网络请求以 delegate 的方式回调 (这里只适合遵守了 delegate 和 dataSource 两个协议对象使用)
- (void)loadRequest;

/// 网络请求以 block 的方式回调
- (WRNetWrapper *)requestWithURL:(NSString *)urlStr
                      parameters:(NSDictionary *)parameters
                      httpMethod:(WRNetWrapperHTTPMethod)httpMethod
                         isCache:(BOOL)isCache
                       cacheTime:(NSTimeInterval)cacheTime
                           cache:(WRNetWrapperGetCacheBlock)cache
                         success:(WRNetWrapperRequestDidSuccessBlock)success
                         failure:(WRNetWrapperRequestDidFailedBlock)failure;

/// 上传文件
+ (__kindof NSURLSessionTask *)uploadWithURL:(NSString *)urlStr
                                  parameters:(id)parameters
                                        name:(NSString *)name
                                    filePath:(NSString *)filePath
                                    progress:(WRNetWrapperProgress)progress
                                     success:(WRNetWrapperRequestDidSuccessBlock)success
                                     failure:(WRNetWrapperRequestDidFailedBlock)failure;

/// 下载文件
+ (__kindof NSURLSessionTask *)downloadWithURL:(NSString *)urlStr
                                       fileDir:(NSString *)fileDir
                                      progress:(WRNetWrapperProgress)progress
                                       success:(void(^)(NSString *filePath))success
                                       failure:(WRNetWrapperRequestDidFailedBlock)failure;

@end

