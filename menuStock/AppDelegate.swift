//
//  AppDelegate.swift
//  menuStock
//
//  Created by 喻建军 on 2019/3/18.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)

    let popover = NSPopover()

    var eventMonitor: EventMonitor?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("StatusBarButtonImage"))
            button.action = #selector(AppDelegate.togglePopover(_:))
        }
        
        popover.contentViewController = StocksViewController.freshController()
        
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                if Defaults[.pinPopover] == false {
                    strongSelf.closePopover(sender: event)
                }
            }
        }
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
            print("showPopover")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                TimerManager.shared.start()
//            }
//            
            TimerManager.shared.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
        print("closePopover")
        TimerManager.shared.pause()
    }


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

