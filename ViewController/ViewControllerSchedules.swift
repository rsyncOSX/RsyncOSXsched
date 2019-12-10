//
//  ViewControllerSchedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 10.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length

import Cocoa
import Foundation

class ViewControllerSchedules: NSViewController, SetDismisser, GetAllSchedules, Setlog {
    @IBOutlet var allschedulestable: NSTableView!
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
        globalMainQueue.async { () -> Void in
            self.allschedulestable.reloadData()
        }
    }

    @IBAction func close(_: NSButton) {
        self.dismissview(viewcontroller: self)
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Loading profile:", comment: "schedule") + " " + self.profilname!)
        if self.profilname == NSLocalizedString("Default profile", comment: "default profile") { self.profilname = nil }
        self.loadProfileDelegate?.reloaddata(profilename: self.profilname)
        self.dismissview(viewcontroller: self)
    }
}

extension ViewControllerSchedules: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return self.schedulessortedandexpanded?.sortedschedules?.count ?? 0
    }
}

extension ViewControllerSchedules: NSTableViewDelegate {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.schedulessortedandexpanded?.sortedschedules?.count ?? -1 else { return nil }
        let object: NSDictionary = self.schedulessortedandexpanded!.sortedschedules![row]
        if tableColumn!.identifier.rawValue == "intime" {
            let hiddenID = object.value(forKey: "hiddenID") as? Int ?? -1
            let profilename = object.value(forKey: "profilename") as? String ?? NSLocalizedString("Default profile", comment: "default profile")
            let dateStart = object.value(forKey: "dateStart") as? Date
            let taskintime: String? = self.schedulessortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: dateStart, number: true)
            return taskintime ?? ""
        } else if tableColumn!.identifier.rawValue == "schedule" {
            switch object[tableColumn!.identifier] as? String {
            case "once":
                return NSLocalizedString("once", comment: "main")
            case "daily":
                return NSLocalizedString("daily", comment: "main")
            case "weekly":
                return NSLocalizedString("weekly", comment: "main")
            default:
                return ""
            }
        } else {
            return object[tableColumn!.identifier]
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            let dict = self.schedulessortedandexpanded!.sortedschedules![index]
            self.profilname = dict.value(forKey: "profilename") as? String ?? NSLocalizedString("Default profile", comment: "default profile")
        }
    }
}
