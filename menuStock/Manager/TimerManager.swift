//
//  TimerManager.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/19.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import Repeat

class TimerManager {
    static let shared = TimerManager()
    
    var timer: Repeater?

    private init(){}
    
    func createTimer(observer: @escaping (() -> Void)) {
        self.timer = Repeater(interval: .seconds(2), mode: .infinite) { _ in
            // do something
            observer()
        }
    }
    
    func start()  {
       self.timer?.start()
    }
    
    func pause() {
       self.timer?.pause()
    }
    
    func addObserver(observer: @escaping (() -> Void))  -> UInt64? {
        
        let token = self.timer?.observe({ ( _ ) in
            observer()
        })
        
        return token
    }
    
    func removeObserver(_ token: UInt64) {
        self.timer?.remove(observer: token)
    }
}
