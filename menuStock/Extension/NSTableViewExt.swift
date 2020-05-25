//
//  NSTableViewExt.swift
//  menuStock
//
//  Created by 喻建军 on 2020/4/16.
//  Copyright © 2020 secnettool. All rights reserved.
//

import Cocoa

extension NSTableView {
    func reloadDataKeepingSelection() {
        let selectedRowIndexes = self.selectedRowIndexes
        self.reloadData()
        self.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
}
