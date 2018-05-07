//
//  completeScheduledOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new waiter time.
final class CompleteScheduledOperation: SetScheduledTask, SetConfigurations, SetSchedules, Setlog {

    // weak var startTimerDelegate: StartTimer?
    private var date: Date?
    private var dateStart: Date?
    private var dateformatter: DateFormatter?
    private var hiddenID: Int?
    private var schedule: String?
    private var index: Int?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        // Write result to Schedule
        let datestring = self.dateformatter!.string(from: date!)
        let dateStartstring = self.dateformatter!.string(from: dateStart!)
        let number = Numbers(outputprocess: outputprocess)
        let numberstring = number.stats(numberOfFiles: nil, sizeOfFiles: nil)
        self.logDelegate?.addlog(logrecord: "Adding result to log: " + numberstring)
        self.schedules!.addresultschedule(self.hiddenID!, dateStart: dateStartstring, result: numberstring, date: datestring, schedule: schedule!)
        _ = Notifications().showNotification(message: datestring + " " + numberstring)
        // Writing timestamp to configuration
        self.configurations!.setCurrentDateonConfigurationQuickbackup(self.index!, outputprocess: outputprocess)
    }

    init (dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.dateformatter = Tools().setDateformat()
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = self.configurations!.getIndex(hiddenID!)
    }
}
