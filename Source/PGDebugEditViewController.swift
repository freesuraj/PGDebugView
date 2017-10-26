//
//  PGDebugEditViewController.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 29/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

open class PGDebugEditViewController: UIViewController {
    var textDidUpdate: ((Any) -> Void)?
    var textView: UITextView!
    open override func viewDidLoad() {
        super.viewDidLoad()
        textView = UITextView(frame: view.frame)
        textView.delegate = self
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(self.textView)
        title = "Please write valid JSON string to add"
        textView.becomeFirstResponder()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Paste", style: .plain, target: self, action: #selector(pasteStuff))
    }
    
    @objc func pasteStuff() {
        if let copiedItem = UIPasteboard.general.string {
            textView.text = copiedItem
            checkJsonValidity(textView: textView)
        }
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let block = textDidUpdate {
            if let json = self.textView.text.validJson() {
                block(json)
            }
        }
    }
}

extension PGDebugEditViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        checkJsonValidity(textView: textView)
    }
    func checkJsonValidity(textView: UITextView) {
        if let _ = textView.text.validJson() {
            textView.textColor = UIColor.darkGray
        } else {
            textView.textColor = UIColor.red
        }
    }
}

extension String {
    func validJson() -> Any? {
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch  {
            }
        }
        return nil
    }
}
