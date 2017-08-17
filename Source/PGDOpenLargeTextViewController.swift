//
//  PGDOpenLargeTextViewController.swift
//  PGDebugView
//
//  Created by Jin Hyong Park on 16/8/17.
//  Copyright © 2017 PropertyGuru Pte Ltd. All rights reserved.
//

import UIKit
import MessageUI

internal class PGDOpenLargeTextViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var loggedFilename: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exit = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(PGDOpenLargeTextViewController.exit))
        self.navigationItem.leftBarButtonItem = exit
        let export = UIBarButtonItem(title: "ToMail!", style: .plain, target: self, action: #selector(PGDOpenLargeTextViewController.mail))
        let clean = UIBarButtonItem(title: "ClearLog", style: .plain, target: self, action: #selector(PGDOpenLargeTextViewController.clearLog))
        self.navigationItem.rightBarButtonItems = [clean, export]
        

        guard let filename = loggedFilename else { return }
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths[0]
        let logfilePath = (documentDirectory as NSString).appendingPathComponent(filename)
        
        mainLabel.text = (try? String(contentsOfFile: logfilePath)) ?? ""
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clearLog() {
        guard let filename = loggedFilename else { return }
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths[0]
        let logfilePath = (documentDirectory as NSString).appendingPathComponent(filename)
        do {
            try FileManager.default.removeItem(atPath: logfilePath)
            mainLabel.text = ""
        } catch {
            print( "remove error : [\(error)]")
        }
        
    }

    func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    func mail() {
        guard let filename = loggedFilename else { return }
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "", message: "Need Mail configuration", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OKAY", style: UIAlertActionStyle.default) { action in
                alert.dismiss(animated: true, completion: nil)
            })
            alert.present(alert, animated: true, completion: nil)
            return
        }
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectory = paths[0]
        let logfilePath = (documentDirectory as NSString).appendingPathComponent(filename)
        
        let log = (try? String(contentsOfFile: logfilePath)) ?? ""
        guard let attatchment = log.data(using: .utf8) else { return }
        
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = self
        vc.addAttachmentData(attatchment, mimeType: "text/plain", fileName: "log.txt")
        self.present(vc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
