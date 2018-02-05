//
//  WRCacheWrapper.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WRCacheWrapper : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, assign) NSTimeInterval cacheTime; // 设置多久过期,默认不过期
@property (nonatomic, assign, readonly) BOOL isExpire;  // 判断是否过期
@property (nonatomic, assign, readonly) BOOL isEmpty;   // 判断 data 是否为空

@end
