//
//  PGDebugExport.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 15/12/16.
//  Copyright © 2016 PropertyGuru Pte Ltd. All rights reserved.
//

import Foundation

public class PGDebugExport: NSObject {
    
    static func documentUrl() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    public static func urlToPlist(folder: String, fileName: String) -> URL? {
        guard let documentUrl = documentUrl() else {
            return nil
        }
        var plistFilename = fileName
        if !fileName.hasSuffix(".plist") {
            plistFilename = "\(fileName).plist"
        }
        return documentUrl.appendingPathComponent("\(folder)/\(plistFilename)")
        
    }
    
    static func export(dictionary: [String: Any], folderName: String, plistFile: String) -> (Bool, URL?) {
        // Create folder if not present
        if let documentUrl = documentUrl() {
            try? FileManager.default.createDirectory(at: documentUrl.appendingPathComponent(folderName), withIntermediateDirectories: true, attributes: nil)
        }
        
        if let url = urlToPlist(folder: folderName, fileName: plistFile) {
            let dict = NSDictionary(dictionary: dictionary)
            print("Writing dict ", dict)
            return (dict.write(to: url, atomically: false), url)
        }
        return (false, nil)
    }
    
}
