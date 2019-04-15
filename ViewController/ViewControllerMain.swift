//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//
//  swiftlint:disable line_length file_length

import Cocoa
import Foundation

class ViewControllerMain: NSViewController, Delay, Setlog {

    // Information about logs
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardInformationID")
            as? NSViewController)!
    }

    // All schedules
    var viewControllerAllschedules: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: "StoryboardAllschedulesID")
            as? NSViewController)!
    }

    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var profilescombobox: NSComboBox!
    @IBOutlet weak var profileinfo: NSTextField!
    @IBOutlet weak var rsyncosxbutton: NSButton!
    @IBOutlet weak var statuslight: NSImageView!
    @IBOutlet weak var info: NSTextField!
    @IBOutlet weak var progresslabel: NSTextField!
    @IBOutlet weak var newversion: NSTextField!
    @IBOutlet weak var rsyncosxschedversion: NSTextField!
    @IBOutlet weak var backupnowbutton: NSButton!

    var configurations: Configurations?
    var schedules: Schedules?
    var schedulesortedandexpanded: ScheduleSortedAndExpand?
    var outputprocess: OutputProcess?
    var profilename: String?
    var log: [String]?
    var reloadnotification: NSObjectProtocol?

    private var profilesArray: [String]?
    private var profile: Files?
    var allschedules: [ConfigurationSchedule]?
    var index: Int?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.sleepandwakenotifications()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.viewControllermain = self
        self.configurations = Configurations(profile: nil)
        self.schedules = Schedules(profile: nil)
        _ = Checkfornewversion()
        self.addobserverforreload()
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
	}

    override func viewDidAppear() {
        super.viewDidAppear()
        self.setprofiles()
        self.checkforrunning()
        self.info(num: -1)
        self.profilescombobox.stringValue = "Default profile"
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func addobserverforreload() {
        self.reloadnotification = DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("no.blogspot.RsyncOSX.reload"), object: nil, queue: nil) { _ -> Void in
            self.addlog(logrecord: "Got notification for reload")
            self.reloadselectedprofile()
            self.schedulesortedandexpanded = ScheduleSortedAndExpand()
            self.startfirstscheduledtask()
        }
    }

    private func checkforrunning() {
        guard Running().rsyncOSXisrunning == false else {
            self.rsyncosxbutton.isEnabled = false
            return
        }
        if ViewControllerReference.shared.pathrsyncosx != nil {
            self.rsyncosxbutton.isEnabled = true
        } else {
            self.rsyncosxbutton.isEnabled = false
        }
    }

    @IBAction func backupnow(_ sender: NSButton) {
        guard self.index != nil else { return  }
        guard self.configurations!.getConfigurationsDataSourcecountBackup() != nil  else { return  }
        self.backupnowbutton.isEnabled = false
        let dict: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackup()![self.index!]
        _ = ExecuteTaskNow(dict: dict)
    }

    @IBAction func abort(_ sender: NSButton) {
        ViewControllerReference.shared.process?.terminate()
        self.progress.stopAnimation(nil)
        self.reloadselectedprofile()
    }

	@IBAction func closeButtonAction(_ sender: NSButton) {
		NSApp.terminate(self)
	}

    @IBAction func openRsyncOSX(_ sender: NSButton) {
        let pathtorsyncosxapp: String = ViewControllerReference.shared.pathrsyncosx! + ViewControllerReference.shared.namersyncosx
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxapp))
        NSApp.terminate(self)
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        self.reloadselectedprofile()
    }

    @IBAction func viewlogg(_ sender: NSButton) {
        self.presentAsSheet(self.viewControllerInformation!)
    }

    @IBAction func viewallschedules(_ sender: NSButton) {
        self.presentAsSheet(self.viewControllerAllschedules!)
    }

    private func reloadselectedprofile() {
        self.info(num: -1)
        guard self.profilesArray != nil else { return }
        guard self.profilescombobox.indexOfSelectedItem > 0 else {
            self.addlog(logrecord: "Profile: default loaded.")
            self.profileinfo.stringValue = "Profile: default"
            self.profilename = nil
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            return
        }
        self.profilename = self.profilesArray![self.profilescombobox.indexOfSelectedItem]
        self.profileinfo.stringValue = "Profile: " + self.profilename!
        self.addlog(logrecord: "Profile: " + self.profilename! + " loaded.")
        self.createandreloadconfigurations()
        self.createandreloadschedules()
    }

    func createandreloadschedules() {
        self.addlog(logrecord: "Reading schedules for current profile")
        guard self.configurations != nil else {
            self.schedules = Schedules(profile: nil)
            return
        }
        if let profile = self.profilename {
            self.schedules = nil
            self.schedules = Schedules(profile: profile)
        } else {
            self.schedules = nil
            self.schedules = Schedules(profile: nil)
        }
    }

    func createandreloadconfigurations() {
        self.addlog(logrecord: "Reading configurations for current profile")
        guard self.configurations != nil else {
            self.configurations = Configurations(profile: nil)
            return
        }
        if let profile = self.profilename {
            self.configurations = nil
            self.configurations = Configurations(profile: profile)
        } else {
            self.configurations = nil
            self.configurations = Configurations(profile: nil)
        }
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func setprofiles() {
        self.profile = nil
        self.profile = Files(whichroot: .profileRoot, configpath: ViewControllerReference.shared.configpath)
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.profilescombobox.removeAllItems()
        guard self.profilesArray != nil else { return }
        self.profilescombobox.addItems(withObjectValues: (self.profilesArray!))
    }

    private func info (num: Int) {
        globalMainQueue.async(execute: { () -> Void in
            switch num {
            case 1:
                self.info.stringValue = "Some remote sites not avaliable, see log ...."
            case 2:
                self.info.stringValue = "Executing scheduled tasks is not enabled in RsyncOSX...."
            default:
                self.info.stringValue = ""
            }
        })
    }

    private func startfirstscheduledtask() {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        ViewControllerReference.shared.timerTaskWaiting = nil
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.getfirstscheduledtask()
        if let operation = ViewControllerReference.shared.operation {
            switch operation {
            case .dispatch:
                _ = ScheduleOperationDispatch()
            case .timer:
                _ = ScheduleOperationTimer()
            }
        } else {
            _ = ScheduleOperationDispatch()
        }
    }

    @objc func onWakeNote(note: NSNotification) {
        self.logDelegate?.addlog(logrecord: "Activating schedules again after sleeping...")
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
    }

    @objc func onSleepNote(note: NSNotification) {
        self.logDelegate?.addlog(logrecord: "Invalidating tasks and going to sleep...")
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
    }

    private func sleepandwakenotifications() {
        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onWakeNote(note:)),
                                                           name: NSWorkspace.didWakeNotification, object: nil)

        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onSleepNote(note:)),
                                                           name: NSWorkspace.willSleepNotification, object: nil)
    }
}

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourcecountBackup()?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourcecountBackup()!.count  else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourcecountBackup()![row]
        let hiddenID = object.value(forKey: "hiddenID") as? Int ?? -1
        let profilename = object.value(forKey: "profilename") as? String ?? "Default profile"
        switch tableColumn!.identifier.rawValue {
        case "scheduleID" :
            if self.schedulesortedandexpanded != nil {
                let schedule: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: nil, number: false)
                return schedule ?? ""
            }
        case "batchCellID" :
            return object[tableColumn!.identifier]
        case "offsiteServerCellID":
            if (object[tableColumn!.identifier] as? String)!.isEmpty {
                return "localhost"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        case "inCellID":
            if self.schedulesortedandexpanded != nil {
                let taskintime: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: nil, number: true)
                return taskintime ?? ""
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
        return nil
    }

    // setting which table row is selected
    func tableViewSelectionDidChange(_ notification: Notification) {
        let myTableViewFromNotification = (notification.object as? NSTableView)!
        let indexes = myTableViewFromNotification.selectedRowIndexes
        if let index = indexes.first {
            self.index = index
        } else {
            self.index = nil
        }
    }

}

