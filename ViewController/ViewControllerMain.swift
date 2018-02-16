//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

import Cocoa
import Foundation


class ViewControllerMain: NSViewController, Coloractivetask, Delay {
    
    // Abort button
    @IBAction func mocup(_ sender: NSButton) {
        if ViewControllerReference.shared.executeschedulesmocup == true {
            ViewControllerReference.shared.executeschedulesmocup = false
            self.addlog(logrecord: "Mocup mode DISABLED.")
        } else {
            ViewControllerReference.shared.executeschedulesmocup = true
            self.addlog(logrecord: "Mocup mode ENABLED.")
        }
        self.reloadsortedandrefreshtabledata()
    }
    
    // Information about logs
    var viewControllerInformation: NSViewController? {
        return (self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "StoryboardInformationID"))
            as? NSViewController)!
    }
    
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var progress: NSProgressIndicator!
    @IBOutlet weak var profilescombobox: NSComboBox!
    @IBOutlet weak var profileinfo: NSTextField!
    @IBOutlet weak var rsyncosxbutton: NSButton!
    @IBOutlet weak var statuslight: NSImageView!
    @IBOutlet weak var info: NSTextField!
    
    var configurations: Configurations?
    var schedules: Schedules?
    var schedulesortedandexpanded: ScheduleSortedAndExpand?
    var outputprocess: OutputProcess?
    var profilename: String?
    var tools: Tools?
    var log: [String]?
    
    private var profilesArray: [String]?
    private var profile: Profiles?
    private var useprofile: String?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        ViewControllerReference.shared.viewControllermain = self
        self.configurations = Configurations(profile: self.profilename)
        self.schedules = Schedules(profile: self.profilename)
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstcheduledtask()
        /*
        self.tools = Tools()
        self.tools?.testAllremoteserverConnections()
        */
        
	}
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setprofiles()
        self.checkforrunning()
        self.info(num: -1)
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
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

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
    
    @IBAction func abort(_ sender: NSButton) {
        ViewControllerReference.shared.process?.terminate()
        self.progress.stopAnimation(nil)
        self.reload()
    }
    
	@IBAction func closeButtonAction(_ sender: NSButton) {
		NSApp.terminate(self)
	}
    
    @IBAction func openRsyncOSX(_ sender: NSButton) {
        let pathtorsyncosxapp: String = ViewControllerReference.shared.pathrsyncosx! + "/" + ViewControllerReference.shared.namersyncosx
        NSWorkspace.shared.open(URL(fileURLWithPath: pathtorsyncosxapp))
        NSApp.terminate(self)
    }

    @IBAction func selectprofile(_ sender: NSComboBox) {
        self.tools = nil
        self.reload()
    }
    
    @IBAction func viewlogg(_ sender: NSButton) {
        self.presentViewControllerAsSheet(self.viewControllerInformation!)
    }
    
    private func reload() {
        self.info(num: -1)
        guard self.profilesArray != nil else { return }
        guard self.profilescombobox.indexOfSelectedItem > -1 else {
            self.addlog(logrecord: "Profile: default loaded.")
            self.profileinfo.stringValue = "Profile: default"
            self.profilename = nil
            self.createandreloadconfigurations()
            self.createandreloadschedules()
            self.startfirstcheduledtask()
            return
        }
        self.profilename = self.profilesArray![self.profilescombobox.indexOfSelectedItem]
        self.profileinfo.stringValue = "Profile: " + self.profilename!
        self.addlog(logrecord: "Profile: " + self.profilename! + " loaded.")
        self.createandreloadconfigurations()
        self.createandreloadschedules()
        self.startfirstcheduledtask()
         /*
        if self.tools == nil {
             self.tools = Tools()
             self.tools?.testAllremoteserverConnections()
        }
        */
    }
    
    func startfirstcheduledtask() {
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        ViewControllerReference.shared.timerTaskWaiting?.invalidate()
        ViewControllerReference.shared.dispatchTaskWaiting = nil
        ViewControllerReference.shared.timerTaskWaiting = nil
        _ = OperationFactory(factory: .timer)
    }
    
    func createandreloadschedules() {
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
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.schedules?.scheduledTasks = self.schedulesortedandexpanded?.firstscheduledtask()
        ViewControllerReference.shared.scheduledTask = self.schedulesortedandexpanded?.firstscheduledtask()
    }
    
    func createandreloadconfigurations() {
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
        self.profile = Profiles()
        self.profilesArray = self.profile!.getDirectorysStrings()
        self.profilescombobox.removeAllItems()
        guard self.profilesArray != nil else { return }
        self.profilescombobox.addItems(withObjectValues: (self.profilesArray!))
    }
    
    private func info (num: Int) {
        globalMainQueue.async(execute: { () -> Void in
            switch num {
            case 1:
                self.info.stringValue = "One or more remote sites not avaliable...."
            default:
                self.info.stringValue = ""
            }
        })
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
        let hiddenID: Int = (object.value(forKey: "hiddenID") as? Int)!
        switch tableColumn!.identifier.rawValue {
        case "scheduleID" :
            if self.schedulesortedandexpanded != nil {
                let schedule: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID, number: false)
                return schedule ?? ""
            }
        case "batchCellID" :
            return object[tableColumn!.identifier] as? Int!
        case "offsiteServerCellID":
            if (object[tableColumn!.identifier] as? String)!.isEmpty {
                return "localhost"
            } else {
                return object[tableColumn!.identifier] as? String
            }
        case "inCellID":
            if self.schedulesortedandexpanded != nil {
                let taskintime: String? = self.schedulesortedandexpanded!.sortandcountscheduledonetask(hiddenID, number: true)
                return taskintime ?? ""
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
        return nil
    }

}

