//
//  Extensions.swift
//  RsyncOSXsched
//
//  Created by Thomas Evensen on 08.05.2018.
//  Copyright © 2018 Maxim. All rights reserved.
//

import Foundation
import Cocoa

enum Status {
    case red
    case green
    case yellow
}

protocol Updatestatuslight: class {
    func updatestatuslight(color: Status)
}

protocol Updatestatustcpconnections: class {
    func updatestatustcpconnections()
}

protocol Addlog: class {
    func addlog( logrecord: String)
}

protocol Setlog {
    var logDelegate: Addlog? { get }
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
    var informationDelegateMain: Information? {get}
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
    var dismissDelegateMain: DismissViewController? {get}
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

// Protocol when a Scehduled job is starting and stopping
// Used to informed the presenting viewcontroller about what
// is going on
protocol ScheduledTaskWorking: class {
    func start()
}

protocol SetScheduledTask {
    var scheduleJob: ScheduledTaskWorking? { get }
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
    var configurationsDelegate: GetConfigurationsObject? { get }
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
    var schedulesDelegate: GetSchedulesObject? { get }
    var schedules: Schedules? { get }
}

extension SetSchedules {
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
    var sortedandexpandedDelegate: GetSortedandExpandedObject? { get }
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
