//
//  completeScheduledOperation.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 20/01/2017.
//  Copyright © 2017 Thomas Evensen. All rights reserved.
//

import Foundation

// Class for completion of Operation objects when Process object termination.
// The object does also kicks of next scheduled job by setting new waiter time.
final class CompleteScheduledOperation: SetScheduledTask, SetConfigurations, SetSchedules, Setlog {
    private var date: Date?
    private var hiddenID: Int?
    private var index: Int?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let datestring = date?.en_us_string_from_date()
        let numberstring = number.stats()
        let message = (datestring ?? "") + " " + numberstring
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Adding result to log:", comment: "Logg")
            + " " + numberstring)
        self.configurations?.setCurrentDateonConfiguration(index: self.index!, outputprocess: outputprocess)
        Notifications().showNotification(message: message)
    }

    init(dict: NSDictionary) {
        self.date = dict.value(forKey: "start") as? Date
        self.hiddenID = dict.value(forKey: "hiddenID") as? Int ?? -1
        self.index = self.configurations!.getIndex(hiddenID!)
    }
}
