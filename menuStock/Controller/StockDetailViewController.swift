//
//  StockDetailViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/21.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Kingfisher
import Alamofire
import Repeat

class StockDetailViewController: NSViewController {
    
    @IBOutlet weak var stockNameLabel: NSTextField!
    
    @IBOutlet weak var stockCodeLabel: NSTextField!
    
    @IBOutlet weak var stockPriceLabel: NSTextField!
    
    @IBOutlet weak var timeLabel: NSTextField!

    @IBOutlet weak var traNumberLabel: NSTextField! //成交量
    
    @IBOutlet weak var traAmountLabel: NSTextField! //成交额
    
    @IBOutlet weak var todayStartPriceLabel: NSTextField!
    
    @IBOutlet weak var yesEndPriceLabel: NSTextField!
    
    @IBOutlet weak var todayHighPriceLabel: NSTextField!
    
    @IBOutlet weak var todayLowPriceLabel: NSTextField!
    
    @IBOutlet weak var week52HighLabel: NSTextField!
    @IBOutlet weak var week52LowLabel: NSTextField!

    @IBOutlet weak var segControl: NSSegmentedControl!
    
    @IBOutlet weak var chartImageView: NSImageView!
    
    var stockModel: StockModel?
    
    var timer: Repeater?
    
    let url_endPoint = "http://image.sinajs.cn"
    
    let stockCodeArray = ["sh000001", "sz399001", "sz399006", "sz399300", "sz399005", "sh000016", "hkHSI", "gb_$dji", "gb_ixic", "gb_$inx"]
    
    var minChartTimer: Repeater?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        segControl.selectedSegment = 0
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
            
