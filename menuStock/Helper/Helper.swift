//
//  Helper.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/19.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa

class Helper {
    static func sendEmail() {
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)!
        service.recipients = ["secnettool@gmail.com"]
        service.subject = "StockMini反馈"
        
        service.perform(withItems: [])
    }
}
