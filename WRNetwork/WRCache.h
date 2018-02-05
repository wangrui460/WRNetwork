//
//  WRCache.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRCache : NSObject

/// 添加缓存
+ (void)addCacheWithData:(id)data URL:(NSString *)urlStr cacheTime:(NSTimeInterval)cacheTime;

/// 获取缓存
+ (id)getCacheWithURL:(NSString *)urlStr;

/// 删除缓存
+ (void)removeCacheWithURL:(NSString *)urlStr;
+ (void)removeAllCache;

@end
