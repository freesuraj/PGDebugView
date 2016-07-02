//
//  PGPlistReader.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 26/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

struct PGPlistReader {
    let plistOutput: AnyObject
    
    init(path: String) {
        if let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            plistOutput = dict
        } else if let array = NSArray(contentsOfFile: path) as? [AnyObject] {
            plistOutput = array
        } else {
            plistOutput = []
        }
    }
    
    init(object: AnyObject) {
        plistOutput = object
    }
    
    func read() -> [PGDebuggableData] {
        /// Caveat: If the plist has a number type and the value is 0 or 1, it'll be read as PGBoolean type
        func readKeyValue(key key: String, value: AnyObject?, inout holder: [PGDebuggableData]) {
            if let value = value as? String { holder.append(PGString(key: key, value: value)) }
            else if let value = value as? NSNumber where Int(value) != 1 && Int(value) != 0  {
                holder.append(PGNumber(key: key, value: value))
            }
            else if let value = value as? Bool { holder.append(PGBoolean(key: key, value: value)) }
            else if let value = value as? NSDate { holder.append(PGDate(key: key, value: value)) }
            else if let value = value as? [String: AnyObject] {
                var subModules: [PGDebuggableData] = []
                readDict(dict: value, holder: &subModules)
                holder.append(PGDictionary(key: key, value: subModules))
            } else if let value = value as? [AnyObject] {
                var subModules: [PGDebuggableData] = []
                readArray(array: value, holder: &subModules)
                holder.append(PGArray(key: key, value: subModules))
            }
        }
        
        func readArray(array array: [AnyObject], inout holder: [PGDebuggableData]) {
            for (_, value) in array.enumerate() {
                let key = "•"
                readKeyValue(key: key, value: value, holder: &holder)
            }
        }
        
        func readDict(dict dict: [String: AnyObject], inout holder: [PGDebuggableData]) {
            let keys = dict.keys.sort { $1 > $0 }
            for key in keys {
                let value = dict[key]
                readKeyValue(key: key, value: value, holder: &holder)
            }
        }
        var modules: [PGDebuggableData] = []
        if let dict = plistOutput as? [String: AnyObject] {
            readDict(dict: dict, holder: &modules)
        } else if let array = plistOutput as? [AnyObject] {
            readArray(array: array, holder: &modules)
        }
        return modules
    }
    
    static func dictionary(from modules: [PGDebuggableData]) -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        func readIntoDictionary(modules modules: [PGDebuggableData], inout holder: [String: AnyObject]) {
            for module in modules {
                if let m = module as? PGString { holder[m.key] = m.value }
                if let m = module as? PGNumber { holder[m.key] = m.value }
                if let m = module as? PGDate { holder[m.key] = m.value }
                if let m = module as? PGBoolean { holder[m.key] = m.value }
                if let m = module as? PGDictionary {
                    var holderDict: [String: AnyObject] = [:]
                    readIntoDictionary(modules: m.value, holder: &holderDict)
                    holder[m.key] = holderDict
                }
                if let m = module as? PGArray {
                    var holderArray: [AnyObject] = []
                    readIntoArray(modules: m.value, holder: &holderArray)
                    holder[m.key] = holderArray
                }
            }
        }
        
        func readIntoArray(modules modules: [PGDebuggableData], inout holder: [AnyObject]) {
            for module in modules {
                if let m = module as? PGString { holder.append(m.value) }
                if let m = module as? PGNumber { holder.append(m.value) }
                if let m = module as? PGDate { holder.append(m.value) }
                if let m = module as? PGBoolean { holder.append(m.value) }
                if let m = module as? PGDictionary {
                    var holderDict: [String: AnyObject] = [:]
                    readIntoDictionary(modules: m.value, holder: &holderDict)
                    holder.append(holderDict)
                }
                if let m = module as? PGArray {
                    var holderArray: [AnyObject] = []
                    readIntoArray(modules: m.value, holder: &holderArray)
                    holder.append(holderArray)
                }
            }
        }
        
        readIntoDictionary(modules: modules, holder: &dictionary)
        return dictionary
    }
    
    static func export(dictionary dictionary: [String: AnyObject], plistFile: String) -> (Bool, NSURL?) {
        func urlToPlist(folder folder: String, fileName: String) -> NSURL? {
            guard let documentUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first else {
                return nil
            }
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(documentUrl.URLByAppendingPathComponent(folder), withIntermediateDirectories: true, attributes: nil)
                var plistFilename = fileName
                if !plistFile.hasSuffix(".plist") {
                    plistFilename = "\(fileName).plist"
                }
                return documentUrl.URLByAppendingPathComponent("\(folder)/\(plistFilename)")
            } catch {
                return nil
            }
            
        }
        if let url = urlToPlist(folder: "DEBUG-PLIST", fileName: plistFile) {
            let dict = NSDictionary(dictionary: dictionary)
            return (dict.writeToURL(url, atomically: false), url)
        }
        return (false, nil)
    }
}