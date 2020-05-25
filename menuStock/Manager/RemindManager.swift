//
//  RemindManager.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/20.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class RemindManager {

    static let shared = RemindManager()
    private  init(){}
    
    func addRemind(model: RemindModel) {
        if findRemind(code: model.stockCode) == nil {
            Defaults[.remindList].append(model)
        }
    }
    
    func removeRemind(code: String) {
        if let index = self.findRemind(code: code) {
            Defaults[.remindList].remove(at: index)
        }
    }
    
    func updateRemind(model: RemindModel) {
        if let index = self.findRemind(code: model.stockCode) {
            Defaults[.remindList][index] = model
        }
    }
    
    func findRemind(code: String) -> Int? {
        var theIndex: Int?
        
        for (index, item) in Defaults[.remindList].enumerated() {
            if item.stockCode == code {
                theIndex = index
                break
            }
        }
        return theIndex
    }
    
    func queryRemind(code: String) -> RemindModel? {
        if let index = self.findRemind(code: code) {
            return Defaults[.remindList][index]
        }
        return nil
    }
}
