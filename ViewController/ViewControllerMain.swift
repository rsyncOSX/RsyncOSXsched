//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//
//  swiftlint:disable line_length file_length cyclomatic_complexity

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
    var checkallconfiguration: CheckAllConfigurations?
    var automaticexecution: [NSDictionary]?

    private var profilesArray: [String]?
    private var profile: Files?
    var allschedules: [ConfigurationSchedule]?
    var index: Int?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.addobservers()
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
        self.info(num: 3)
        self.profilescombobox.stringValue = NSLocalizedString("Default profile", comment: "default profile")
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

    private func addobserverforreload() {
        self.reloadnotification = DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("no.blogspot.RsyncOSX.reload"), object: nil, queue: nil) { _ -> Void in
            let notification: String = NSLocalizedString("Got notification for reload", comment: "addobserverforreload")
            self.addlog(logrecord: notification)
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
        guard self.configurations!.getConfigurationsDataSourceSynchronize() != nil  else { return  }
        self.backupnowbutton.isEnabled = false
        let dict: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![self.index!]
        _ = ExecuteScheduledTask(dict: dict)
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
            let reloadinfo: String = NSLocalizedString("Profile: default loaded.", comment: "reloadinfo")
            self.addlog(logrecord: reloadinfo)
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
        let readingschedule: String = NSLocalizedString("Reading schedules for current profile", comment: "main")
        self.addlog(logrecord: readingschedule)
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
        let readingconfig: String = NSLocalizedString( "Reading configurations for current profile", comment: "main")
        self.addlog(logrecord: readingconfig)
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
                let info1: String = NSLocalizedString("Some remote sites not avaliable, see log ....", comment: "main")
                self.info.stringValue = info1
            case 2:
                let info2: String = NSLocalizedString("Executing scheduled tasks is not enabled in RsyncOSX....", comment: "main")
                self.info.stringValue = info2
            case 3:
                self.info.stringValue = FirsScheduledTask().taskintime ?? ""
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
        let onwake: String = NSLocalizedString("Activating schedules again after sleeping...", comment: "main")
        self.logDelegate?.addlog(logrecord: onwake)
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
    }

    @objc func onSleepNote(note: NSNotification) {
        let onsleep: String = NSLocalizedString("Invalidating tasks and going to sleep...", comment: "main")
        self.logDelegate?.addlog(logrecord: onsleep)
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
    }

    @objc func didMount(_ notification: NSNotification) {
        if let devicePath = notification.userInfo!["NSDevicePath"] as? String {
            let mount: String = NSLocalizedString("Mounting volumes:", comment: "main")
            self.logDelegate?.addlog(logrecord: mount + " " + devicePath)
            if self.checkallconfiguration == nil {
                self.checkallconfiguration = CheckAllConfigurations(path: devicePath)
            } else {
                self.checkallconfiguration?.allpaths?.append(devicePath)
            }
        }
    }

    @objc func didUnMount(_ notification: NSNotification) {
        if let devicePath = notification.userInfo!["NSDevicePath"] as? String {
            let unmount: String = NSLocalizedString("Unmounting volumes:", comment: "main")
            self.logDelegate?.addlog(logrecord: unmount + " " + devicePath)
            self.checkallconfiguration = nil
            self.automaticexecution = nil
        }
    }

    private func addobservers() {
        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onWakeNote(note:)),
                                                           name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver( self, selector: #selector(onSleepNote(note:)),
                                                           name: NSWorkspace.willSleepNotification, object: nil)
        if ViewControllerReference.shared.automaticexecutelocalvolumes {
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didMount(_:)),
                                                              name: NSWorkspace.didMountNotification, object: nil)
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didUnMount(_:)),
                                                              name: NSWorkspace.didUnmountNotification, object: nil)
        }
    }
}

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourceSynchronize()!.count  else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
        let hiddenID = object.value(forKey: "hiddenID") as? Int ?? -1
        let profilename = object.value(forKey: "profilename") as? String ?? NSLocalizedString("Default profile", comment: "default profile")
        switch tableColumn!.identifier.rawValue {
        case "scheduleID" :
            if self.schedulesortedandexpanded != nil {
                let schedule: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: nil, number: false)
                if schedule?.isEmpty == false {
                    switch schedule {
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
                    return ""
                }
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
        let logtime = Date().localizeDate()
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
        if self.automaticexecution == nil {
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
        } else {
            ViewControllerReference.shared.completeoperation!.finalizeScheduledJob(outputprocess: self.outputprocess)
            guard self.automaticexecution != nil else { return }
            guard self.automaticexecution!.count > 0 else {
                self.automaticexecution = nil
                self.schedulesortedandexpanded = ScheduleSortedAndExpand()
                self.startfirstscheduledtask()
                return
            }
            self.delayWithSeconds(1) {
                let dict: NSDictionary = self.automaticexecution!.removeFirst()
                _ = ExecuteScheduledTask(dict: dict)
            }
        }
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
                    self.profileinfo.stringValue = NSLocalizedString("Profile:", comment: "main") + " " + NSLocalizedString("default", comment: "main")
                })
                return
            }
            self.profilename = nil
            self.profilescombobox.stringValue = NSLocalizedString("Profile", comment: "default profile") + " default"
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            return
        }
        guard profilename == self.profilename else {
            self.profilename = profilename
            globalMainQueue.async(execute: { () -> Void in
                self.profileinfo.stringValue = NSLocalizedString("Profile:", comment: "main") + " " + self.profilename!
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

extension ViewControllerMain: NewVersionDiscovered {
    func currentversion(version: String) {
         globalMainQueue.async(execute: { () -> Void in
            self.rsyncosxschedversion.stringValue = NSLocalizedString("RsyncOSXsched version:", comment: "main") + " " + version
         })
    }

    func notifyNewVersion() {
        globalMainQueue.async(execute: { () -> Void in
            self.newversion.isHidden = false
        })
    }
}

extension ViewControllerMain: Startautomaticexecution {
    func startautomaticexecution() {
        self.automaticexecution = self.checkallconfiguration?.automaticexecution
        guard  self.automaticexecution != nil else { return }
        guard self.automaticexecution!.count > 0 else {
            self.automaticexecution = nil
            return
        }
        let dict: NSDictionary = self.automaticexecution!.removeFirst()
        _ = ExecuteScheduledTask(dict: dict)
    }
}
