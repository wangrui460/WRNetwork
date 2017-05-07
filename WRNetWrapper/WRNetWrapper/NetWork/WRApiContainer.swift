//
//  ApiContainer.swift
//  ZhihuDaily-Swift3.0
//
//  Created by wangrui on 2017/5/7.
//  Copyright © 2017年 wangrui. All rights reserved.
//

import UIKit
import Alamofire

let BaseURL:String = "http://news-at.zhihu.com/api/"

class WRApiContainer: NSObject
{
    /// 根据知乎日报二次封装的一个网络请求
    ///
    /// - Parameters:
    ///   - url:            当前接口需要的 URL
    ///   - requestName:    请求名称
    ///   - delegate:       处理网络请求成功和失败的代理
    ///   - param:          请求参数                    可选参数，默认为nil
    ///   - method:         网络请求类型                 可选参数，默认为 Get 请求方式
    class func WRRequest(url:String, requestName:String, delegate:WRNetWrapperDelegate, param:NSDictionary? = nil, method: HTTPMethod? = .get)
    {
        WRNetWrapper.requestDelegate(method: .get, url: url, requestName: requestName, parameters: nil, delegate: delegate)
    }
}


// MARK: - 所有接口的集合
extension WRApiContainer
{
    // 启动页闪屏
    class func requestSplashImage(delegate:WRNetWrapperDelegate)
    {
        let curURL = BaseURL.appending("7/prefetch-launch-images/1080*1920")
        WRRequest(url: curURL, requestName: "requestSplashImage", delegate: delegate)
    }
    
    
}





