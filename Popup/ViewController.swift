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

class ViewController: NSViewController, Coloractivetask {
    
    @IBOutlet weak var mainTableView: NSTableView!
    weak var configurations: Configurations?
    weak var schedules: Schedules?
    var schedulessortedandexpanded: ScheduleSortedAndExpand?
    
    var profile = "RsyncOSXtest"

	override func viewDidLoad() {
		super.viewDidLoad()
        self.mainTableView.delegate = self
        self.mainTableView.dataSource = self
        self.configurations = Configurations(profile: self.profile)
        self.schedules = Schedules(profile: self.profile, configuration: self.configurations)
        self.schedulessortedandexpanded = ScheduleSortedAndExpand(schedules: self.schedules, configurations: self.configurations)
        self.startfirstcheduledtask()
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

}

extension ViewController: NSTableViewDataSource {
    // Delegate for size of table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.configurations?.getConfigurationsDataSourcecountBackup()?.count ?? 0
    }
}

extension ViewController: NSTableViewDelegate, Attributedestring {
    
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


extension ViewController: StartNextTask {
    func startfirstcheduledtask() {
        // Cancel any schedeuled tasks first
        ViewControllerReference.shared.dispatchTaskWaiting?.cancel()
        _ = OperationFactory(configurations: self.configurations, schedules: self.schedules)
    }
}

extension ViewController: ScheduledTaskWorking {
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

extension ViewController: Sendprocessreference {
    func sendprocessreference(process: Process?) {
        //
    }
    
    func sendoutputprocessreference(outputprocess: OutputProcess?) {
        //
    }
}

extension ViewController: UpdateProgress {
    func processTermination() {
        //
    }
    
    func fileHandler() {
        //
    }
}

extension ViewController: ErrorOutput {
    func erroroutput() {
        //
    }
}

extension ViewController: RsyncError {
    func rsyncerror() {
        //
    }
}
