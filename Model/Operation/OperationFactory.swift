//
//  OperationFactory.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 22.10.2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

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

class OperationFactory {

    var operationDispatch: ScheduleOperationDispatch?

    init() {
        self.operationDispatch = ScheduleOperationDispatch()
    }

}
