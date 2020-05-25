//
//  NotificationTimer.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/20.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Repeat

class NotificationTimer {

    static let shared = NotificationTimer()
    
    var timer: Repeater?
    
    private init(){}
    
    func start(observer: @escaping (() -> Void)) {
        self.timer = Repeater(interval: .seconds(3), mode: .infinite) { _ in
            // do something
            observer()
        }
        self.timer?.start()
    }
    
    func pause() {
        self.timer?.pause()
    }
}
