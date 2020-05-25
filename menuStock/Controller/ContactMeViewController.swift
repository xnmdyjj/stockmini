//
//  ContactMeViewController.swift
//  menuStock
//
//  Created by 喻建军 on 2019/4/1.
//  Copyright © 2019 secnettool. All rights reserved.
//

import Cocoa

class ContactMeViewController: NSViewController {

    @IBOutlet weak var qqTips: NSTextField!
    @IBOutlet weak var emailTips: NSTextField!
    @IBOutlet weak var weChatTips: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
    }
    
    @IBAction func copyEmail(_ sender: Any) {
        NSPasteboard.general.setString("secnettool@gmail.com", forType: NSPasteboard.PasteboardType.string)
        emailTips.stringValue = "复制成功"
        
    }
    @IBAction func copyQQ(_ sender: Any) {
         NSPasteboard.general.setString("271519243", forType: NSPasteboard.PasteboardType.string)
        qqTips.stringValue = "复制成功"
    }
    
    
    @IBAction func copyWechat(_ sender: Any) {
        NSPasteboard.general.setString("xnmdyjj", forType: NSPasteboard.PasteboardType.string)
        weChatTips.stringValue = "复制成功"
        
    }
    @IBAction func sendEmail(_ sender: Any) {
        Helper.sendEmail()
    }
}