            if self.minChartTimer == nil {
                self.minChartTimer = Repeater(interval: .seconds(10), mode: .infinite) { _ in
                    // do something
                    DispatchQueue.main.async {
                        self.updateMinChart()
                    }
                }
            }
            self.minChartTimer?.start()
        }
        
        self.updateView()
        self.updateMinChart()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.timer?.pause()
        self.minChartTimer?.pause()
    }
    
    func requestData(code: String) {
        print("股票详情timer")
        let urlString = Constants.api_endPoint + code
        Alamofire.request(urlString).response { response in // method defaults to `.get`
            if let data = response.data, let text = String(gbkData:data){
                var array = text.components(separatedBy: ";")
                array.removeLast()
                if let item = array.first {
                    let model = StockModel(string: item)
                    self.stockModel = model
                    self.updateView()
                }
            }
        }
    }
    
    func updateView() {
        guard let model = self.stockModel else {
            return
        }
        
        self.stockNameLabel.stringValue = model.name
        self.stockCodeLabel.stringValue = model.getPureCode()
        
        var pricedelta = ""
        var percent = ""
        
        if model.percent > 0 {
            self.stockPriceLabel.textColor = NSColor.red
            pricedelta = String(format: "+%.2f", model.pricedelta)
            percent = String(format: "+%.2f%%", model.percent)
        }else if model.percent == 0 {
            self.stockPriceLabel.textColor = NSColor.gray
            pricedelta = String(format: "%.2f", model.pricedelta)
            percent = String(format: "%.2f%%", model.percent)
        }else {
            self.stockPriceLabel.textColor = NSColor.green
            pricedelta = String(format: "%.2f", model.pricedelta)
            percent = String(format: "%.2f%%", model.percent)
        }
        
        self.stockPriceLabel.stringValue = String(format: "%.2f     %@     %@", model.nowPrice, pricedelta, percent)
        self.timeLabel.stringValue = model.dateStr + " " + model.timeStr
        
        if model.traNumber != 0 {
            if isStockIndex(code: model.code) {
                if model.code == "sh000001" || model.code == "sh000016" {
                    let traNumber = model.traNumber / 10000
                    if traNumber > 10000 {
                        let value = traNumber / 10000
                        self.traNumberLabel.stringValue = String(format: "%.2f亿", value)
                    }else {
                        self.traNumberLabel.stringValue = String(format: "%.2f万", traNumber)
                    }
                } else if model.code == "sz399001" || model.code == "sz399006" || model.code == "sz399300" || model.code == "sz399005" {
                    let traNumber = (model.traNumber / 100) / 10000
                    if traNumber > 10000 {
                        let value = traNumber / 10000
                        self.traNumberLabel.stringValue = String(format: "%.2f亿", value)
                    }else {
                        self.traNumberLabel.stringValue = String(format: "%.2f万", traNumber)
                    }
                } else {
                    let traNumber = model.traNumber / 10000
                    if traNumber > 10000 {
                        let value = traNumber / 10000
                        self.traNumberLabel.stringValue = String(format: "%.2f亿", value)
                    }else {
                        self.traNumberLabel.stringValue = String(format: "%.2f万", traNumber)
                    }
                }
            } else if isAStock(code: model.code) {
                let traNumber = model.traNumber / 100
                if traNumber > 10000 {
                    let value = traNumber / 10000
                    self.traNumberLabel.stringValue = String(format: "%.2f万手", value)
                }else {
                    self.traNumberLabel.stringValue = "\(Int(traNumber))手"
                }
            } else {
                let traNumber = model.traNumber / 10000
                if traNumber > 10000 {
                    let value = traNumber / 10000
                    self.traNumberLabel.stringValue = String(format: "%.2f亿", value)
                }else {
                    self.traNumberLabel.stringValue = String(format: "%.2f万", traNumber)
                }
            }
        }
        
        if model.traAmount != 0 {
            let traAmount = model.traAmount/10000
            if traAmount > 10000 {
                let value = traAmount / 10000
                self.traAmountLabel.stringValue = String(format: "%.2f亿", value)
            } else {
                self.traAmountLabel.stringValue = String(format: "%.2f万", traAmount)
            }
        }
        
        self.todayStartPriceLabel.stringValue = String(format: "%.2f", model.todayStartPrice)
        self.yesEndPriceLabel.stringValue = String(format: "%.2f", model.yesEndPrice)
        
        self.todayHighPriceLabel.stringValue = String(format: "%.2f", model.todayHighPrice)
        self.todayLowPriceLabel.stringValue = String(format: "%.2f", model.todayLowPrice)
        
        if model.week52High != 0 {
            self.week52HighLabel.stringValue = String(format: "%.2f", model.week52High)
        }
        
        if model.week52Low != 0 {
            self.week52LowLabel.stringValue = String(format: "%.2f", model.week52Low)
        }

        //self.updateMinChart()
    }
    
    func isStockIndex(code: String) -> Bool {
        var value = false
        for item in self.stockCodeArray {
            if item == code  {
                value = true
                break
            }
        }
        return value
    }
    
    func isAStock(code: String) -> Bool {
        if code.hasPrefix("sh") || code.hasPrefix("sz") {
            return true
        }
        return false
    }
    
    func updateMinChart() {
        print("股票分时图timer")
        guard let model = self.stockModel else {
            return
        }
        if self.segControl.selectedSegment == 0 {
            var url: String?
            if model.code.hasPrefix("sh") || model.code.hasPrefix("sz") {
                url = url_endPoint.appendingPathComponent("newchart/min/n/\(model.code).gif")
            } else if model.code.hasPrefix("hk") {
                let code = model.code.replacingOccurrences(of: "hk", with: "")
                url = url_endPoint.appendingPathComponent("newchart/hk_stock/min/\(code).gif")
            } else if model.code.hasPrefix("gb_") {
                let code = model.code.replacingOccurrences(of: "gb_", with: "")
                url = url_endPoint.appendingPathComponent("newchartv5/usstock/min/\(code).gif")
            }
            guard let theUrl = url else {
                return
            }
            chartImageView.kf.setImage(with: URL(string: theUrl), options:[.forceRefresh])
        }
    }
    
    func updateChart() {
        guard let model = self.stockModel else {
            return
        }
        
        var url: String?
        if model.code.hasPrefix("sh") || model.code.hasPrefix("sz") {
            switch segControl.selectedSegment {
            case 0:
                url = url_endPoint.appendingPathComponent("newchart/min/n/\(model.code).gif")
            case 1:
                url = url_endPoint.appendingPathComponent("newchart/daily/n/\(model.code).gif")
            case 2:
                url = url_endPoint.appendingPathComponent("newchart/weekly/n/\(model.code).gif")
            case 3:
                url = url_endPoint.appendingPathComponent("newchart/monthly/n/\(model.code).gif")
            default:
                break
            }
        } else if model.code.hasPrefix("hk") {
            let code = model.code.replacingOccurrences(of: "hk", with: "")
            
            switch segControl.selectedSegment {
            case 0:
                url = url_endPoint.appendingPathComponent("newchart/hk_stock/min/\(code).gif")
            case 1:
                url = url_endPoint.appendingPathComponent("newchart/hk_stock/daily/\(code).gif")
            case 2:
                url = url_endPoint.appendingPathComponent("newchart/hk_stock/weekly/\(code).gif")
            case 3:
                url = url_endPoint.appendingPathComponent("newchart/hk_stock/monthly/\(code).gif")
            default:
                break
            }
        } else if model.code.hasPrefix("gb_") {
            let code = model.code.replacingOccurrences(of: "gb_", with: "")
            
            switch segControl.selectedSegment {
            case 0:
                url = url_endPoint.appendingPathComponent("newchartv5/usstock/min/\(code).gif")
            case 1:
                url = url_endPoint.appendingPathComponent("newchartv5/usstock/daily/\(code).gif")
            case 2:
                url = url_endPoint.appendingPathComponent("newchartv5/usstock/weekly/\(code).gif")
            case 3:
                url = url_endPoint.appendingPathComponent("newchartv5/usstock/monthly/\(code).gif")
            default:
                break
            }
        }
        
        guard let theUrl = url else {
            return
        }

        chartImageView.kf.setImage(with: URL(string: theUrl), options: [.forceRefresh])
        
    }
    
    
    @IBAction func segControlAction(_ sender: Any) {
        self.updateChart()
    }
}



