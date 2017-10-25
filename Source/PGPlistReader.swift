//
//  PGPlistReader.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 26/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import Foundation

struct PGPlistReader {
    let plistOutput: Any
    
    init(path: String) {
        if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            plistOutput = dict as Any
        } else if let array = NSArray(contentsOfFile: path) as? [Any] {
            plistOutput = array as Any
        } else {
            plistOutput = []
        }
    }
    
    init(object: Any) {
        plistOutput = object
    }
    
    func read() -> [PGDebuggableData] {
        /// Caveat: If the plist has a number type and the value is 0 or 1, it'll be read as PGBoolean type
        func readKeyValue(key: String, value: Any?, holder: inout [PGDebuggableData]) {
            if let value = value as? String { holder.append(PGString(key: key, value: value)) }
            else if let value = value as? NSNumber , Int(truncating: value) != 1 && Int(truncating: value) != 0  {
                holder.append(PGNumber(key: key, value: value))
            }
            else if let value = value as? Bool { holder.append(PGBoolean(key: key, value: value)) }
            else if let value = value as? Date { holder.append(PGDate(key: key, value: value)) }
            else if let value = value as? [String: Any] {
                var subModules: [PGDebuggableData] = []
                readDict(dict: value, holder: &subModules)
                holder.append(PGDictionary(key: key, value: subModules))
            } else if let value = value as? [Any] {
                var subModules: [PGDebuggableData] = []
                readArray(array: value, holder: &subModules)
                holder.append(PGArray(key: key, value: subModules))
            }
        }
        
        func readArray(array: [Any], holder: inout [PGDebuggableData]) {
            for (_, value) in array.enumerated() {
                let key = "•"
                readKeyValue(key: key, value: value, holder: &holder)
            }
        }
        
        func readDict(dict: [String: Any], holder: inout [PGDebuggableData]) {
            let keys = dict.keys.sorted { $1 > $0 }
            for key in keys {
                let value = dict[key]
                readKeyValue(key: key, value: value, holder: &holder)
            }
        }
        var modules: [PGDebuggableData] = []
        if let dict = plistOutput as? [String: Any] {
            readDict(dict: dict, holder: &modules)
        } else if let array = plistOutput as? [Any] {
            readArray(array: array, holder: &modules)
        }
        return modules
    }
    
    static func dictionary(from modules: [PGDebuggableData]) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        func readIntoDictionary(modules: [PGDebuggableData], holder: inout [String: Any]) {
            for module in modules {
                if let m = module as? PGString { holder[m.key] = m.value as Any? }
                if let m = module as? PGNumber { holder[m.key] = m.value }
                if let m = module as? PGDate { holder[m.key] = m.value }
                if let m = module as? PGBoolean { holder[m.key] = m.value as Any? }
                if let m = module as? PGDictionary {
                    var holderDict: [String: Any] = [:]
                    readIntoDictionary(modules: m.value, holder: &holderDict)
                    holder[m.key] = holderDict as Any?
                }
                if let m = module as? PGArray {
                    var holderArray: [Any] = []
                    readIntoArray(modules: m.value, holder: &holderArray)
                    holder[m.key] = holderArray as Any?
                }
            }
        }
        
        func readIntoArray(modules: [PGDebuggableData], holder: inout [Any]) {
            for module in modules {
                if let m = module as? PGString { holder.append(m.value as Any) }
                if let m = module as? PGNumber { holder.append(m.value) }
                if let m = module as? PGDate { holder.append(m.value) }
                if let m = module as? PGBoolean { holder.append(m.value as Any) }
                if let m = module as? PGDictionary {
                    var holderDict: [String: Any] = [:]
                    readIntoDictionary(modules: m.value, holder: &holderDict)
                    holder.append(holderDict as Any)
                }
                if let m = module as? PGArray {
                    var holderArray: [Any] = []
                    readIntoArray(modules: m.value, holder: &holderArray)
                    holder.append(holderArray as Any)
                }
            }
        }
        
        readIntoDictionary(modules: modules, holder: &dictionary)
        return dictionary
    }
    
}
