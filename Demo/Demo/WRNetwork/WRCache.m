//
//  WRCache.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import "WRCache.h"
#import "WRCacheWrapper.h"

@implementation WRCache
static NSCache *_cache;

+ (void)initialize {
    _cache = [[NSCache alloc] init];
}

+ (void)addCacheWithData:(id)data URL:(NSString *)urlStr cacheTime:(NSTimeInterval)cacheTime {
    WRCacheWrapper *cacheWrapper = [_cache objectForKey:urlStr];
    if (cacheWrapper == nil) {
        cacheWrapper = [[WRCacheWrapper alloc] init];
    }
    cacheWrapper.data = data;
    cacheWrapper.cacheTime = cacheTime;
    [_cache setObject:cacheWrapper forKey:urlStr];
}

+ (id)getCacheWithURL:(NSString *)urlStr {
    WRCacheWrapper *cacheWrapper = [_cache objectForKey:urlStr];
    if (cacheWrapper.isEmpty || cacheWrapper.isExpire)  {
        // 如果过期了，就把缓存删除
        [self removeCacheWithURL:urlStr];
        return nil;
    }
    return cacheWrapper.data;
}

+ (void)removeCacheWithURL:(NSString *)urlStr {
    [_cache removeObjectForKey:urlStr];
}

+ (void)removeAllCache {
    [_cache removeAllObjects];
}

@end

