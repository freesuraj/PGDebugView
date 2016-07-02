//
//  DebugViewController.swift
//  PropertyGuruSG
//
//  Created by Suraj Pathak on 26/5/16.
//
//

import UIKit

public final class PGDebugViewController: UIViewController {
    
    let tableView: UITableView = UITableView(frame: CGRectZero, style: .Grouped)
    var didUpdateCellModules: ([PGDebuggableData] -> Void)?
    var readOnlyMode: Bool = false
    var cellModules: [PGDebuggableData] = [] {
        didSet {
            if let block = didUpdateCellModules {
                block(cellModules)
            }
        }
    }
    var plistPath: String?
    var plistObject: AnyObject?
    public var exportFilename: String = "debug"
    public var didFinishExport: ((Bool, NSURL?) -> Void)?
	public var shouldExit: (Void -> Void)?
    
    public convenience init(plistPath: String, readOnly: Bool = false) {
        self.init()
        self.plistPath = plistPath
        self.readOnlyMode = readOnly
    }
    
    public convenience init(plistObject: AnyObject, readOnly: Bool = false) {
        self.init()
        self.plistObject = plistObject
        self.readOnlyMode = readOnly
    }
    
    convenience init(cellModules: [PGDebuggableData]) {
        self.init()
        self.cellModules = cellModules
    }
    
    static func debugVC(title: String?, cellModules: [PGDebuggableData]) -> PGDebugViewController? {
        let vc = PGDebugViewController()
        vc.cellModules = cellModules
        vc.title = title
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(self.tableView)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.keyboardDismissMode = .OnDrag
        if cellModules.count == 0 { loadFromPlistFile() }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateLeftNavigationButtons()
        if !readOnlyMode { updateRightNavigationButtons() }
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadFromPlistFile() {
        if let path = plistPath {
            cellModules = PGPlistReader(path: path).read()
            tableView.reloadData()
        } else if let object = plistObject {
            cellModules = PGPlistReader(object: object).read()
            tableView.reloadData()
        }
    }
    
    func updateLeftNavigationButtons() {
        if self.navigationController?.viewControllers.count == 1 {
        	self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .Plain, target: self, action: #selector(exitDebugView))
        }
    }
    
    func updateRightNavigationButtons() {
        let editTitle = tableView.editing ? "Done" : "Edit"
        let editStyle = tableView.editing ? UIBarButtonItemStyle.Done : UIBarButtonItemStyle.Plain
        let editButton = UIBarButtonItem(title: editTitle, style: editStyle, target: self, action: #selector(toggleEdit))
        var rightButtons = [editButton]
        if tableView.editing {
            let addButton = UIBarButtonItem(title: "✚", style: .Plain, target: self, action: #selector(openJsonEditor))
            rightButtons.append(addButton)
        }
        if self.navigationController?.viewControllers.count == 1 && !tableView.editing {
            let exportButton = UIBarButtonItem(title: "Export", style: .Plain, target: self, action: #selector(exportPlist))
            rightButtons.append(exportButton)
        }
        self.navigationItem.rightBarButtonItems = rightButtons
    }
    
    // MARK: UITableView Action
    
    func toggleEdit() {
        tableView.setEditing(!tableView.editing, animated: true)
        updateRightNavigationButtons()
    }
    
    func exitDebugView() {
        if let block = shouldExit { block() }
    }
    
    func openJsonEditor() {
        let editVc = PGDebugEditViewController()
        editVc.textDidUpdate = { [weak self] json in
            let modules = PGPlistReader(object: json).read()
            self?.cellModules.appendContentsOf(modules)
            self?.tableView.reloadData()
        }
        self.navigationController?.pushViewController(editVc, animated: true)
    }
    
    func exportPlist() {
        let dict = PGPlistReader.dictionary(from: cellModules)
        let exportResult = PGPlistReader.export(dictionary: dict, plistFile: exportFilename)
        if let block = didFinishExport {
            block(exportResult.0, exportResult.1)
        }
        print("\(exportResult.0)\n\(exportResult.1)")
    }
    
    func selectModule(at index: Int) {
        func present(title: String, modules: [PGDebuggableData]) {
            let debugVC = PGDebugViewController(cellModules: modules)
            debugVC.title = title
            debugVC.readOnlyMode = self.readOnlyMode
            debugVC.didUpdateCellModules = { [weak self] updates in
                if let module = self?.cellModules[index] {
                    self?.updateModule(module, at: index, with: updates)
                }
            }
            self.navigationController?.pushViewController(debugVC, animated: true)
        }
        if let moduleArray = cellModules[index] as? PGArray {
            present(moduleArray.key, modules: moduleArray.value)
        } else if let moduleDict = cellModules[index] as? PGDictionary {
            present(moduleDict.key, modules: moduleDict.value)
        }
    }
    
    func deleteModule(at index: Int) {
        cellModules.removeAtIndex(index)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Bottom)
        tableView.endUpdates()
    }
    
    func moveModule(from from: Int, to: Int) {
        let temp = cellModules[to]
        cellModules[to] = cellModules[from]
        cellModules[from] = temp
    }
    
    func updateModule(module: PGDebuggableData, at index: Int, with newValue: Any?) {
        cellModules[index] = module.willUpdate(with: newValue)
    }
}

    // MARK: UITableViewDataSource, UITableViewDelegate
extension PGDebugViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModules.count
    }
    public func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let module = cellModules[indexPath.row]
        let cell = module.dequeueCell(from: tableView, at: indexPath)
        if var c = cell as? PGDebuggableCell {
            c.didUpdateValue = { [weak self] value in
                self?.updateModule(module, at: indexPath.row, with: value)
            }
        }
        module.paint(cell: cell)
        return cell
    }
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return cellModules[indexPath.row].shouldHighlight
    }
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectModule(at: indexPath.row)
    }
    public func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteModule(at: indexPath.row)
        }
    }
    public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        moveModule(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}
