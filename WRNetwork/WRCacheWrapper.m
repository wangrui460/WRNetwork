//
//  WRCacheWrapper.m
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import "WRCacheWrapper.h"

@interface WRCacheWrapper ()

@property (nonatomic, copy) NSDate *lastUpdateDate; // 最近一次更新时间

@end

@implementation WRCacheWrapper

- (BOOL)isEmpty {
    return (_data == nil || _data == [NSNull null]);
}

- (BOOL)isExpire {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateDate];
    return (_cacheTime != 0 && timeInterval > _cacheTime);
}

- (void)setData:(id)data {
    _data = [data copy];
    _lastUpdateDate = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
