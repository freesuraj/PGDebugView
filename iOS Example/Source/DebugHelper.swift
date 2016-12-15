//
//  DebugHelper.swift
//  iOS Example
//
//  Created by Suraj Pathak on 15/12/16.
//  Copyright © 2016 PropertyGuru Pte Ltd. All rights reserved.
//

import UIKit
import PGDebugView

class PGDebugViewHelper: NSObject {
    
    static let shared = PGDebugViewHelper()
    private let exportFolderName: String = "PlistContainer"
    private let exportFileName: String = "AppConfig"
    
    func presentDebugViewInRoot() {
        if let path = defaultDebugPlistPath() {
            let debugVc = PGDebugViewController(plistPath: path)
            var oldRoot: UIViewController?
            debugVc.exportFolderName = exportFolderName
            debugVc.exportFilename = exportFileName
            debugVc.title = "Debug Mode"
            debugVc.didFinishExport = { success, _ in
                if success {
                    print("Export success !!")
                }
            }
            debugVc.shouldExit = {
                if let delegate = UIApplication.shared.delegate,
                    let window = delegate.window,
                    let previousRoot = oldRoot {
                    window?.rootViewController = previousRoot
                    window?.makeKeyAndVisible()
                }
            }
            let vc = UINavigationController(rootViewController: debugVc)
            if let delegate = UIApplication.shared.delegate,
                let window = delegate.window {
                oldRoot = window?.rootViewController
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
            }
        }
    }
    
    func defaultDebugPlistPath() -> String? {
        guard let url = PGDebugExport.urlToPlist(folder: exportFolderName, fileName: exportFileName), FileManager.default.fileExists(atPath: url.path) else {
            return Bundle.main.path(forResource: "Debug", ofType: "plist")
        }
        return url.path
    }
    
}
