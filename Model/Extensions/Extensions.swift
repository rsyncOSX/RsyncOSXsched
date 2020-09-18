//
//  Extensions.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 08.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Cocoa
import Foundation

enum Status {
    case red
    case green
    case yellow
}

protocol Updatestatuslight: AnyObject {
    func updatestatuslight(color: Status)
}

protocol Updatestatustcpconnections: AnyObject {
    func updatestatustcpconnections()
}

protocol Addlog: AnyObject {
    func addlog(logrecord: String)
}

protocol Setlog {
    var logDelegate: Addlog? { get }
}

extension Setlog {
    var logDelegate: Addlog? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
}

protocol Information: AnyObject {
    func getInformation() -> [String]
}

protocol GetInformation {
    var informationDelegateMain: Information? { get }
}

extension GetInformation {
    var informationDelegateMain: Information? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    func getinfo() -> [String] {
        return self.informationDelegateMain?.getInformation() ?? []
    }
}

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledTaskStartanimation: AnyObject {
    func startanimation()
}

protocol ScheduledTaskAnimation {
    var scheduletaskanimation: ScheduledTaskStartanimation? { get }
}

extension ScheduledTaskAnimation {
    var scheduletaskanimation: ScheduledTaskStartanimation? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }
}

protocol SendOutputProcessreference: AnyObject {
    func sendoutputprocessreference(outputprocess: OutputProcess?)
}

protocol SecondstoStart {
    func secondstostart() -> Double
}

extension SecondstoStart {
    // Calculation of time to a spesific date
    private func timeindoubleseconds(_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    private func seconds(_ startdate: Date, enddate: Date?) -> Double {
        return enddate?.timeIntervalSince(startdate) ?? startdate.timeIntervalSinceNow
    }

    func secondstostart() -> Double {
        var seconds: Double?
        weak var schedulesDelegate: GetSortedandExpandedObject?
        schedulesDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        let scheduledjobs = schedulesDelegate?.getsortedandexpandeobject()
        if let dict = scheduledjobs?.getfirstscheduledtask() {
            let dateStart: Date = (dict.value(forKey: "start") as? Date)!
            seconds = self.timeindoubleseconds(dateStart, enddate: nil)
        }
        return seconds ?? 0
    }
}

protocol Attributedestring: AnyObject {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString
}

extension Attributedestring {
    func attributedstring(str: String, color: NSColor, align: NSTextAlignment) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: str)
        let range = (str as NSString).range(of: str)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        attributedString.setAlignment(align, range: range)
        return attributedString
    }
}

// Protocol for either completion of work or update progress when Process discovers a
// process termination and when filehandler discover data
protocol UpdateProgress: AnyObject {
    func processTermination()
}

// Protocol for returning object Configurations
protocol GetConfigurationsObject: AnyObject {
    func getconfigurationsobject() -> Configurations?
    func createandreloadconfigurations()
}

protocol SetConfigurations {
    var configurationsDelegate: GetConfigurationsObject? { get }
    var configurations: Configurations? { get }
}

extension SetConfigurations {
    var configurationsDelegate: GetConfigurationsObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    var configurations: Configurations? {
        return self.configurationsDelegate?.getconfigurationsobject()
    }
}

// Protocol for returning object configurations data
protocol GetSchedulesObject: AnyObject {
    func getschedulesobject() -> Schedules?
    func createandreloadschedules()
}

protocol SetSchedules {
    var schedulesDelegate: GetSchedulesObject? { get }
    var schedules: Schedules? { get }
}

extension SetSchedules {
    var schedulesDelegate: GetSchedulesObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    var schedules: Schedules? {
        return self.schedulesDelegate?.getschedulesobject()
    }
}

// Protocol for returning object sorted and expanded
protocol GetSortedandExpandedObject: AnyObject {
    func getsortedandexpandeobject() -> ScheduleSortedAndExpand?
}

protocol SetSortedAndExpanded {
    var sortedandexpandedDelegate: GetSortedandExpandedObject? { get }
    var sortedandexpanded: ScheduleSortedAndExpand? { get }
}

extension SetSortedAndExpanded {
    var sortedandexpandedDelegate: GetSortedandExpandedObject? {
        return ViewControllerReference.shared.viewControllermain as? ViewControllerMain
    }

    var sortedandexpanded: ScheduleSortedAndExpand? {
        return self.sortedandexpandedDelegate?.getsortedandexpandeobject()
    }
}
