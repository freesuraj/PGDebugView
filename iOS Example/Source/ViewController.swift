//
//  ViewController.swift
//  iOS Example
//
//  Created by Suraj Pathak on Sep 23, 2016.
//  Copyright © 2016 PropertyGuru Pte Ltd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.green
        let button = UIButton(frame: CGRect(x: 30, y: 20, width: 200, height: 200))
        button.setTitle("Open Debug View", for: .normal)
        button.addTarget(self, action: #selector(openDebug), for: .touchUpInside)
        view.addSubview(button)
        button.center = view.center
    }
    
    func openDebug() {
        PGDebugViewHelper.shared.presentDebugViewInRoot()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

