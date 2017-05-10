//
//  AppDelegate.swift
//  ZhihuDaily-Swift3.0
//
//  Created by wangrui on 2017/5/5.
//  Copyright © 2017年 wangrui. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let requestSplashImage = "requestSplashImage"
    let bgImageView:UIImageView = UIImageView(frame: UIScreen.main.bounds)
    var advImageView:UIImageView?
    let SPLASHIMAGE = "SPLASHIMAGE"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // 启动页闪屏网络请求，就这么简单
        WRApiContainer.requestSplashImage(delegate: self)
        
        // 闭包回调的方式
//        let urlStr = "http://news-at.zhihu.com/api/7/prefetch-launch-images/1080*1920"
//        WRNetWrapper.request(method: .get, url: urlStr, parameters: nil)
//        { [weak self] (result, error) in
//            if let weakSelf = self
//            {
//                if (error == nil)
//                {
//                    // 请求成功
//                }
//                else
//                {
//                    // 请求失败
//                }
//            }
//        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
        let navVC:UINavigationController = UINavigationController.init(rootViewController: ViewController())
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        
        addAdvertisement()
        removeAdvertisement()
        return true
    }
    
    
    /// 添加广告
    private func addAdvertisement()
    {
        bgImageView.image = UIImage(named: "backImage")
        window!.addSubview(bgImageView)
        if (IS_SCREEN_4_INCH) {
            advImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 100))
        } else if (IS_SCREEN_47_INCH) {
            advImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 115))
        } else {
            advImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - 130))
        }
        bgImageView.addSubview(advImageView!)
        if let data = UserDefaults.standard.object(forKey: SPLASHIMAGE) as? Data
        {
            advImageView?.image = UIImage(data: data)
        }
    }

    /// 移除广告
    private func removeAdvertisement()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute:
        {
            UIView.animate(withDuration: 1.0, animations:
            {
                self.advImageView?.alpha = 0
                self.bgImageView.alpha = 0
            },completion: { (finish) in
                self.bgImageView.removeFromSuperview()
            })
        })
    }
}



// MARK: - WRNetWrapperDelegate
extension AppDelegate: WRNetWrapperDelegate
{
    func netWortDidSuccess(result: AnyObject, requestName: String, parameters: NSDictionary?)
    {
        if (requestName == requestSplashImage)
        {
            let json = JSON(result)
    //            let dict = json.dictionaryValue
    //            let creatives = dict["creatives"]
    //            let url = creatives?[0]["url"].string
            
            let splashUrl = json.dictionaryValue["creatives"]?[0]["url"].string
            
            // 对喵神的 Kingfisher 修改了一下，解决了当placeholder为nil的时候，如果原图片框中已有图片，则会闪一下的问题
            // https://github.com/wangrui460/Kingfisher
            advImageView?.kf.setImage(with: URL(string: splashUrl!), completionHandler:
            { [weak self] (image, error, cachtType, url) in
                if let weakSelf = self
                {
                    let data = UIImagePNGRepresentation(image!)
                    UserDefaults.standard.set(data, forKey: weakSelf.SPLASHIMAGE)
                }
            })
        }
    }

    func netWortDidFailed(result: AnyObject, error:Error?, requestName: String, parameters: NSDictionary?)
    {
        print(result.error)
    }
}







