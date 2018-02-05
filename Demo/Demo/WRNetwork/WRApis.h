//
//  WRApis.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRNetWrapper.h"

typedef id<WRNetWrapperRequestDelegate> APICallBackDelegate;


#pragma mark - 首页
/// 请求 a
WRNetWrapper *req_test_a(APICallBackDelegate callBack);
/// 请求 b
WRNetWrapper *req_test_b(APICallBackDelegate callBack);
/// 请求 c
WRNetWrapper *req_test_c(APICallBackDelegate callBack);
/// 请求 d
WRNetWrapper *req_test_d(APICallBackDelegate callBack);
/// 请求 e
WRNetWrapper *req_test_e(APICallBackDelegate callBack);
/// 请求 f
WRNetWrapper *req_test_f(APICallBackDelegate callBack);



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
WRNetWrapper *req_wx_list(int pageIndex, APICallBackDelegate callBack);










