//
//  Extensions.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 07.02.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Foundation
import Cocoa

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
        self.progress.startAnimation(nil)
        self.statuslight.image = #imageLiteral(resourceName: "green")
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
        self.progress.stopAnimation(nil)
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
        return self.sortedandexpanded
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
    // Used in view of all tasks
    // Returns time in seconds
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
}

protocol Updatestatuslight: class {
    func updatestatuslight(color: status)
}
