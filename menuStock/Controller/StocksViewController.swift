//
//  StocksViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/18.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyUserDefaults
import LaunchAtLogin

class StocksViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate,  NSUserNotificationCenterDelegate{

    @IBOutlet weak var tableView: NSTableView!
    var modelArray: [StockModel] = []
    var timer: Timer?
    
    var addStockWindowController: NSWindowController!
    var setRemindWindowController: NSWindowController!
    var remindListWindowController: NSWindowController!
    var stockDetailWindowController: NSWindowController!
    var contactMeWindowController: NSWindowController!
    
    
    @IBOutlet weak var pinButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        if Defaults[.pinPopover] {
            pinButton.image = NSImage(named: NSImage.Name("pin-2"))
        } else {
            pinButton.image = NSImage(named: NSImage.Name("pin-1"))
        }
            
        tableView.rowHeight = 20
        tableView.menu = NSMenu(title: "context menu")
        tableView.menu?.delegate = self

        tableView.registerForDraggedTypes([NSPasteboard.PasteboardType.string])
        let sharedTimer = TimerManager.shared
        sharedTimer.createTimer {
            self.requestData()
        }
        sharedTimer.start()
        
        //start notification timer
        NotificationTimer.shared.start {
            self.requestRemindStockInfo()
        }
    }
    
    func requestData() {
        if Defaults[.stockList].count == 0 {
            return
        }
        
        print("自选股票列表timer")
        let param = Defaults[.stockList].joined(separator: ",")
        let urlString = Constants.api_endPoint + param
        
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            if let data = response.data, let text = String(gbkData:data){
                //print(text)
                var array = text.components(separatedBy: ";")
                array.removeLast()
        
                self.modelArray.removeAll()
                for item in array {
                    let model = StockModel(string: item)
                    self.modelArray.append(model)
                }
                //self.tableView.reloadData()
                self.tableView.reloadDataKeepingSelection()
            }
        }
    }
    
    func requestRemindStockInfo() {
        if Defaults[.remindList].count == 0 {
            return
        }
        
        var codeList: [String] = []
        for item in Defaults[.remindList] {
            if item.checkRisePrice || item.checkFallPrice {
                codeList.append(item.stockCode)
            }
        }
        
        if codeList.count == 0 {
            return
        }
        
        print("通知timer")
        
        let param = codeList.joined(separator: ",")
        let urlString = Constants.api_endPoint + param
        
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            if let data = response.data, let text = String(gbkData:data){
                //print(text)
                var array = text.components(separatedBy: ";")
                array.removeLast()
                
                for item in array {
                    let model = StockModel(string: item)
                    if let remindModel = RemindManager.shared.queryRemind(code: model.code) {
                        if model.nowPrice > 0 {
                            if model.nowPrice >= remindModel.risePrice && remindModel.checkRisePrice && remindModel.risePrice != 0 {
                                let nowTime = self.getNowTime()
                                let message = String(format: "%@ 最新价%.2f元，上涨达到您设置的%.2f元", nowTime, model.nowPrice, remindModel.risePrice)
                                
                                self.showNotification(title: model.name, message: message)
                                //RemindManager.shared.removeRemind(code: model.code)
                                remindModel.checkRisePrice = false
                                RemindManager.shared.updateRemind(model: remindModel)
                                continue
                            }
                            
                            if model.nowPrice <= remindModel.fallPrice && remindModel.checkFallPrice && remindModel.fallPrice != 0 {
                                let nowTime = self.getNowTime()
                                let message = String(format: "%@ 最新价%.2f元，下跌达到您设置的%.2f元", nowTime, model.nowPrice, remindModel.fallPrice)
                                
                                self.showNotification(title: model.name, message: message)
                                //RemindManager.shared.removeRemind(code: model.code)
                                remindModel.checkFallPrice = false
                                RemindManager.shared.updateRemind(model: remindModel)
                                continue
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNowTime() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"
        return dateFormatterGet.string(from: Date())
    }
    
    func showNotification(title:String,  message: String) {
        // Create the notification and setup information
        let notification = NSUserNotification()
        notification.title = title
        notification.subtitle = message
        notification.soundName = NSUserNotificationDefaultSoundName
        // Manually display the notification
        let notificationCenter = NSUserNotificationCenter.default
        notificationCenter.delegate = self
        notificationCenter.deliver(notification)
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool{
        return true
    }
    
    @IBAction func addStock(_ sender: Any) {
        
        if addStockWindowController != nil {
            addStockWindowController.close()
        }
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("AddStockWindow")
        //3.
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Why cant i find AddStockWindow? - Check Main.storyboard")
        }
        addStockWindowController = windowController
        addStockWindowController.showWindow(self)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    

    func numberOfRows(in tableView: NSTableView) -> Int {
        return modelArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        
        let identifier = (tableColumn?.identifier)!
        var result:NSTableCellView
        result  = tableView.makeView(withIdentifier: identifier, owner: self) as! NSTableCellView
        let model = self.modelArray[row]
        switch identifier.rawValue {
        case "name":
            result.textField?.stringValue = model.name
//            if Defaults[.followStockList].contains(model.code) {
//                result.textField?.textColor = .white
//            } else {
//                result.textField?.textColor = .textColor
//            }
        case "nowPrice":
            result.textField?.stringValue = String(format: "%.2f", model.nowPrice)
            if model.pricedelta > 0 {
                result.textField?.textColor = NSColor.red
            } else if model.percent == 0 {
                result.textField?.textColor = NSColor.gray
            } else {
                result.textField?.textColor = NSColor.green
            }
        case "pricedelta":
            if model.pricedelta > 0 {
                result.textField?.textColor = NSColor.red
                result.textField?.stringValue = String(format: "+%.2f", model.pricedelta)
            } else if model.percent == 0 {
                result.textField?.textColor = NSColor.gray
                result.textField?.stringValue = String(format: "%.2f", model.pricedelta)
            } else {
              result.textField?.textColor = NSColor.green
              result.textField?.stringValue = String(format: "%.2f", model.pricedelta)
            }
        case "percent":
            if model.percent > 0 {
                result.textField?.textColor = NSColor.red
                result.textField?.stringValue = String(format: "+%.2f%%", model.percent)
            } else if model.percent == 0 {
                result.textField?.textColor = NSColor.gray
                result.textField?.stringValue = String(format: "%.2f%%", model.percent)
            } else {
                result.textField?.textColor = NSColor.green
                result.textField?.stringValue = String(format: "%.2f%%", model.percent)

            }
        default:
            break
        }
        
        return result
    }
    

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        let model = self.modelArray[row]
        if Defaults[.followStockList].contains(model.code) {
            if NSAppearance.current.isDarkMode {
                rowView.backgroundColor = NSColor.init(red: 105/255.0, green: 105/255.0, blue: 105/255.0, alpha: 1.0)
                //rgba(105,105,105 ,1)
            } else {
                //rgba(220,220,220 ,1)
                rowView.backgroundColor = NSColor.init(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1.0)
            }
        }
    }
    
    // For the source table view
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {

        let model = self.modelArray[row]
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(model.code, forType: NSPasteboard.PasteboardType.string)
        return pasteboardItem
    }
    
    // For the destination table view
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            TimerManager.shared.pause()
            return .move
        } else {
            return []
        }
    }
    
    // For the destination table view
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard.pasteboardItems?.first,
            let theString = item.string(forType: NSPasteboard.PasteboardType.string),
            let model = modelArray.first(where: { $0.code == theString }),
            let originalRow = modelArray.firstIndex(of: model)
            else { return false }
        
        var newRow = row
        // When you drag an item downwards, the "new row" index is actually --1. Remember dragging operation is `.above`.
        if originalRow < newRow {
            newRow = row - 1
        }
        
        // Animate the rows
        tableView.beginUpdates()
        tableView.moveRow(at: originalRow, to: newRow)
        tableView.endUpdates()
        
        // Persist the ordering by saving your data model
        saveModelsReordered(at: originalRow, to: newRow)
        
        TimerManager.shared.start()
        return true
    }
    
    func saveModelsReordered(at: Int, to: Int) {
        
        //let array = Defaults[.stockList]
       // Defaults[.stockList].swapAt(at, to)
        
        let element = Defaults[.stockList].remove(at: at)
        Defaults[.stockList].insert(element, at: to)
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
        let menuItemSeparator1 = NSMenuItem.separator()
        let menuItemSeparator2 = NSMenuItem.separator()
        let menuItemSeparator3 = NSMenuItem.separator()

        let menuItemAddNotification = NSMenuItem(title: "设置提醒", action: #selector(addNotification(_:)), keyEquivalent: "")
        menuItemAddNotification.representedObject = row
        
        var menuTitle = "关注"
        let model = self.modelArray[row]
        if Defaults[.followStockList].contains(model.code) {
            menuTitle = "取消关注"
        }
        
        let menuItemFollow = NSMenuItem(title: menuTitle, action: #selector(followOrUnfollowStock(_:)), keyEquivalent: "")
        menuItemFollow.representedObject = row
        
        let menuItemDetail = NSMenuItem(title: "详情", action: #selector(stockDetail(_:)), keyEquivalent: "")
        menuItemDetail.representedObject = row
        let menuItemDelete = NSMenuItem(title: "删除", action: #selector(deleteStock(_:)), keyEquivalent: "")
        menuItemDelete.representedObject = row
        return [menuItemAddNotification, menuItemSeparator1, menuItemFollow, menuItemSeparator2, menuItemDetail, menuItemSeparator3, menuItemDelete]
    }
    
    @objc func addNotification(_ sender: NSMenuItem) {
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
            viewController.stockModel = self.modelArray[row]
        }
        setRemindWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func stockDetail(_ sender: NSMenuItem) {
        if stockDetailWindowController != nil {
            stockDetailWindowController.close()
        }
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("stockDetailWindow")
        //3.
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Why cant i find stockDetailWindow? - Check Main.storyboard")
        }
        stockDetailWindowController = windowController
        
        let viewController = stockDetailWindowController.contentViewController as! StockDetailViewController
        if let row = sender.representedObject as? Int {
            viewController.stockModel = self.modelArray[row]
        }
        stockDetailWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func deleteStock(_ sender: NSMenuItem) {
        if let row = sender.representedObject as? Int {
            TimerManager.shared.pause()
            
            let model = self.modelArray[row]
            StockManager.shared.removeStock(code: model.code)
            RemindManager.shared.removeRemind(code: model.code)
            
            tableView.beginUpdates()
            let indexSet = IndexSet(integer:row)
            tableView.removeRows(at: indexSet, withAnimation: .effectFade)
            tableView.endUpdates()
            
            TimerManager.shared.start()
        }
    }
    
    @objc func followOrUnfollowStock(_ sender: NSMenuItem) {
        if let row = sender.representedObject as? Int {
            TimerManager.shared.pause()
            
            let model = self.modelArray[row]
            if Defaults[.followStockList].contains(model.code) {
                //unfollow
                Defaults[.followStockList] = Defaults[.followStockList].filter { (item) -> Bool in
                    return item != model.code
                }
            } else {
                //follow
                Defaults[.followStockList].append(model.code)
                
            }
            self.tableView.reloadData()
            
            TimerManager.shared.start()
        }
    }
    
    @IBAction func showRemindListView(_ sender: Any) {
        if remindListWindowController != nil {
            remindListWindowController.close()
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("remindListWindow")
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Why cant i find remindListWindow? - Check Main.storyboard")
        }
        remindListWindowController = windowController
        remindListWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func settingButtonAction(_ sender: Any) {
        let menu = NSMenu(title: "Setting Menu")
        let menuItemLauchAtLogin = NSMenuItem(title: "开机启动", action: #selector(toggleLauchAtLogin(_:)), keyEquivalent: "")
        menuItemLauchAtLogin.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(menuItemLauchAtLogin)
        
        let menuItemSeparator1 = NSMenuItem.separator()
        menu.addItem(menuItemSeparator1)
        
        let menuItemRate = NSMenuItem(title: "赏个好评", action: #selector(rate(_:)), keyEquivalent: "")
        menu.addItem(menuItemRate)
        let menuItemContact = NSMenuItem(title: "联系我", action: #selector(showContactMeView(_:)), keyEquivalent: "")
        menu.addItem(menuItemContact)
        let menuItemAbout = NSMenuItem(title: "关于", action: #selector(about(_:)), keyEquivalent: "")
        menu.addItem(menuItemAbout)
        
        let menuItemSeparator2 = NSMenuItem.separator()
        menu.addItem(menuItemSeparator2)
        
        let menuItemQuit = NSMenuItem(title: "退出", action: #selector(quit(_:)), keyEquivalent: "")
        menu.addItem(menuItemQuit)
        
        if let button = sender as? NSButton {
            //button.bezelColor
            if let event = NSApplication.shared.currentEvent {
                NSMenu.popUpContextMenu(menu, with:event , for: button)
            }
        }
    }
    
    @objc func toggleLauchAtLogin(_ sender: Any) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        print(LaunchAtLogin.isEnabled)
    }
    
    @objc func showContactMeView(_ sender: Any) {
        if contactMeWindowController != nil {
            contactMeWindowController.close()
        }
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("contactMeWindow")
        guard let windowController = storyboard.instantiateController(withIdentifier: identifier) as? NSWindowController else {
            fatalError("Why cant i find contactMeWindow? - Check Main.storyboard")
        }
        contactMeWindowController = windowController
        contactMeWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit(_ sender: Any?)  {
        NotificationTimer.shared.pause()
        TimerManager.shared.pause()
        NSApplication.shared.terminate(self)
    }
    
    @objc func sendFeedback(_ sender: Any?) {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["secnettool@gmail.com"]
        service.subject = "StockMini反馈"
        service.perform(withItems: [])
    }
    
    @objc func rate(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "macappstore://itunes.apple.com/app/1457423760")!)
    }
    
    @objc func about(_ sender: Any?) {
        NSApp.orderFrontStandardAboutPanel(sender);
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func pinAction(_ sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }
        
        Defaults[.pinPopover] = !Defaults[.pinPopover]
        if Defaults[.pinPopover] {
            button.image = NSImage(named: NSImage.Name("pin-2"))
        } else {
            button.image = NSImage(named: NSImage.Name("pin-1"))
        }
    }
}


extension StocksViewController {
    // MARK: Storyboard instantiation
    static func freshController() -> StocksViewController {
        //1.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        //2.
        let identifier = NSStoryboard.SceneIdentifier("StocksViewController")
        //3.
        guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? StocksViewController else {
            fatalError("Why cant i find StocksViewController? - Check Main.storyboard")
        }
        return viewcontroller
    }
}
