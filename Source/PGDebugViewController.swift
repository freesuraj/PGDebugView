//
//  DebugViewController.swift
//  PropertyGuruSG
//
//  Created by Suraj Pathak on 26/5/16.
//
//

import UIKit

public class PGDebugViewController: UIViewController {
    
    let tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
    var didUpdateCellModules: (([PGDebuggableData]) -> Void)?
    var readOnlyMode: Bool = false
    var cellModules: [PGDebuggableData] = [] {
        didSet {
            if let block = didUpdateCellModules {
                block(cellModules)
            }
        }
    }
    var plistPath: String?
    var plistObject: Any?
    public var exportFilename: String = "debug"
    public var exportFolderName: String = "DEBUG-PLIST"
    public var didFinishExport: ((Bool, URL?) -> Void)?
	public var shouldExit: ((Void) -> Void)?
    
    
    public convenience init(plistPath: String, readOnly: Bool = false) {
        self.init()
        self.plistPath = plistPath
        self.readOnlyMode = readOnly
    }
    
    public convenience init(plistObject: Any, readOnly: Bool = false) {
        self.init()
        self.plistObject = plistObject
        self.readOnlyMode = readOnly
    }
    
    convenience init(cellModules: [PGDebuggableData]) {
        self.init()
        self.cellModules = cellModules
    }
    
    static func debugVC(_ title: String?, cellModules: [PGDebuggableData]) -> PGDebugViewController? {
        let vc = PGDebugViewController()
        vc.cellModules = cellModules
        vc.title = title
        return vc
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.frame
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(self.tableView)
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.keyboardDismissMode = .onDrag
        if cellModules.count == 0 { loadFromPlistFile() }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
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
        	self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(exitDebugView))
        }
    }
    
    func updateRightNavigationButtons() {
        let editTitle = tableView.isEditing ? "Done" : "Edit"
        let editStyle = tableView.isEditing ? UIBarButtonItemStyle.done : UIBarButtonItemStyle.plain
        let editButton = UIBarButtonItem(title: editTitle, style: editStyle, target: self, action: #selector(toggleEdit))
        var rightButtons = [editButton]
        if tableView.isEditing {
            let addButton = UIBarButtonItem(title: "✚", style: .plain, target: self, action: #selector(openJsonEditor))
            rightButtons.append(addButton)
        }
        if self.navigationController?.viewControllers.count == 1 && !tableView.isEditing {
            let exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportPlist))
            rightButtons.append(exportButton)
        }
        self.navigationItem.rightBarButtonItems = rightButtons
    }
    
    // MARK: UITableView Action
    
    func toggleEdit() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        updateRightNavigationButtons()
    }
    
    func exitDebugView() {
        if let block = shouldExit { block() }
    }
    
    func openJsonEditor() {
        let editVc = PGDebugEditViewController()
        editVc.textDidUpdate = { [weak self] json in
            let modules = PGPlistReader(object: json).read()
            self?.cellModules.append(contentsOf: modules)
            self?.tableView.reloadData()
        }
        self.navigationController?.pushViewController(editVc, animated: true)
    }
    
    func exportPlist() {
        let dict = PGPlistReader.dictionary(from: cellModules)
        let exportResult = PGDebugExport.export(dictionary: dict, folderName: exportFolderName, plistFile: exportFilename)
        if let block = didFinishExport {
            block(exportResult.0, exportResult.1 as URL?)
        }
        
        print("\(exportResult.0)\n\(exportResult.1)")
    }
    
    func selectModule(at index: Int) {
        func present(_ title: String, modules: [PGDebuggableData]) {
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
        cellModules.remove(at: index)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .bottom)
        tableView.endUpdates()
    }
    
    func moveModule(from: Int, to: Int) {
        let temp = cellModules[to]
        cellModules[to] = cellModules[from]
        cellModules[from] = temp
    }
    
    func updateModule(_ module: PGDebuggableData, at index: Int, with newValue: Any?) {
        cellModules[index] = module.willUpdate(with: newValue)
    }
}

    // MARK: UITableViewDataSource, UITableViewDelegate
extension PGDebugViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModules.count
    }
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let module = cellModules[(indexPath as NSIndexPath).row]
        let cell = module.dequeueCell(from: tableView, at: indexPath)
        if var c = cell as? PGDebuggableCell {
            c.didUpdateValue = { [weak self] value in
                self?.updateModule(module, at: (indexPath as NSIndexPath).row, with: value)
            }
        }
        module.paint(cell: cell)
        return cell
    }
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return cellModules[(indexPath as NSIndexPath).row].shouldHighlight
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectModule(at: (indexPath as NSIndexPath).row)
    }
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteModule(at: (indexPath as NSIndexPath).row)
        }
    }
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveModule(from: (sourceIndexPath as NSIndexPath).row, to: (destinationIndexPath as NSIndexPath).row)
    }
}
