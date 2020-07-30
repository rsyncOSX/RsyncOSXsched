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

    @IBOutlet var mainTableView: NSTableView!
    @IBOutlet var progress: NSProgressIndicator!
    @IBOutlet var profileinfo: NSTextField!
    @IBOutlet var rsyncosxbutton: NSButton!
    @IBOutlet var statuslight: NSImageView!
    @IBOutlet var info: NSTextField!
    @IBOutlet var progresslabel: NSTextField!
    @IBOutlet var newversion: NSTextField!
    @IBOutlet var rsyncosxschedversion: NSTextField!
    @IBOutlet var backupnowbutton: NSButton!
    @IBOutlet var profilepopupbutton: NSPopUpButton!

    var configurations: Configurations?
    var schedules: Schedules?
    var schedulesortedandexpanded: ScheduleSortedAndExpand?
    var outputprocess: OutputProcess?
    var profilename: String?
    var log: [String]?
    var reloadnotification: NSObjectProtocol?
    var checkallconfiguration: CheckAllConfigurations?
    var automaticexecution: [NSDictionary]?

    var profilesArray: [String]?
    var profile: Files?
    var allschedules: [ConfigurationSchedule]?
    var index: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Read user configuration
        if let userconfiguration = PersistentStorageUserconfiguration().readuserconfiguration() {
            _ = Userconfiguration(userconfigRsyncOSX: userconfiguration)
        }
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
        self.initpopupbutton()
        self.info(num: 3)
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    private func addobserverforreload() {
        self.reloadnotification = DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("no.blogspot.RsyncOSX.reload"), object: nil, queue: nil) { _ -> Void in
            let notification: String = NSLocalizedString("Got notification for reload", comment: "addobserverforreload")
            self.addlog(logrecord: notification)
            self.initpopupbutton()
            self.schedulesortedandexpanded = ScheduleSortedAndExpand()
            self.startfirstscheduledtask()
        }
    }

    @IBAction func backupnow(_: NSButton) {
        if let index = self.index {
            guard self.configurations?.getConfigurationsDataSourceSynchronize() != nil else { return }
            self.backupnowbutton.isEnabled = false
            if let dict: NSDictionary = self.configurations?.getConfigurationsDataSourceSynchronize()![index] {
                if let executepretask = dict.value(forKey: "executepretask") as? Int {
                    if executepretask == 1 {
                        _ = ExecuteScheduledTaskShellOut(dict: dict)
                    } else {
                        _ = ExecuteScheduledTask(dict: dict)
                    }
                }
            }
        }
    }

    @IBAction func abort(_: NSButton) {
        _ = InterruptProcess()
        self.progress.stopAnimation(nil)
        self.initpopupbutton()
    }

    @IBAction func closeButtonAction(_: NSButton) {
        NSApp.terminate(self)
    }

    @IBAction func openRsyncOSX(_: NSButton) {
        let running = Running()
        guard running.rsyncOSXisrunning == false else { return }
        guard running.verifyrsyncosx() == true else { return }
        NSWorkspace.shared.open(URL(fileURLWithPath: (ViewControllerReference.shared.pathrsyncosx ?? "/Applications/") + ViewControllerReference.shared.namersyncosx))
        NSApp.terminate(self)
    }

    @IBAction func viewlogg(_: NSButton) {
        self.presentAsSheet(self.viewControllerInformation!)
    }

    @IBAction func viewallschedules(_: NSButton) {
        self.presentAsSheet(self.viewControllerAllschedules!)
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
        let readingconfig: String = NSLocalizedString("Reading configurations for current profile", comment: "main")
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
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }

    private func info(num: Int) {
        globalMainQueue.async { () -> Void in
            switch num {
            case 1:
                let info1: String = NSLocalizedString("Some remote sites not avaliable, see log ....", comment: "main")
                self.info.stringValue = info1
            case 2:
                let info2: String = NSLocalizedString("Executing scheduled tasks is not enabled in RsyncOSX....", comment: "main")
                self.info.stringValue = info2
            case 3:
                self.info.stringValue = FirsScheduledTask().firsscheduledtaskintime ?? ""
            default:
                self.info.stringValue = ""
            }
        }
    }

    private func startfirstscheduledtask() {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        ViewControllerReference.shared.timerTaskWaiting = nil
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.getfirstscheduledtask()
        _ = ScheduleOperationDispatch()
        // We use Dispatch not Timer
        // _ = ScheduleOperationTimer()
    }

    @objc func onWakeNote(note _: NSNotification) {
        let onwake: String = NSLocalizedString("Activating schedules again after sleeping...", comment: "main")
        self.logDelegate?.addlog(logrecord: onwake)
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstscheduledtask()
    }

    @objc func onSleepNote(note _: NSNotification) {
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
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(onWakeNote(note:)),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(onSleepNote(note:)),
                                                          name: NSWorkspace.willSleepNotification, object: nil)
        if ViewControllerReference.shared.automaticexecutelocalvolumes {
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didMount(_:)),
                                                              name: NSWorkspace.didMountNotification, object: nil)
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(didUnMount(_:)),
                                                              name: NSWorkspace.didUnmountNotification, object: nil)
        }
    }

    func initpopupbutton() {
        var profilestrings: [String]?
        profilestrings = Files(whichroot: .profileRoot, configpath: ViewControllerReference.shared.configpath).getDirectorysStrings()
        profilestrings?.insert(NSLocalizedString("Default profile", comment: "default profile"), at: 0)
        self.profilepopupbutton.removeAllItems()
        self.profilepopupbutton.addItems(withTitles: profilestrings ?? [])
        // self.profilepopupbutton.selectItem(at: 0)
    }

    @IBAction func selectprofile(_: NSButton) {
        let selectedindex = self.profilepopupbutton.indexOfSelectedItem
        self.info(num: -1)
        self.profilename = self.profilepopupbutton.titleOfSelectedItem
        self.profileinfo.stringValue = "Profile: " + (self.profilename ?? NSLocalizedString("Profile: default loaded.", comment: "reloadinfo"))
        self.addlog(logrecord: "Profile: " + (self.profilename ?? NSLocalizedString("Profile: default loaded.", comment: "reloadinfo") + " loaded."))
        if selectedindex == 0 {
            self.profilename = nil
        }
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.info(num: 3)
    }
}

