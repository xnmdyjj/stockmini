//
//  ColorView.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/22.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa

class ColorView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // #1d161d
        //NSColor(red: 0x1d/255, green: 0x16/255, blue: 0x1d/255, alpha: 1).setFill()
        NSColor.white.setFill()
        dirtyRect.fill()
    }
}
