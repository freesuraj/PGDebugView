//
//  PGDebugCustomCells.swift
//  PGDebugView
//
//  Created by Suraj Pathak on 30/5/16.
//  Copyright © 2016 Suraj Pathak. All rights reserved.
//

import UIKit

final class PGStringCell: UITableViewCell, PGDebuggableCell, UITextFieldDelegate {
    let nameLabel: UILabel = UILabel()
    let valueTextField: UITextField = UITextField()
    
    var didUpdateValue: (Any? -> Void)?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(valueTextField)
        nameLabel.textColor = UIColor.darkTextColor()
        nameLabel.font = UIFont.systemFontOfSize(14.0)
        nameLabel.minimumScaleFactor = 0.7
        nameLabel.numberOfLines = 0
        valueTextField.addEmptyRightView(18.0)
        valueTextField.delegate = self
        valueTextField.backgroundColor = UIColor.clearColor()
        valueTextField.textAlignment = .Right
        valueTextField.font = UIFont.systemFontOfSize(13.0)
        setNeedsUpdateConstraints()
    }
    
    static func registerFor(tableView tableView: UITableView) {
        tableView.registerClass(PGStringCell.self, forCellReuseIdentifier: self.identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let block = didUpdateValue {
            block(textField.text)
        }
    }
    
    func paint(with cellModule: PGDebuggableData) {
        if let module = cellModule as? PGString {
            nameLabel.text = module.key
            valueTextField.text = module.value
            valueTextField.keyboardType = .Default
        } else if let module = cellModule as? PGNumber {
            nameLabel.text = module.key
            valueTextField.text = "\(module.value)"
            valueTextField.keyboardType = .NumberPad
        } else if let module = cellModule as? PGDate {
            nameLabel.text = module.key
            valueTextField.text = "\(module.value)"
            valueTextField.keyboardType = .NumbersAndPunctuation
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: AnyObject] = ["name": nameLabel, "value": valueTextField]
        let metrics: [String: CGFloat] = [:]
        var allConstraints: [NSLayoutConstraint] = []
        func addConstr(format: String) {
            allConstraints += NSLayoutConstraint.constraintsWithVisualFormat(format, options: [], metrics: metrics, views: views)
        }
        
        addConstr("H:|-[name(==value)]-[value]|")
        addConstr("V:|[name(>=44)]")
        addConstr("V:|[value(==name)]")
        NSLayoutConstraint.activateConstraints(allConstraints)
    }
}

extension UITextField {
    func addEmptyRightView(margin: CGFloat) {
        let rightView = UIView(frame: CGRect(origin: CGPointZero, size: CGSize(width: margin, height: 1)))
        rightView.backgroundColor = UIColor.clearColor()
        self.rightView = rightView
        self.rightViewMode = .Always
    }
}