extension ViewControllerMain: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in _: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourceSynchronize()?.count ?? 0
    }
}

extension ViewControllerMain: NSTableViewDelegate, Attributedestring {
    func tableView(_: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard row < self.configurations!.getConfigurationsDataSourceSynchronize()!.count else { return nil }
        let object: NSDictionary = self.configurations!.getConfigurationsDataSourceSynchronize()![row]
        let hiddenID = object.value(forKey: "hiddenID") as? Int ?? -1
        let profilename = object.value(forKey: "profilename") as? String ?? NSLocalizedString("Default profile", comment: "default profile")
        switch tableColumn!.identifier.rawValue {
        case "scheduleID":
            if self.schedulesortedandexpanded != nil {
                let schedule: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID: hiddenID, profilename: profilename, dateStart: nil, number: false)
                if schedule?.isEmpty == false {
                    switch schedule {
                    case Scheduletype.once.rawValue:
                        return NSLocalizedString("once", comment: "main")
                    case Scheduletype.daily.rawValue:
                        return NSLocalizedString("daily", comment: "main")
                    case Scheduletype.weekly.rawValue:
                        return NSLocalizedString("weekly", comment: "main")
                    default:
                        return ""
                    }
                } else {
                    return ""
                }
            }
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
        self.backupnowbutton.isEnabled = true
    }
}

