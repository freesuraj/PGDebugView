//
//  PGDebugEditViewController.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 29/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

public class PGDebugEditViewController: UIViewController {
    var textDidUpdate: (AnyObject -> Void)?
    var textView: UITextView!
    public override func viewDidLoad() {
        super.viewDidLoad()
        textView = UITextView(frame: view.frame)
        textView.delegate = self
        textView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(self.textView)
        title = "Please write valid JSON string to add"
        textView.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Paste", style: .Plain, target: self, action: #selector(pasteStuff))
    }
    
    func pasteStuff() {
        if let copiedItem = UIPasteboard.generalPasteboard().string {
            textView.text = copiedItem
            checkJsonValidity(textView: textView)
        }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let block = textDidUpdate {
            if let json = self.textView.text.validJson() {
                block(json)
            }
        }
    }
}

extension PGDebugEditViewController: UITextViewDelegate {
    public func textViewDidChange(textView: UITextView) {
        checkJsonValidity(textView: textView)
    }
    func checkJsonValidity(textView textView: UITextView) {
        if let _ = textView.text.validJson() {
            textView.textColor = UIColor.darkGrayColor()
        } else {
            textView.textColor = UIColor.redColor()
        }
    }
}

extension String {
    func validJson() -> AnyObject? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: [])
            } catch  {
            }
        }
        return nil
    }
}