extension ViewControllerMain: Updatestatuslight {
    func updatestatuslight(color: Status) {
        globalMainQueue.async(execute: { () -> Void in
            switch color {
            case .red:
                self.statuslight.image = #imageLiteral(resourceName: "red")
            case .green:
                self.statuslight.image = #imageLiteral(resourceName: "green")
            case .yellow:
                self.statuslight.image = #imageLiteral(resourceName: "yellow")
            }
        })
    }
}

extension ViewControllerMain: Updatestatustcpconnections {
    func updatestatustcpconnections() {
        self.info(num: 1)
    }
}

extension ViewControllerMain: Addlog {
    func addlog(logrecord: String) {
        if self.log == nil {
            self.log = [String]()
        }
        let dateformatter = Dateandtime().setDateformat()
        let logtime = dateformatter.string(from: Date())
        self.log!.append(logtime + ": " + logrecord)
    }
}

extension ViewControllerMain: Information {
    func getInformation() -> [String] {
        return self.log ?? []
    }
}

extension ViewControllerMain: DismissViewController {
    func dismiss_view(viewcontroller: NSViewController) {
        self.dismiss(viewcontroller)
    }
}

extension ViewControllerMain: Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata() {
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

extension ViewControllerMain: ScheduledTaskWorking {
    func start() {
        globalMainQueue.async(execute: { () -> Void in
            self.progress.startAnimation(nil)
            self.progresslabel.isHidden = false
            self.statuslight.image = #imageLiteral(resourceName: "green")
        })
    }
}

extension ViewControllerMain: Sendprocessreference {
    func sendprocessreference(process: Process?) {
        ViewControllerReference.shared.process = process
    }

    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }
}

