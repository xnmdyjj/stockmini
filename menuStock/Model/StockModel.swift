//
//  StockModel.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/19.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa

class StockModel: NSObject {
    var code: String = ""
    var name: String = ""
    
    var todayStartPrice: Double = 0
    var yesEndPrice: Double = 0
    
    var nowPrice: Double = 0
    
    var todayHighPrice: Double = 0
    var todayLowPrice: Double = 0
    
    var traNumber: Double = 0 //成交量
    var traAmount: Double = 0 //成交金额

    var dateStr: String = ""
    var timeStr: String = ""
    
    var pricedelta: Double = 0
    var percent: Double = 0
    
    var week52High: Double = 0
    var week52Low: Double = 0
    
    
    
    override init() {
        super.init()
    }
    
    init(string: String) {
        let components = string.components(separatedBy: "=")
        
        guard let keyString = components.first else {
            return
        }
        
        guard var valueString = components.last else {
            return
        }
        
        valueString = valueString.replacingOccurrences(of: "\"", with: "")
        if valueString.isEmpty {
            return
        }
        
        let keyNSString = keyString as NSString
        let range = keyNSString.range(of: "hq_str")
        let stockCode = keyNSString.substring(from: range.location + range.length + 1)
        let array = valueString.components(separatedBy: ",")
        if stockCode.hasPrefix("sh") || stockCode.hasPrefix("sz") {
            
            self.code = stockCode
            
            self.name = array[0]
            self.todayStartPrice = Double(array[1]) ?? 0
            self.yesEndPrice = Double(array[2]) ?? 0
            self.nowPrice = Double(array[3]) ?? 0
            self.todayHighPrice = Double(array[4]) ?? 0
            self.todayLowPrice = Double(array[5]) ?? 0
            
            self.traNumber = Double(array[8]) ?? 0
            self.traAmount = Double(array[9]) ?? 0
            
            self.dateStr = array[30]
            self.timeStr = array[31]
        } else if stockCode.hasPrefix("hk") {
            self.code = stockCode
            
            self.name = array[1]
            self.todayStartPrice = Double(array[2]) ?? 0
            self.yesEndPrice = Double(array[3]) ?? 0
            self.nowPrice = Double(array[6]) ?? 0
            self.todayHighPrice = Double(array[4]) ?? 0
            self.todayLowPrice = Double(array[5]) ?? 0
            
            self.traNumber = Double(array[11]) ?? 0
            self.traAmount = Double(array[12]) ?? 0
            
            self.week52High = Double(array[15]) ?? 0
            self.week52Low = Double(array[16]) ?? 0
            
            self.dateStr = array[17]
            self.timeStr = array[18]
        } else if stockCode.hasPrefix("gb_") {
            self.code = stockCode
            
            self.name = array[0]
            self.todayStartPrice = Double(array[5]) ?? 0
            self.yesEndPrice = Double(array[26]) ?? 0
            self.nowPrice = Double(array[1]) ?? 0
            self.todayHighPrice = Double(array[6]) ?? 0
            self.todayLowPrice = Double(array[7]) ?? 0
            
            self.traNumber = Double(array[10]) ?? 0
            
            self.dateStr = array[3]
            self.timeStr = array[3]
            
            self.week52High = Double(array[8]) ?? 0
            self.week52Low = Double(array[9]) ?? 0
        }
        if self.nowPrice > 0 {
            self.pricedelta = self.nowPrice - self.yesEndPrice
            self.percent = (self.nowPrice/self.yesEndPrice - 1)*100
        }
    }
    
    func getPureCode() -> String {
        let codeNSString = self.code as NSString
        if self.code.hasPrefix("sh") || self.code.hasPrefix("sz") || self.code.hasPrefix("hk") {
            return codeNSString.substring(from: 2)
        }else if self.code.hasPrefix("gb_") {
            return codeNSString.substring(from: 3)
        }
        return ""
    }
}
