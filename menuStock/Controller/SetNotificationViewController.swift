//
//  SetNotificationViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/20.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyUserDefaults
import Repeat

class SetNotificationViewController: NSViewController, NSWindowDelegate, NSTextFieldDelegate {
    var stockModel: StockModel?
    //var stockCode: String?
    
    var nowPrice: Double = 0
    
    @IBOutlet weak var nameLabel: NSTextField!
    
    @IBOutlet weak var priceLabel: NSTextField!
    
    //@IBOutlet weak var percentOffsetTextField: NSTextField!
    @IBOutlet weak var risePriceTextField: NSTextField!
    @IBOutlet weak var fallPriceTextField: NSTextField!
    
    //@IBOutlet weak var percentOffsetCheckbox: NSButton!
    @IBOutlet weak var risePriceCheckbox: NSButton!
    @IBOutlet weak var fallPriceCheckbox: NSButton!
    
    @IBOutlet weak var riseMessageLabel: NSTextField!
    @IBOutlet weak var fallMessageLabel: NSTextField!
    
    
    var timer: Repeater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        //percentOffsetTextField.delegate = self
        risePriceTextField.delegate = self
        fallPriceTextField.delegate = self
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let code = self.stockModel?.code {
            if self.timer == nil {
                self.timer = Repeater(interval: .seconds(2), mode: .infinite) { _ in
                    // do something
                    self.requestData(code: code)
                }
            }
            self.timer?.start()
        }
        self.updateView()
    }
    
    func updateView() {
        guard let model = self.stockModel else {
            return
        }
        
        self.updateStock(model: model)
        
        guard let code = self.stockModel?.code else {
            return
        }
        
        if let index = RemindManager.shared.findRemind(code: code) {
            let model = Defaults[.remindList][index]
            //self.percentOffsetCheckbox.state = model.checkPercentOffset ? .on : .off
            self.risePriceCheckbox.state = model.checkRisePrice ? .on : .off
            self.fallPriceCheckbox.state = model.checkFallPrice ? .on : .off
            
            //self.percentOffsetTextField.stringValue = String(model.percentOffset)
            self.risePriceTextField.doubleValue = model.risePrice
            self.fallPriceTextField.doubleValue = model.fallPrice
        }
    }
    
//    override func viewDidAppear() {
//        self.view.window?.delegate = self
//    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.timer?.pause()
    }
    
//    private func windowShouldClose(_ sender: Any) {
//        //NSApplication.shared().terminate(self)
//        print("windowShouldClose")
//        if let theToken = self.token {
//            TimerManager.shared.removeObserver(theToken)
//        }
//    }
    
    func requestData(code: String) {
        //print("requestData")
        print("设置提醒timer")
        let urlString = Constants.api_endPoint + code
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            if let data = response.data, let text = String(gbkData:data){
                //print(text)
                var array = text.components(separatedBy: ";")
                array.removeLast()
                if let item = array.first {
                    let model = StockModel(string: item)
                    self.updateStock(model: model)
                }
            }
        }
    }
    
    func updateStock(model: StockModel) {
        self.nowPrice = model.nowPrice

        self.nameLabel.stringValue = model.name
        
        var pricedelta = ""
        var percent = ""
        
        if model.percent > 0 {
            self.priceLabel.textColor = NSColor.red
            pricedelta = String(format: "+%.2f", model.pricedelta)
            percent = String(format: "+%.2f%%", model.percent)
        }else if model.percent == 0 {
            self.priceLabel.textColor = NSColor.gray
            pricedelta = String(format: "%.2f", model.pricedelta)
            percent = String(format: "%.2f%%", model.percent)
        }else {
            self.priceLabel.textColor = NSColor.green
            pricedelta = String(format: "%.2f", model.pricedelta)
            percent = String(format: "%.2f%%", model.percent)
        }
        
        self.priceLabel.stringValue = String(format: "%.2f     %@     %@", model.nowPrice, pricedelta, percent)
    }
    
    
    @IBAction func okAction(_ sender: Any) {
        self.timer?.pause()
        
        if let code = self.stockModel?.code {
            
            let model = RemindModel()
            
            let risePrice = self.risePriceTextField.doubleValue
            let fallPrice = self.fallPriceTextField.doubleValue
            
            model.stockCode = code
            model.risePrice = risePrice
            model.fallPrice = fallPrice
            
            //model.checkPercentOffset = self.percentOffsetCheckbox.state == .on ? true : false
            model.checkRisePrice = self.risePriceCheckbox.state == .on ? true : false
            model.checkFallPrice = self.fallPriceCheckbox.state == .on ? true : false
            
            if let _ = RemindManager.shared.findRemind(code: code) {
                RemindManager.shared.updateRemind(model: model)
            } else {
                RemindManager.shared.addRemind(model: model)
            }
        }
        
        self.view.window?.close()
    }
    
    //NSTextFieldDelegate
    func controlTextDidEndEditing(_ notification: Notification) {
        if let textField = notification.object as? NSTextField {
            if textField == self.risePriceTextField {
                let number = textField.doubleValue
                self.risePriceCheckbox.state = number > 0 ? .on : .off
                if self.nowPrice > 0 {
                    if number > self.nowPrice {
                        let percent = (number/self.nowPrice - 1)*100
                        self.riseMessageLabel.stringValue = String(format: "即比最新价上涨超过+%.2f%%", percent)
                    }else {
                        self.riseMessageLabel.stringValue = "上涨目标价低于最新价"
                    }
                }
            } else if textField == self.fallPriceTextField {
                let number = textField.doubleValue
                self.fallPriceCheckbox.state = number > 0 ? .on : .off
                if self.nowPrice > 0 {
                    if number < self.nowPrice {
                        let percent = (number/self.nowPrice - 1)*100
                        self.fallMessageLabel.stringValue = String(format: "即比最新价下跌超过%.2f%%", percent)
                    }else {
                        self.fallMessageLabel.stringValue = "下跌目标价高于最新价"
                    }
                }
            }
        }
    }
    
//    func controlTextDidChange(_ obj: Notification) {
//        if let textField = obj.object as? NSTextField {
//            if textField == self.risePriceTextField {
//                //self.risePriceCheckbox.state = textField.stringValue.isEmpty ? .off : .on
//
//            } else if textField == self.fallPriceTextField {
//                //self.fallPriceCheckbox.state = textField.stringValue.isEmpty ? .off : .on
//            }
//        }
//    }
    
    @IBAction func checkBoxAction(_ sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }
        
        if button.state == .off {
            return
        }
        
        if self.nowPrice == 0 {
            return
        }
        
        if button == self.risePriceCheckbox {
            let number = self.risePriceTextField.doubleValue
            if number > self.nowPrice {
                let percent = (number/self.nowPrice - 1)*100
                self.riseMessageLabel.stringValue = String(format: "即比最新价上涨超过+%.2f%%", percent)
            }else {
                self.riseMessageLabel.stringValue = "上涨目标价低于最新价"
            }
        } else if button == self.fallPriceCheckbox {
            let number = self.fallPriceTextField.doubleValue
            if number < self.nowPrice {
                let percent = (number/self.nowPrice - 1)*100
                self.fallMessageLabel.stringValue = String(format: "即比最新价下跌超过%.2f%%", percent)
            }else {
                self.fallMessageLabel.stringValue = "下跌目标价高于最新价"
            }
        }
    }
}
