//
//  AppDelegate.swift
//  WRNetWrapper
//
//  Created by wangrui on 2017/5/4.
//  Copyright © 2017年 wangrui. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        self.window = UIWindow(frame:UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.rootViewController = ViewController()
        self.window!.makeKeyAndVisible()
        
        return true
    }
}