extension ViewControllerMain: UpdateProgress {
    func processTermination() {
        globalMainQueue.async(execute: { () -> Void in
            self.progress.stopAnimation(nil)
            self.progresslabel.isHidden = true
        })
        guard ViewControllerReference.shared.completeoperation != nil else {
            self.delayWithSeconds(5) {
                self.schedulesortedandexpanded = ScheduleSortedAndExpand()
                self.startfirstscheduledtask()
            }
            return
        }
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
        ViewControllerReference.shared.completeoperation!.finalizeScheduledJob(outputprocess: self.outputprocess)
        self.backupnowbutton.isEnabled = true
    }

    func fileHandler() {
        //
    }
}

extension ViewControllerMain: GetConfigurationsObject {
    func getconfigurationsobject() -> Configurations? {
        return self.configurations
    }
}

extension ViewControllerMain: GetSchedulesObject {
    func getschedulesobject() -> Schedules? {
        return self.schedules
    }
}

extension ViewControllerMain: GetSortedandExpandedObject {
    func getsortedandexpandeobject() -> ScheduleSortedAndExpand? {
        return self.schedulesortedandexpanded
    }
}

extension ViewControllerMain: ErrorOutput {
    func erroroutput() {
        //
    }
}

extension ViewControllerMain: RsyncError {
    func rsyncerror() {
        //
    }
}

extension ViewControllerMain: Fileerror {
    func errormessage(errorstr: String, errortype: Fileerrortype) {
        self.logDelegate?.addlog(logrecord: errorstr)
    }
}

extension ViewControllerMain: ReloadData {
    func reloaddata(profilename: String?) {
        guard profilename != nil else {
            if self.profilename == nil {
                globalMainQueue.async(execute: { () -> Void in
                     self.profileinfo.stringValue = "Profile: default"
                })
                return
            }
            self.profilename = nil
            self.profilescombobox.stringValue = "Default profile"
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            return
        }
        guard profilename == self.profilename else {
            self.profilename = profilename
            globalMainQueue.async(execute: { () -> Void in
                self.profileinfo.stringValue = "Profile: " + self.profilename!
                self.profilescombobox.stringValue = self.profilename!
            })
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            return
        }
    }
}

extension ViewControllerMain: GetSchedulesSortedAndExpanded {
    func getschedulessortedandexpanded() -> ScheduleSortedAndExpand? {
        return self.schedulesortedandexpanded
    }
}

extension ViewControllerMain: GetTCPconnections {
    func gettcpconnections() -> TCPconnections? {
        return self.schedulesortedandexpanded?.tcpconnections
    }
}

extension ViewControllerMain: RsyncOSXschedversion {
    func currentversion(version: String) {
         globalMainQueue.async(execute: { () -> Void in
            self.rsyncosxschedversion.stringValue = "RsyncOSXsched version: " + version
         })
    }

    func notifyNewVersion() {
        globalMainQueue.async(execute: { () -> Void in
            self.newversion.isHidden = false
        })
    }
}
