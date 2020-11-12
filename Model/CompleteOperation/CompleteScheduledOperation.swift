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
final class CompleteScheduledOperation: ScheduledTaskAnimation, SetConfigurations, SetSchedules, Setlog {
    weak var reloaddataDelegate: ReloadData?
    var date: Date?
    var hiddenID: Int?
    var index: Int?
    var dict: NSDictionary?

    // Function for finalizing the Scheduled job
    // The Operation object sets reference to the completeScheduledOperation in self.schedules!.operation
    // This function is executed when rsyn process terminates
    func finalizeScheduledJob(outputprocess: OutputProcess?) {
        let number = Numbers(outputprocess: outputprocess)
        let datestring = date?.en_us_string_from_date()
        let numberstring = number.stats()
        let message = (datestring ?? "") + " " + numberstring

        if let index = self.configurations?.getIndex(hiddenID ?? -1) {
            self.configurations?.setCurrentDateonConfiguration(index: index, outputprocess: outputprocess)
            Notifications().showNotification(message: message)
        }
        self.logDelegate?.addlog(logrecord: NSLocalizedString("Adding result to log:", comment: "Logg")
            + " " + numberstring)
    }

    init(dict: NSDictionary) {
        self.dict = dict
        self.date = dict.value(forKey: DictionaryStrings.start.rawValue) as? Date
        self.hiddenID = dict.value(forKey: DictionaryStrings.hiddenID.rawValue) as? Int
    }
}
