//
//
//  Created by Thomas Evensen on 07/05/16.
//  Copyright © 2016 Thomas Evensen. All rights reserved.
//
// swiftlint:disable line_length

import Foundation

// Class for creating and preparing the scheduled task
// The class set up a Timer for waiting for the first task to be
// executed. The class creates a object holding all jobs in
// queue for execution. The class calculates the number of
// seconds to wait before the firste scheduled task is executed.
// It set up a Timer to wait for the first job to execute. And when
// time is due it create a Operation object and dump the object onto the 
// OperationQueue for imidiate execution.

final class ScheduleOperationTimer: SecondsBeforeStart, SetSortedAndExpanded, Setlog {

    private var timerTaskWaiting: Timer?

    @objc private func executetasktest() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        globalMainQueue.async(execute: { [weak self] in
            let queue = OperationQueue()
            // Create the Operation object which executes the scheduled job
            let task = ExecuteTaskTimerMocup()
            // Add the Operation object to the queue for execution.
            // The queue executes the main() task whenever everything is ready for execution
            queue.addOperation(task)
        })
    }

    @objc private func executetask() {
        // Start the task in BackgroundQueue
        // The Process itself is executed in GlobalMainQueue
        globalMainQueue.async(execute: { [weak self] in
            let queue = OperationQueue()
            // Create the Operation object which executes the scheduled job
            let task = ExecuteTaskTimer()
            // Add the Operation object to the queue for execution.
            // The queue executes the main() task whenever everything is ready for execution
            queue.addOperation(task)
        })
    }

    init() {
        weak var updatestatuslightDelegate: Updatestatuslight?
        updatestatuslightDelegate = ViewControllerReference.shared.viewControllermain as? ViewControllerMain
        let seconds = self.secondsbeforestart()
        guard ViewControllerReference.shared.executeschedulesmocup == false else {
            guard seconds > 0 else {
                self.logDelegate?.addlog(logrecord: "Mocup timer: no more scheduled task in queue")
                updatestatuslightDelegate?.updatestatuslight(color: .red)
                return
            }
            updatestatuslightDelegate?.updatestatuslight(color: .yellow)
            self.timerTaskWaiting = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(executetasktest), userInfo: nil, repeats: false)
            ViewControllerReference.shared.timerTaskWaiting = self.timerTaskWaiting
            self.logDelegate?.addlog(logrecord: "Mocup timer: task starts in: " + String(Int(seconds)))
            return
        }
        guard seconds > 0 else {
            self.logDelegate?.addlog(logrecord: "Timer: no more scheduled task in queue")
            updatestatuslightDelegate?.updatestatuslight(color: .red)
            return
        }
        self.timerTaskWaiting = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(executetask), userInfo: nil, repeats: false)
        ViewControllerReference.shared.scheduledTask = self.sortedandexpanded?.firstscheduledtask()
        ViewControllerReference.shared.timerTaskWaiting = self.timerTaskWaiting
        updatestatuslightDelegate?.updatestatuslight(color: .green)
    }
}
