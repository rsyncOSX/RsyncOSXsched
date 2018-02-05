//
//  ViewController.swift
//  Popup
//
//  Created by Maxim on 10/21/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

import Cocoa
import Foundation

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
}

protocol SetSchedules {
    weak var schedulesDelegate: GetSchedulesObject? {get}
    var schedules: Schedules? {get}
}

extension SetSchedules {
    weak var schedulesDelegate: GetSchedulesObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
    var schedules: Schedules? {
        return self.schedulesDelegate?.getschedulesobject()
    }
}

class ViewControllerMain: NSViewController, Coloractivetask {
    
    @IBOutlet weak var mainTableView: NSTableView!
    var configurations: Configurations?
    var schedules: Schedules?
    var schedulessortedandexpanded: ScheduleSortedAndExpand?
    private var outputprocess: OutputProcess?

	override func viewDidLoad() {
		super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.configurations = ViewControllerReference.shared.loaddata?.configurations
        self.schedules = ViewControllerReference.shared.loaddata?.schedules
        self.schedulessortedandexpanded = ViewControllerReference.shared.loaddata?.schedulessortedandexpanded
        ViewControllerReference.shared.viewControllermain = self
	}
    
    override func viewDidAppear() {
        super.viewDidAppear()
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func closeButtonAction(_ sender: NSButton) {
		NSApp.terminate(self)
	}
    
    @IBAction func openRsyncOSX(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(fileURLWithPath: "/Volumes/Home/thomas/Applications/RsyncOSX.app"))
        NSApp.terminate(self)
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
        var number: Int?
        var taskintime: String?
        let hiddenID: Int = (object.value(forKey: "hiddenID") as? Int)!
        switch tableColumn!.identifier.rawValue {
        case "numberCellID" :
            if self.schedulessortedandexpanded != nil {
                number = self.schedulessortedandexpanded!.countscheduledtasks(hiddenID).0
            }
            if number ?? 0 > 0 {
                let returnstr = String(number!)
                if let color = self.colorindex, color == hiddenID {
                    return self.attributedstring(str: returnstr, color: NSColor.red, align: .center)
                } else {
                    return returnstr
                }
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
            if self.schedulessortedandexpanded != nil {
                taskintime = self.schedulessortedandexpanded!.sortandcountscheduledonetask(hiddenID)
                return taskintime ?? ""
            }
        default:
            return object[tableColumn!.identifier] as? String
        }
        return nil
    }
    
}


extension ViewControllerMain: StartNextTask {
    func startfirstcheduledtask() {
        // Cancel any schedeuled tasks first
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        _ = OperationFactory()
        ViewControllerReference.shared.scheduledTask = self.schedulessortedandexpanded?.allscheduledtasks()
    }
}

extension ViewControllerMain: ScheduledTaskWorking {
    func start() {
        //
    }
    
    func completed() {
        //
    }
    
    func notifyScheduledTask(config: Configuration?) {
        //
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
        ViewControllerReference.shared.loaddata = nil
        ViewControllerReference.shared.loaddata = LoadData()
        self.configurations = ViewControllerReference.shared.loaddata?.configurations
        self.schedules = ViewControllerReference.shared.loaddata?.schedules
        self.schedulessortedandexpanded = ViewControllerReference.shared.loaddata?.schedulessortedandexpanded
        globalMainQueue.async(execute: { () -> Void in
            self.mainTableView.reloadData()
        })
    }
    
    func fileHandler() {
        //
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

