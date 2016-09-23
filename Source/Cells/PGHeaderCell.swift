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
    
    var didUpdateValue: ((Any?) -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        nameLabel.font = UIFont.systemFont(ofSize: 14.0)
        nameLabel.textColor = UIColor.darkText
        self.accessoryType = .disclosureIndicator
        setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func registerFor(tableView: UITableView) {
        tableView.register(PGHeaderCell.self, forCellReuseIdentifier: self.identifier)
    }
    override func updateConstraints() {
        super.updateConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: Any] = ["name": nameLabel]
        let metrics: [String: CGFloat] = [:]
        var allConstraints: [NSLayoutConstraint] = []
        func addConstr(_ format: String) {
            allConstraints += NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: metrics, views: views)
        }
        addConstr("V:|[name(>=44)]")
        addConstr("H:|-[name]-|")
        NSLayoutConstraint.activate(allConstraints)
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
