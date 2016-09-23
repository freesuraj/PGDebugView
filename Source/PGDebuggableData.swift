//
//  PGDebuggableData.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 28/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

/// Debuggable data
protocol PGDebuggableData {
    var tableCellType: PGDebuggableCell.Type { get }
    var shouldHighlight: Bool { get }
}

extension PGDebuggableData {
    
    func dequeueCell(from tableView: UITableView, at: IndexPath) -> UITableViewCell {
        if tableView.dequeueReusableCell(withIdentifier: tableCellType.identifier) == nil {
            tableCellType.registerFor(tableView: tableView)
        }
        return tableView.dequeueReusableCell(withIdentifier: tableCellType.identifier, for: at)
    }
    
    func paint(cell: UITableViewCell) {
        guard let paintableCell = cell as? PGDebuggableCell else { return }
        paintableCell.paint(with: self)
    }
    
    func cellUpdateBlock(_ cell: UITableViewCell) -> ((Any?) -> Void)? {
        guard let paintableCell = cell as? PGDebuggableCell else { return nil }
        return paintableCell.didUpdateValue
    }
    
    func willUpdate(with value: Any?) -> PGDebuggableData {
        if var dataType = self as? PGArray {
            guard let value = value as? [PGDebuggableData] else { return self }
            dataType.value = value
            return dataType
        }
        if var dataType = self as? PGDictionary {
            guard let value = value as? [PGDebuggableData] else { return self }
            dataType.value = value
            return dataType
        }
        if var dataType = self as? PGString {
            guard let value = value as? String else { return self }
            dataType.value = value
            return dataType
        }
        if var dataType = self as? PGNumber {
            guard let value = value as? String,
                let numberValue = NumberFormatter().number(from: value) else { return self }
            dataType.value = numberValue
            return dataType
        }
        if var dataType = self as? PGDate {
            guard let value = value as? String,
                let dataeValue = DateFormatter().date(from: value) else { return self }
            dataType.value = dataeValue
            return dataType
        }
        if var dataType = self as? PGBoolean {
            guard let value = value as? Bool else { return self }
            dataType.value = value
            return dataType
        }
        return self
    }
}

/// Debuggable Cell
protocol PGDebuggableCell {
    static var identifier: String { get }
    func paint(with cellModule: PGDebuggableData)
    var didUpdateValue: ((Any?) -> Void)? { get set }
    static func registerFor(tableView: UITableView)
}

extension PGDebuggableCell where Self: UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    static func registerFor(tableView: UITableView) {
        let nib = UINib(nibName: self.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: self.identifier)
    }
}

// MARK:- Data types
struct PGArray: PGDebuggableData {
    var key: String
    var value: [PGDebuggableData]
    var shouldHighlight: Bool { return true }
    var tableCellType: PGDebuggableCell.Type { return PGHeaderCell.self }
}

struct PGDictionary: PGDebuggableData {
    var key: String
    var value: [PGDebuggableData]
    var shouldHighlight: Bool { return true }
    var tableCellType: PGDebuggableCell.Type { return PGHeaderCell.self }
    
    init(key: String, value: [PGDebuggableData]) {
        self.key = key
        self.value = value
    }
}

struct PGBoolean: PGDebuggableData {
    var key: String
    var value: Bool
    var shouldHighlight: Bool { return false }
    var tableCellType: PGDebuggableCell.Type { return PGBooleanCell.self }
}

struct PGString: PGDebuggableData {
    var key: String
    var value: String
    var shouldHighlight: Bool { return false }
    var tableCellType: PGDebuggableCell.Type { return PGStringCell.self }
}

struct PGNumber: PGDebuggableData {
    var key: String
    var value: NSNumber
    var shouldHighlight: Bool { return false }
    var tableCellType: PGDebuggableCell.Type { return PGStringCell.self }
}

struct PGDate: PGDebuggableData {
    var key: String
    var value: Date
    var shouldHighlight: Bool { return false }
    var tableCellType: PGDebuggableCell.Type { return PGStringCell.self }
}