//    "minurl":"http://image.sinajs.cn/newchart/min/n/sh601009.gif",/*分时K线图*/
//    "dayurl":"http://image.sinajs.cn/newchart/daily/n/sh601009.gif",/*日K线图*/
//    "weekurl":"http://image.sinajs.cn/newchart/weekly/n/sh601009.gif",/*周K线图*/
//    "monthurl":"http://image.sinajs.cn/newchart/monthly/n/sh601009.gif"/*月K线图*/

//
//    "gopicture":{
//    "minurl":"http://image.sinajs.cn/newchart/hk_stock/min/00001.gif",/*分时K线*/
//    "dayurl":"http://image.sinajs.cn/newchart/hk_stock/daily/00001.gif",/*日K线图*/
//    "weekurl":"http://image.sinajs.cn/newchart/hk_stock/weekly/00001.gif",/*周K线图*/
//    "monthurl":"http://image.sinajs.cn/newchart/hk_stock/monthly/00001.gif"/*月K线图*/
//    },

//    "gopicture":{
//    "minurl":"http://image.sinajs.cn/newchartv5/usstock/min/aapl.gif",/*分时K线图*/
//    "min_weekpic":"http://image.sinajs.cn/newchartv5/usstock/min_week/aapl.gif",/*5日K线图*/
//    "dayurl":"http://image.sinajs.cn/newchartv5/usstock/daily/aapl.gif",/*日K线图*/
//    "weekurl":"http://image.sinajs.cn/newchartv5/usstock/weekly/aapl.gif",/*周K线图*/
//    "monthurl":"http://image.sinajs.cn/newchartv5/usstock/monthly/aapl.gif"/*月K线图*/
//}
