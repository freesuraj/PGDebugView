//
//  PGDebugExport.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 15/12/16.
//  Copyright © 2016 PropertyGuru Pte Ltd. All rights reserved.
//

import Foundation

public class PGDebugExport: NSObject {
    
    public static func urlToPlist(folder: String, fileName: String) -> URL? {
        guard var documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        documentUrl.appendPathComponent(folder)
        do {
            try FileManager.default.createDirectory(at: documentUrl, withIntermediateDirectories: true, attributes: nil)
            var plistFilename = fileName
            if !fileName.hasSuffix(".plist") {
                plistFilename = "\(fileName).plist"
            }
            return documentUrl.appendingPathComponent("\(folder)/\(plistFilename)")
        } catch {
            return nil
        }
        
    }
    
    static func export(dictionary: [String: Any], folderName: String, plistFile: String) -> (Bool, URL?) {
        
        if let url = urlToPlist(folder: folderName, fileName: plistFile) {
            let dict = NSDictionary(dictionary: dictionary)
            return (dict.write(to: url, atomically: false), url)
        }
        return (false, nil)
    }
    
}
