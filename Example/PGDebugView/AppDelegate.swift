//
//  AppDelegate.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 05/30/2016.
//  Copyright (c) 2016 Suraj Pathak. All rights reserved.
//

import UIKit
import PGDebugView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let path = NSBundle.mainBundle().pathForResource("Debug", ofType: "plist") {
            let debugVC = PGDebugViewController(plistPath: path, readOnly: false)
            window?.rootViewController = UINavigationController(rootViewController: debugVC)
            window?.makeKeyAndVisible()
        }
        return true
    }
}

