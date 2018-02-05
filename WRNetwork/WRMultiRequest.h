//
//  WRMultiRequest.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WRMultiRequest;
@class WRNetWrapper;

/// 多个请求成功或失败回调
@protocol WRMultiRequestDelegate <NSObject>
- (void)multiRequestDidSuccess:(WRMultiRequest *)multiRequest;
- (void)multiRequestDidFailed:(WRMultiRequest *)multiRequest;
@end

@interface WRMultiRequest : NSObject

@property (nonatomic, weak) id<WRMultiRequestDelegate> delegate;

/// 初始化方法
- (instancetype)initWithRequestArray:(NSArray<WRNetWrapper *> *)requestArray delegate:(id)delegate;

/// 发起网络请求
- (void)loadRequests;

/// 取消网络请求
- (void)cancelAllRequest;

@end
