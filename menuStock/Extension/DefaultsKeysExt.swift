//
//  DefaultsKeysExt.swift
//  tbrBrowser
//
//  Created by 喻建军 on 2018/12/12.
//  Copyright © 2018 Jianjun Yu. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {

    static let stockList = DefaultsKey<[String]>("stockList", defaultValue: ["sh000001", "sz399001", "sz399006"])
    static let remindList = DefaultsKey<[RemindModel]>("remindList", defaultValue: [])
    
    static let pinPopover = DefaultsKey<Bool>("pinPopover", defaultValue: false)
    
    static let followStockList = DefaultsKey<[String]>("followStockList", defaultValue: [])


}
