//
//  ViewControllerSchedules.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 10.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//
// swiftlint:disable line_length cyclomatic_complexity

import Cocoa
import Foundation

class ViewControllerSchedules: NSViewController, GetAllSchedules, Setlog {
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

    override func viewDidDisappear() {
        super.viewDidDisappear()
    }

    @objc(tableViewDoubleClick:) func tableViewDoubleClick(sender _: AnyObject) {
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Loading profile:", comment: "schedule") + " " + self.profilname!)
        if self.profilname == NSLocalizedString("Default profile", comment: "default profile") { self.profilname = nil }
        self.loadProfileDelegate?.reloaddata(profilename: self.profilname)
        self.view.window?.close()
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
        if let object: NSDictionary = self.schedulessortedandexpanded?.sortedschedules?[row],
           let hiddenID = object.value(forKey: "hiddenID") as? Int
        {
            if let tableColumn = tableColumn {
                switch tableColumn.identifier.rawValue {
                case "intime":
                    let profilename = object.value(forKey: DictionaryStrings.profilename.rawValue) as? String ?? NSLocalizedString("Default profile", comment: "default profile")
                    let taskintime = self.schedulessortedandexpanded?.sortandcountscheduledonetask(hiddenID, profilename: profilename, number: true)
                    return taskintime ?? ""
                case "schedule":
                    switch object[tableColumn.identifier] as? String {
                    case Scheduletype.once.rawValue:
                        return NSLocalizedString("once", comment: "main")
                    case Scheduletype.daily.rawValue:
                        return NSLocalizedString("daily", comment: "main")
                    case Scheduletype.weekly.rawValue:
                        return NSLocalizedString("weekly", comment: "main")
                    default:
                        return ""
                    }
                case "delta":
                    let delta = self.schedulessortedandexpanded?.sortedschedules?.filter { $0.value(forKey: "hiddenID") as? Int == hiddenID }
                    if (delta?.count ?? 0) > 0 {
                        return delta?[0].value(forKey: "delta") as? String
                    }
                default:
                    return object[tableColumn.identifier]
                }
            }
        }
        return nil
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            if let dict = self.schedulessortedandexpanded?.sortedschedules?[index] {
                self.profilname = dict.value(forKey: DictionaryStrings.profilename.rawValue) as? String ?? NSLocalizedString("Default profile", comment: "default profile")
            }
        }
    }
}
