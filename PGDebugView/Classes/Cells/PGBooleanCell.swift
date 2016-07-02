//
//  PGBooleanCell.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 30/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

final class PGBooleanCell: UITableViewCell, PGDebuggableCell {
    let nameLabel: UILabel = UILabel()
    let toggle: UISwitch = UISwitch()
    
    func didChangeValue(sender: UISwitch) {
        if let block = didUpdateValue {
            block(sender.on)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(toggle)
        toggle.addTarget(self, action: #selector(didChangeValue), forControlEvents: .ValueChanged)
        nameLabel.textColor = UIColor.darkTextColor()
        nameLabel.font = UIFont.systemFontOfSize(14.0)
        nameLabel.minimumScaleFactor = 0.7
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    static func registerFor(tableView tableView: UITableView) {
        tableView.registerClass(PGBooleanCell.self, forCellReuseIdentifier: self.identifier)
    }
    
    var didUpdateValue: (Any? -> Void)?
    func paint(with cellModule: PGDebuggableData) {
        if let module = cellModule as? PGBoolean {
            nameLabel.text = module.key
            toggle.on = module.value
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = ["name": nameLabel, "value": toggle]
        let metrics: [String: CGFloat] = [:]
        var allConstraints: [NSLayoutConstraint] = []
        func addConstr(format: String) {
            allConstraints += NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: metrics, views: views)
        }
        addConstr("V:|[name(>=44)]")
        allConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[name]-[value(==64)]-8-|", options: [.AlignAllCenterY], metrics: metrics, views: views)
        NSLayoutConstraint.activateConstraints(allConstraints)
    }
}