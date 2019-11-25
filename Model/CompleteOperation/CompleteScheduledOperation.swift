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

    private var date: Date?
    private var dateStart: Date?
    private var hiddenID: Int?
    private var schedule: String?
    private var index: Int?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        // Write result to Schedule
        let datestring = date?.en_us_string_from_date()
        let dateStartstring = dateStart?.en_us_string_from_date()
        let number = Numbers(outputprocess: outputprocess)
        let numberstring = number.stats(numberOfFiles: nil, sizeOfFiles: nil)
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Adding result to log:", comment: "Logg") + " " + numberstring)
        self.schedules!.addresultschedule(hiddenID: self.hiddenID!, dateStart: dateStartstring ?? "", result: numberstring, date: datestring ?? "", schedule: schedule ?? "Once")
        let message = (datestring ?? "") + " " + numberstring
        _ = Notifications().showNotification(message: message)
        self.configurations!.setCurrentDateonConfigurationQuickbackup(self.index!, outputprocess: outputprocess)
    }

    init (dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.dateStart = dict.value(forKey: "dateStart") as? Date
        self.hiddenID = (dict.value(forKey: "hiddenID") as? Int)!
        self.schedule = dict.value(forKey: "schedule") as? String
        self.index = self.configurations!.getIndex(hiddenID!)
    }
}
