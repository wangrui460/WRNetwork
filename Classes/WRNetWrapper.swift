//
//  NetWorkHelper.swift
//  WRNetWrapper
//
//  Created by wangrui on 2017/5/4.
//  Copyright © 2017年 wangrui. All rights reserved.
//


// tips：因为Swift存在namespace，所以就不需要写类前缀了
import UIKit
import Alamofire
import SwiftyJSON

// 网络请求超时时间
let NetworkTimeoutInterval:Double = 10

@objc protocol WRNetWrapperDelegate:NSObjectProtocol
{
    // TODO：研究 如果把result的类型改为Any会怎么样
    @objc optional func netWortDidSuccess(result:AnyObject,requestName:String,parameters:NSDictionary?);
    @objc optional func netWortDidFailed (result:AnyObject,requestName:String,parameters:NSDictionary?);
}

class WRNetWrapper: NSObject
{
    var delegate:WRNetWrapperDelegate?
    static var sessionManager:SessionManager? = nil
    
    /// 闭包回调请求(类方法)
    ///
    /// - Parameters:
    ///   - method: 请求方式 get、post...
    ///   - url: 可以是字符串，也可以是URL
    ///   - parameters: 参数字典
    ///   - finishedCallback: 完成请求的回调
    class func request(method:HTTPMethod, url:String, parameters:NSDictionary?, finishedCallback:  @escaping (_ result : Any, _ error: Error?) -> ())
    {
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkTimeoutInterval
        sessionManager = SessionManager(configuration: config)
        sessionManager?.request(url, method: method, parameters: parameters as? Parameters).responseJSON
        { (response) in
            let data = response.result.value
            // 我这里使用了框架 SwiftyJSON 来处理结果，如果不喜欢也可以自己来处理
            let json = JSON(data as Any)
            if (response.result.isSuccess)
            {
                finishedCallback(json, nil)
            }
            else
            {
                finishedCallback(json,response.result.error)
            }
        }
    }
    
    
    /// 代理方法请求(类方法)
    ///
    /// - Parameters:
    ///   - method: 请求方式 get、post...
    ///   - url: 可以是字符串，也可以是URL
    ///   - requestName: 请求名字，一个成功的代理方法可以处理多个请求，所以用requestName来区分具体请求
    ///   - parameters: 参数字典
    ///   - delegate: 代理对象
    class func requestDelegate(method:HTTPMethod, url:String, requestName:String, parameters:NSDictionary?, delegate:AnyObject)
    {
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = NetworkTimeoutInterval
        sessionManager = SessionManager(configuration: config)
        sessionManager?.request(url, method: method, parameters: parameters as? Parameters).responseJSON
        { (response) in
            let data = response.result.value
            // 我这里使用了框架 SwiftyJSON 来处理结果，如果不喜欢也可以自己来处理
            let json = JSON(data as Any)

            if (response.result.isSuccess)
            {
                delegate.netWortDidSuccess?(result: json as AnyObject, requestName: requestName, parameters: parameters)
            }
            else
            {
                delegate.netWortDidFailed?(result: json as AnyObject, requestName: requestName, parameters: parameters)
            }
        }
    }
    
}
