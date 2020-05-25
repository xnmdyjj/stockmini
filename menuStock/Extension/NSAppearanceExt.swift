//
//  NSAppearanceExt.swift
//  menuStock
//
//  Created by 喻建军 on 2020/4/20.
//  Copyright © 2020 secnettool. All rights reserved.
//

import Cocoa

extension NSAppearance {
    public var isDarkMode: Bool {
        if #available(macOS 10.14, *) {
            if self.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