extension ViewControllerMain: Updatestatuslight {
    func updatestatuslight(color: status) {
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
        let dateformatter = Tools().setDateformat()
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
        self.dismissViewController(viewcontroller)
    }
}

extension ViewControllerMain: Reloadsortedandrefresh {
    func reloadsortedandrefreshtabledata() {
        self.schedulesortedandexpanded = ScheduleSortedAndExpand()
        self.startfirstcheduledtask()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
}

protocol Attributedestring: class {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

protocol Coloractivetask {
    var colorindex: Int? { get }
}

extension Coloractivetask {
    var colorindex: Int? {
        return self.color()
    }
    
    func color() -> Int? {
        if let dict: NSDictionary = ViewControllerReference.shared.scheduledTask {
            if let hiddenID: Int = dict.value(forKey: "hiddenID") as? Int {
                return hiddenID
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: class {
    func processTermination()
    func fileHandler()
}

// Protocol for returning object Configurations
protocol GetConfigurationsObject: class {
    func getconfigurationsobject() -> Configurations?
    func createandreloadconfigurations()
}

protocol SetConfigurations {
    weak var configurationsDelegate: GetConfigurationsObject? { get }
    var configurations: Configurations? { get }
}

extension SetConfigurations {
    weak var configurationsDelegate: GetConfigurationsObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var configurations: Configurations? {
        return self.configurationsDelegate?.getconfigurationsobject()
    }
}

// Protocol for returning object configurations data
protocol GetSchedulesObject: class {
    func getschedulesobject() -> Schedules?
    func createandreloadschedules()
}

protocol SetSchedules {
    weak var schedulesDelegate: GetSchedulesObject? { get }
    var schedules: Schedules? { get }
}

extension SetSchedules{
    weak var schedulesDelegate: GetSchedulesObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var schedules: Schedules? {
        return self.schedulesDelegate?.getschedulesobject()
    }
}

// Protocol for returning object sorted and expanded
protocol GetSortedandExpandedObject: class {
    func getsortedandexpandeobject() -> ScheduleSortedAndExpand?
}

protocol SetSortedAndExpanded {
    weak var sortedandexpandedDelegate: GetSortedandExpandedObject? { get }
    var sortedandexpanded: ScheduleSortedAndExpand? { get }
}

extension SetSortedAndExpanded {
    weak var sortedandexpandedDelegate: GetSortedandExpandedObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var sortedandexpanded: ScheduleSortedAndExpand? {
        return self.sortedandexpandedDelegate?.getsortedandexpandeobject()
    }
}


extension ViewControllerMain: ScheduledTaskWorking {
    func start() {
        globalMainQueue.async(execute: { () -> Void in
            self.progress.startAnimation(nil)
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
        ViewControllerReference.shared.completeoperation!.finalizeScheduledJob(outputprocess: self.outputprocess)
        globalMainQueue.async(execute: { () -> Void in
            self.progress.stopAnimation(nil)
        })
        self.startfirstcheduledtask()
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
    func fileerror(errorstr: String, errortype: Fileerrortype) {
        //
    }
}

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledTaskWorking: class {
    func start()
}

protocol SetScheduledTask {
    weak var scheduleJob: ScheduledTaskWorking? { get }
}

extension SetScheduledTask {
    weak var scheduleJob: ScheduledTaskWorking? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
}

protocol Sendprocessreference: class {
    func sendprocessreference(process: Process?)
    func sendoutputprocessreference(outputprocess: OutputProcess?)
}

// Protocol for starting next scheduled job
protocol StartNextTask: class {
    // func startanyscheduledtask()
    func startfirstcheduledtask()
}

protocol SecondsBeforeStart {
    func secondsbeforestart() -> Double
}

extension SecondsBeforeStart {
    // Calculation of time to a spesific date
    private func timeDoubleSeconds (_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }
    
    private func seconds (_ startdate: Date, enddate: Date?) -> Double {
        if enddate == nil {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }
    
    func secondsbeforestart() -> Double {
        var secondsToWait: Double?
        let scheduledJobs = ScheduleSortedAndExpand()
        if let dict = scheduledJobs.firstscheduledtask() {
            let dateStart: Date = (dict.value(forKey: "start") as? Date)!
            secondsToWait = self.timeDoubleSeconds(dateStart, enddate: nil)
        }
        return secondsToWait ?? 0
    }
}

enum status {
    case red
    case green
    case yellow
}

protocol Updatestatuslight: class {
    func updatestatuslight(color: status)
}

protocol Updatestatustcpconnections: class {
    func updatestatustcpconnections()
}

protocol Addlog: class {
    func addlog( logrecord: String)
}

protocol Setlog  {
    weak var logDelegate: Addlog? { get }
}

extension Setlog {
    weak var logDelegate: Addlog? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
}

protocol Information: class {
    func getInformation () -> [String]
}

protocol GetInformation {
    weak var informationDelegateMain: Information? {get}
}

extension GetInformation {
    weak var informationDelegateMain: Information? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    
    func getinfo() -> [String] {
        return self.informationDelegateMain?.getInformation() ?? []
    }
}

// Protocol for dismissing a viewcontroller
protocol DismissViewController: class {
    func dismiss_view(viewcontroller: NSViewController)
}
protocol SetDismisser {
    weak var dismissDelegateMain: DismissViewController? {get}
    func dismissview(viewcontroller: NSViewController)
}

extension SetDismisser {
    weak var dismissDelegateMain: DismissViewController? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    
    func dismissview(viewcontroller: NSViewController) {
        self.dismissDelegateMain?.dismiss_view(viewcontroller: (self as? NSViewController)!)
    }
}

// Protocol for doing a refresh of tabledata
protocol Reloadsortedandrefresh: class {
    func reloadsortedandrefreshtabledata()
}

