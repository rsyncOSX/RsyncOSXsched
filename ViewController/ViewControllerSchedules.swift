//
//  ViewControllerSchedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 10.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import Cocoa

class ViewControllerSchedules: NSViewController, SetDismisser, GetAllSchedules {

    @IBOutlet weak var allschedulestable: NSTableView!
    var profilname: String?
    weak var loadProfileDelegate: ReloadData?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.allschedulestable.delegate = self
        self.allschedulestable.dataSource = self
        self.allschedulestable.doubleAction = #selector(ViewControllerSchedules.tableViewDoubleClick(sender:))
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.loadProfileDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        globalMainQueue.async(execute: { () -> Void in
            self.allschedulestable.reloadData()
        })
    }

    @IBAction func close(_ sender: NSButton) {
        self.dismissview(viewcontroller: self)
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender: AnyObject) {
        self.loadProfileDelegate?.reloaddata(profilename: self.profilname)
        self.dismissview(viewcontroller: self)
    }
}

extension ViewControllerSchedules: NSTableViewDataSource {

    func numberOfRows(in aTableView: NSTableView) -> Int {
        return self.schedulessortedandexpanded?.getsortedAndExpandedScheduleData()?.count ?? 0
    }
}

extension ViewControllerSchedules: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.schedulessortedandexpanded!.getsortedAndExpandedScheduleData()!.count else { return nil }
        let object: NSDictionary = self.schedulessortedandexpanded!.getsortedAndExpandedScheduleData()![row]
        if tableColumn!.identifier.rawValue == "intime" {
            let hiddenID = object.value(forKey: "hiddenID") as? Int ?? -1
            let profilename = object.value(forKey: "profilename") as? String ?? "Default profile"
            let taskintime: String? = self.schedulessortedandexpanded!.sortandcountscheduledonetask(hiddenID, profilename: profilename, number: true)
            return taskintime ?? ""
        } else {
            return object[tableColumn!.identifier]
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            let dict = self.schedulessortedandexpanded!.getsortedAndExpandedScheduleData()![index]
            self.profilname = dict.value(forKey: "profilename") as? String ?? "Default profile"
        }
    }
}
