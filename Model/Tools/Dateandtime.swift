//
//  Dateandtime.swift
//  RsyncOSX
//
//  Created by Thomas Evensen on 24.08.2018.
//  Copyright © 2018 Thomas Evensen. All rights reserved.
//

import Foundation

struct Dateandtime {
    // Calculation of time to a spesific date
    func timestring(seconds: Double) -> String {
        var result: String?
        let (hr, minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        // hr, min, 60 * secf
        if hr == 0, min == 0 {
            if secf < 0.9 {
                result = String(format: "%.0f", 60 * secf) + "s"
            } else {
                result = String(format: "%.0f", 1.0) + "m"
            }
        } else if hr == 0, min < 60 {
            // print(secf)
            if secf < 0.9 {
                result = String(format: "%.0f", min) + "m"
            } else {
                result = String(format: "%.0f", min + 1) + "m"
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

    var secondstonow: Int {
        let components = Set<Calendar.Component>([.second])
        return Calendar.current.dateComponents(components, from: self, to: Date()).second ?? 0
    }

    var daystonow: Int {
        let components = Set<Calendar.Component>([.day])
        return Calendar.current.dateComponents(components, from: self, to: Date()).day ?? 0
    }

    var weekstonow: Int {
        let components = Set<Calendar.Component>([.weekOfYear])
        return Calendar.current.dateComponents(components, from: self, to: Date()).weekOfYear ?? 0
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

    func long_localized_string_from_date() -> String {
        let dateformatter = DateFormatter()
        dateformatter.formatterBehavior = .behavior10_4
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .long
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
