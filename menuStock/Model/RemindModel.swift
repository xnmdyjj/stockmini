//
//  RemindModel.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/20.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

class RemindModel: Codable, DefaultsSerializable {
    var stockCode: String = ""
    
    //var percentOffset: Double = 0
    var risePrice: Double = 0
    var fallPrice: Double = 0
    
    //var checkPercentOffset: Bool = false
    var checkRisePrice: Bool = false
    var checkFallPrice: Bool = false
}
