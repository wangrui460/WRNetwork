# WRNetWrapper
基于 Alamofire 的一个网络请求的封装，包括闭包回调 和 成功或失败代理方法！

## 1. 接口
**方式一：请求后的闭包回调**
<pre><code>
/// 闭包回调请求(类方法)
///
/// - Parameters:
///   - method: 请求方式 get、post...
///   - url: 可以是字符串，也可以是URL
///   - parameters: 参数字典
///   - finishedCallback: 完成请求的回调
class func request(method:HTTPMethod, url:String, parameters:NSDictionary?, finishedCallback:  @escaping (_ result : AnyObject, _ error: Error?) -> ())
{
    Alamofire.request(url, method: method, parameters: parameters as? Parameters).responseJSON
    { (response) in
        let data = response.result.value
        if (response.result.isSuccess)
        {
            finishedCallback(data as AnyObject, nil)
        }
        else
        {
            finishedCallback(data as AnyObject,response.result.error)
        }
    }
}
</code></pre>


**方式二：请求后的代理方法返回**
<pre><code>
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
    Alamofire.request(url, method: method, parameters: parameters as? Parameters).responseJSON
    { (response) in
        let data = response.result.value
        if (response.result.isSuccess)
        {
            delegate.netWortDidSuccess?(result: data as AnyObject, requestName: requestName, parameters: parameters)
        }
        else
        {
            delegate.netWortDidFailed?(result: data as AnyObject, error:response.error, requestName: requestName, parameters: parameters)
        }
    }
}

@objc protocol WRNetWrapperDelegate:NSObjectProtocol
{
    // TODO：研究 如果把result的类型改为Any会怎么样
    @objc optional func netWortDidSuccess(result:AnyObject, requestName:String, parameters:NSDictionary?);
    @objc optional func netWortDidFailed (result:AnyObject, error:Error?, requestName:String, parameters:NSDictionary?);
}
</code></pre>

## 2. 如何使用
**代理返回方式**
<pre><code>
let requestSplashImage = "requestSplashImage"
// 网络请求，就这么简单
WRApiContainer.requestSplashImage(delegate: self)

// 网络请求成功
func netWortDidSuccess(result: AnyObject, requestName: String, parameters: NSDictionary?)
{
    if (requestName == requestSplashImage)
    {
    // 请求 requestSplashImage 对应的成功返回
    }
}

// 网络请求失败
func netWortDidFailed(result: AnyObject, error:Error?,  requestName: String, parameters: NSDictionary?)
{
}
</code></pre>


**闭包回调方式**
<pre><code>
let urlStr = "http://news-at.zhihu.com/api/7/prefetch-launch-images/1080*1920"
WRNetWrapper.request(method: .get, url: urlStr, parameters: nil)
{ [weak self] (result, error) in
    if let weakSelf = self
    {
        if (error == nil)
        {
            // 请求成功
        }
        else
        {
            // 请求失败
        }
    }
}
</code></pre>





你觉得对你有所帮助的话，请献上宝贵的Star！！！ 不胜感激！！！
