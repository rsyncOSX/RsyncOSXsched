//
//  ViewControllerSchedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 10.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Foundation

import Cocoa

class ViewControllerSchedules: NSViewController, SetDismisser, GetAllSchedules {

    @IBOutlet weak var allschedulestable: NSTableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.allschedulestable.delegate = self
        self.allschedulestable.dataSource = self
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        globalMainQueue.async(execute: { () -> Void in
            self.allschedulestable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self)
    }
}

extension ViewControllerSchedules: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.allschedules?.count ?? 0
    }
}

extension ViewControllerSchedules: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.allschedules!.count  else { return nil }
        let object: NSDictionary = self.allschedules![row]
        return object[tableColumn!.identifier]
    }
}