extension ViewControllerMain: Updatestatuslight {
    func updatestatuslight(color: Status) {
        globalMainQueue.async { () -> Void in
            switch color {
            case .red:
                self.statuslight.image = #imageLiteral(resourceName: "red")
            case .green:
                self.statuslight.image = #imageLiteral(resourceName: "green")
            case .yellow:
                self.statuslight.image = #imageLiteral(resourceName: "yellow")
            }
        }
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
        let logtime = Date().localized_string_from_date()
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
        globalMainQueue.async { () -> Void in
            self.mainTableView.reloadData()
        }
    }
}

extension ViewControllerMain: ScheduledTaskStartanimation {
    func startanimation() {
        globalMainQueue.async { () -> Void in
            self.progress.startAnimation(nil)
            self.progresslabel.isHidden = false
            self.statuslight.image = #imageLiteral(resourceName: "green")
        }
    }
}

extension ViewControllerMain: SendOutputProcessreference {
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        self.outputprocess = outputprocess
    }
}

extension ViewControllerMain: UpdateProgress {
    func processTermination() {
        globalMainQueue.async { () -> Void in
            self.progress.stopAnimation(nil)
            self.progresslabel.isHidden = true
        }
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
            ViewControllerReference.shared.completeoperation?.finalizeScheduledJob(outputprocess: self.outputprocess)
            self.backupnowbutton.isEnabled = true
        } else {
            ViewControllerReference.shared.completeoperation?.finalizeScheduledJob(outputprocess: self.outputprocess)
            guard self.automaticexecution != nil else { return }
            guard self.automaticexecution!.count > 0 else {
                self.automaticexecution = nil
                self.schedulesortedandexpanded = ScheduleSortedAndExpand()
                self.startfirstscheduledtask()
                return
            }
            self.delayWithSeconds(1) {
                if let dict: NSDictionary = self.automaticexecution?.removeFirst() {
                    if let executepretask = dict.value(forKey: "executepretask") as? Int {
                        if executepretask == 1 {
                            _ = ExecuteScheduledTaskShellOut(dict: dict)
                        } else {
                            _ = ExecuteScheduledTask(dict: dict)
                        }
                    }
                }
            }
        }
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

extension ViewControllerMain: RsyncError {
    func rsyncerror() {
        let errorinfo: String = NSLocalizedString("There was a rsync error", comment: "rsyncerror")
        self.addlog(logrecord: errorinfo)
    }
}

extension ViewControllerMain: Fileerror {
    func errormessage(errorstr: String, errortype _: Fileerrortype) {
        self.logDelegate?.addlog(logrecord: errorstr)
    }
}

extension ViewControllerMain: ReloadData {
    func reloaddata(profilename: String?) {
        guard profilename != nil else {
            if self.profilename == nil {
                globalMainQueue.async { () -> Void in
                    self.profileinfo.stringValue = NSLocalizedString("Profile:", comment: "main") + " " + NSLocalizedString("default", comment: "main")
                }
                return
            }
            self.profilename = nil
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            return
        }
        guard profilename == self.profilename else {
            self.profilename = profilename
            globalMainQueue.async { () -> Void in
                self.profileinfo.stringValue = NSLocalizedString("Profile:", comment: "main") + " " + (self.profilename ?? "Default profile")
            }
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
        globalMainQueue.async { () -> Void in
            self.rsyncosxschedversion.stringValue = NSLocalizedString("RsyncOSXsched version:", comment: "main") + " " + version
        }
    }

    func notifyNewVersion() {
        globalMainQueue.async { () -> Void in
            self.newversion.isHidden = false
        }
    }
}

extension ViewControllerMain: Startautomaticexecution {
    func startautomaticexecution() {
        self.automaticexecution = self.checkallconfiguration?.listofautomaticexecutions
        guard self.automaticexecution?.count ?? 0 > 0 else {
            self.automaticexecution = nil
            return
        }
        if let dict: NSDictionary = self.automaticexecution?.removeFirst() {
            if let executepretask = dict.value(forKey: "executepretask") as? Int {
                if executepretask == 1 {
                    _ = ExecuteScheduledTaskShellOut(dict: dict)
                } else {
                    _ = ExecuteScheduledTask(dict: dict)
                }
            }
        }
    }
}
