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
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(toggle)
        toggle.addTarget(self, action: #selector(didChangeValue(_:)), for: .valueChanged)
        nameLabel.textColor = UIColor.darkText
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        nameLabel.minimumScaleFactor = 0.7
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    static func registerFor(tableView: UITableView) {
        tableView.register(PGBooleanCell.self, forCellReuseIdentifier: self.identifier)
    }
    
    func didChangeValue(_ sender: UISwitch) {
        if let block = didUpdateValue {
            block(sender.isOn)
        }
    }
    
    var didUpdateValue: ((Any?) -> Void)?
    func paint(with cellModule: PGDebuggableData) {
        if let module = cellModule as? PGBoolean {
            nameLabel.text = module.key
            toggle.isOn = module.value
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        toggle.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["name": nameLabel, "value": toggle]
        let metrics: [String: CGFloat] = [:]
        var allConstraints: [NSLayoutConstraint] = []
        func addConstr(_ format: String) {
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: metrics, views: views)
        }
        addConstr("V:|[name(>=44)]")
        allConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[name]-[value(==64)]-8-|", options: [.alignAllCenterY], metrics: metrics, views: views)
        NSLayoutConstraint.activate(allConstraints)
    }
}
