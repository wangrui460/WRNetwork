//
//  WRApis.h
//  PandaMakeUp
//
//  Created by wangrui on 2016/7/28.
//  Copyright © 2016年 lrlz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WRNetWrapper.h"

typedef id<WRNetWrapperRequestDelegate> NetCallBack;

/// 还在找在哪里发起网络请求的吗？
/// 当后台小哥问你xx接口传xx参数了吗，你是否还在思考接口在"?"目录下的"?"文件夹下的"?"文件中？
///
/// 不妨试试以下方式，接口一目了然，网络请求只需要一行代码，剩下的交给回调吧~

#pragma mark - 首页
WRNetWrapper *req_test_a(NetCallBack callBack);     // 请求 a
WRNetWrapper *req_test_b(NetCallBack callBack);     // 请求 b
WRNetWrapper *req_test_c(NetCallBack callBack);     // 请求 c
WRNetWrapper *req_test_d(NetCallBack callBack);     // 请求 d
WRNetWrapper *req_test_e(NetCallBack callBack);     // 请求 e
WRNetWrapper *req_test_f(NetCallBack callBack);     // 请求 f

#pragma mark - 发现
// xxx 请求接口
// xxx 请求接口
// xxx 请求接口

#pragma mark - 购物车
// xxx 请求接口
// xxx 请求接口
// xxx 请求接口

#pragma mark - 我的
WRNetWrapper *req_wx_list(int pageIndex, NetCallBack callBack); // 笑话列表










