//
//  NSImageExt.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/19.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        color.set()
        
        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        
        return image
    }
}
