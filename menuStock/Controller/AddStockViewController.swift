//
//  AddStockViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/18.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Alamofire
import SwiftyUserDefaults

class AddStockViewController: NSViewController {

    var type = "sh"

    @IBOutlet weak var codeTextField: NSTextField!
    @IBOutlet weak var messageLabel: NSTextField!

    let message = "添加失败，请确认股票代码和股票板块。"
    
    let stockCodeArray = ["sh000001", "sz399001", "sz399006", "sz399300", "sz399005", "sh000016", "hkHSI", "gb_$dji", "gb_ixic", "gb_$inx"]
    
    
    @IBOutlet weak var boxContainerView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        updateStockIndex()
    }
    
    func updateStockIndex() {
        let buttonArray = boxContainerView.subviews
        let stockMgr = StockManager.shared
        for button in buttonArray {
            guard let theButton = button as? NSButton else {
                continue
            }
            let code = self.stockCodeArray[theButton.tag - 1]
            theButton.state = stockMgr.findStock(code: code) != nil ? .on : .off
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        let code = self.codeTextField.stringValue
        if code.isEmpty {
            self.messageLabel.stringValue = "请输入股票代码"
            return
        }
        
        self.requestData(code: type+code)
    }
    
    func requestData(code: String) {
       
        let urlString = Constants.api_endPoint + code
        Alamofire.request(urlString).response { response in
            if let data = response.data, let text = String(gbkData:data){
                print(text)
                var array = text.components(separatedBy: ";")
                array.removeLast()

                guard let string = array.first else {
                    self.messageLabel.stringValue = self.message
                    return
                }
                
                let model = StockModel(string: string)
                if !model.name.isEmpty {
                    StockManager.shared.addStock(code: model.code)
                    self.messageLabel.stringValue = "添加成功!"
                    self.codeTextField.stringValue = ""
                }else {
                    self.messageLabel.stringValue = self.message
                }
            }else {
                self.messageLabel.stringValue = "添加失败，请稍后再试。"
            }
        }
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        guard let button = sender as? NSButton else {
            return
        }
        
        switch button.tag {
        case 1:
            type = "sh"
        case 2:
            type = "sz"
        case 3:
            type = "hk"
        case 4:
            type = "gb_"
        default:
            type = ""
        }
    }
    
    @IBAction func checkStockIndex(_ sender: Any) {
        guard let button = sender as? NSButton else {
            return
        }
        let stockMgr = StockManager.shared
        let code = self.stockCodeArray[button.tag - 1]
        
        if button.state == .on {
            stockMgr.addStock(code: code)
        }else {
            stockMgr.removeStock(code: code)
        }
    }
}
