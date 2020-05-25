//
//  RemindListViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/21.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults
import Alamofire
import Repeat

class RemindListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSMenuDelegate {

    @IBOutlet weak var tableView: NSTableView!
    
    var timer: Repeater?
    var stockList: [StockModel] = []
    
    var setRemindWindowController: NSWindowController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        tableView.menu = NSMenu(title: "Context Menu")
        tableView.menu?.delegate = self
        
        for item in Defaults[.remindList] {
            let model = StockModel()
            model.code = item.stockCode
            self.stockList.append(model)
        }
        
        self.timer = Repeater(interval: .seconds(2), mode: .infinite) { _ in
            // do something
            self.requestRemindStockInfo()
        }
        
        self.timer?.start()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        print("通知管理 timer stop")
        self.timer?.pause()
    }
    
    func requestRemindStockInfo() {
        if Defaults[.remindList].count == 0 {
            return
        }
        
        print("通知管理timer")
        var codeList: [String] = []
        for item in Defaults[.remindList] {
            codeList.append(item.stockCode)
        }
        
        let param = codeList.joined(separator: ",")
        let urlString = Constants.api_endPoint + param
        
        Alamofire.request(urlString).response { response in
            if let data = response.data, let text = String(gbkData:data){
                //print(text)
                var array = text.components(separatedBy: ";")
                array.removeLast()
                
                self.stockList.removeAll()
                for item in array {
                    let model = StockModel(string: item)
                    self.stockList.append(model)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Defaults[.remindList].count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let identifier = (tableColumn?.identifier)!
        var result:NSTableCellView
        result  = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        let remindModel = Defaults[.remindList][row]
        let stockModel = self.stockList[row]
        
        switch identifier.rawValue {
        case "name":
            result.textField?.stringValue = stockModel.name
        case "nowPrice":
            result.textField?.stringValue = String(format: "%.2f", stockModel.nowPrice)
            if stockModel.pricedelta > 0 {
                result.textField?.textColor = NSColor.red
            } else if stockModel.percent == 0 {
                result.textField?.textColor = NSColor.gray
            } else {
                result.textField?.textColor = NSColor.green
            }
        case "rise":
            result.textField?.stringValue = String(format: "%.2f", remindModel.risePrice)
        case "fall":
            result.textField?.stringValue = String(format: "%.2f", remindModel.fallPrice)
        default:
            break
        }
        return result
    }
    
    
    //pragma mark tableview menu delegates
    func menuNeedsUpdate(_ menu: NSMenu) {
        // get the row/column from the NSTableView (or a subclasse, as here, an NSOutlineView)
        let row = tableView.clickedRow
        let col = tableView.clickedColumn
        if row < 0 || col < 0 {
            return
        }
        let newItems = constructMenuForRow(row, andColumn: col)
        menu.removeAllItems()
        for item in newItems {
            menu.addItem(item)
            // target this object for handling the actions
            item.target = self
        }
    }
    
    func constructMenuForRow(_ row: Int, andColumn column: Int) -> [NSMenuItem] {
        let menuItemSeparator = NSMenuItem.separator()
        
        let menuItemEdit = NSMenuItem(title: "编辑", action: #selector(editRemind(_:)), keyEquivalent: "")
        menuItemEdit.representedObject = row
        let menuItemDelete = NSMenuItem(title: "删除", action: #selector(deleteRemind(_:)), keyEquivalent: "")
        menuItemDelete.representedObject = row
        return [menuItemEdit, menuItemSeparator, menuItemDelete]
    }
    
    @objc func editRemind(_ sender: NSMenuItem) {
        if setRemindWindowController != nil {
            setRemindWindowController.close()
        }
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("setRemindWindow")
        //3.
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Why cant i find setRemindWindow? - Check Main.storyboard")
        }
        setRemindWindowController = windowController
        
        let viewController = setRemindWindowController.contentViewController as! SetNotificationViewController
        if let row = sender.representedObject as? Int {
            viewController.stockModel = self.stockList[row]
        }
        setRemindWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func deleteRemind(_ sender: NSMenuItem) {
        if let row = sender.representedObject as? Int {
            self.timer?.pause()
            
            let model = Defaults[.remindList][row]
            RemindManager.shared.removeRemind(code: model.stockCode)
            
            tableView.beginUpdates()
            let indexSet = IndexSet(integer:row)
            tableView.removeRows(at: indexSet, withAnimation: .effectFade)
            tableView.endUpdates()
            
            self.timer?.start()
        }
    }
}
