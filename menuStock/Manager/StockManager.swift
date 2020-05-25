//
//  StockManager.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/19.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class StockManager {

    static let shared = StockManager()
    private  init(){}

    func addStock(code: String) {
        if findStock(code: code) == nil {
            Defaults[.stockList].append(code)
        }
    }
    
    func removeStock(code: String) {
        if let index = self.findStock(code: code) {
            Defaults[.stockList].remove(at: index)
        }
    }
    
    func findStock(code: String) -> Int? {
        var theIndex: Int?
        
        for (index, item) in Defaults[.stockList].enumerated() {
            if item == code {
                theIndex = index
                break
            }
        }
        return theIndex
    }
    
}
