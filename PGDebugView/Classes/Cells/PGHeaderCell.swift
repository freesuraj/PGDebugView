//
//  PGHeaderCell.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 30/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

final class PGHeaderCell: UITableViewCell, PGDebuggableCell {
    let nameLabel: UILabel = UILabel()
    
    var didUpdateValue: (Any? -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFontOfSize(14.0)
        nameLabel.textColor = UIColor.darkTextColor()
        self.accessoryType = .DisclosureIndicator
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func registerFor(tableView tableView: UITableView) {
        tableView.registerClass(PGHeaderCell.self, forCellReuseIdentifier: self.identifier)
    }
    override func updateConstraints() {
        super.updateConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = ["name": nameLabel]
        let metrics: [String: CGFloat] = [:]
        var allConstraints: [NSLayoutConstraint] = []
        func addConstr(format: String) {
            allConstraints += NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: metrics, views: views)
        }
        addConstr("V:|[name(>=44)]")
        addConstr("H:|-[name]-|")
        NSLayoutConstraint.activateConstraints(allConstraints)
    }
    
    func paint(with cellModule: PGDebuggableData) {
        if let module = cellModule as? PGDictionary {
            nameLabel.text = module.key
        }
        else if let module = cellModule as? PGArray {
            nameLabel.text = module.key
        }
    }
}