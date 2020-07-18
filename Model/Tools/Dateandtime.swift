//
//  Dateandtime.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

final class Dateandtime {
    // Calculate seconds from now to startdate
    private func seconds(_ startdate: Date, enddate: Date?) -> Double {
        if enddate == nil {
            return startdate.timeIntervalSinceNow
        } else {
            return enddate!.timeIntervalSince(startdate)
        }
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    // Returns time in seconds
    func timeDoubleSeconds(_ startdate: Date, enddate: Date?) -> Double {
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        return seconds
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString(_ startdate: Date, enddate: Date?) -> String {
        var result: String?
        let seconds: Double = self.seconds(startdate, enddate: enddate)
        let (hr, minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        // hr, min, 60 * secf
        if hr == 0, min == 0 {
            result = String(format: "%.0f", 60 * secf) + " " + NSLocalizedString("secs", comment: "datetime")
        } else if hr == 0, min < 60 {
            result = String(format: "%.0f", min) + " " + NSLocalizedString("mins", comment: "datetime")
                + String(format: "%.0f", 60 * secf) + " " + "secs"
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + " " + NSLocalizedString("hours", comment: "datetime")
                + String(format: "%.0f", min) + " " + "mins"
        } else {
            result = String(format: "%.0f", hr / 24) + " " + NSLocalizedString("days", comment: "datetime")
        }
        if secf <= 0 {
            result = "... working ..."
        }
        return result!
    }

    // Calculation of time to a spesific date
    // Used in view of all tasks
    func timeString(_ seconds: Double) -> String {
        var result: String?
        let (hr, minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        // hr, min, 60 * secf
        if hr == 0, min == 0 {
            result = String(format: "%.0f", 60 * secf) + "s"
        } else if hr == 0, min < 60 {
            if secf > 0.9 {
                result = String(format: "%.0f", min + 1) + "m "
            } else {
                if (60 * secf) > 15 {
                    result = String(format: "%.0f", min) + "m " + String(format: "%.0f", 60 * secf) + "s"
                } else {
                    result = String(format: "%.0f", min) + "m "
                }
            }
        } else if hr < 25 {
            result = String(format: "%.0f", hr) + NSLocalizedString("h", comment: "datetime") + " "
                + String(format: "%.0f", min) + "m"
        } else {
            result = String(format: "%.0f", hr / 24) + "d"
        }
        return result ?? ""
    }
}

extension Date {
    func dateByAddingDays(_ days: Int) -> Date {
        let calendar = Calendar.current
        var dateComponent = DateComponents()
        dateComponent.day = days
        return (calendar as NSCalendar).date(byAdding: dateComponent,
                                             to: self, options: NSCalendar.Options.matchNextTime)!
    }

    // Returns a DateComponent value with number of days away from a specified date
    var dayssincenow: DateComponents {
        let now = Date()
        return Calendar.current.dateComponents([.day], from: self, to: now)
    }

    var weekssincenowplusoneweek: DateComponents {
        let now = Date()
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: now.dateByAddingDays(7))
    }

    func localized_string_from_date() -> String {
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        return dateformatter.string(from: self)
    }

    func en_us_string_from_date() -> String {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter.string(from: self)
    }
}

extension String {
    func en_us_date_from_string() -> Date {
        let dateformatter = DateFormatter()
        dateformatter.locale = Locale(identifier: "en_US")
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .short
        dateformatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateformatter.date(from: self) ?? Date()
    }

    var setdatesuffixbackupstring: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "-yyyy-MM-dd"
        return self + formatter.string(from: Date())
    }
}
