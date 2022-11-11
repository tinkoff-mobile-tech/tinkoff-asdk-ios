//
//  Date+Ext.swift
//  TinkoffASDKCore
//
//  Created by Ivan Glushko on 08.11.2022.
//

import Foundation

extension Date {

    func getTimezoneOffset() -> Int {
        let calendar = Calendar.current
        var utcCalendar = Calendar.current
        guard let utcTimezone = TimeZone(abbreviation: "UTC") else { return .zero }
        utcCalendar.timeZone = utcTimezone

        guard let startDateHour = utcCalendar.dateComponents([.hour], from: self).hour,
              let endDateHour = calendar.dateComponents([.hour], from: self).hour
        else {
            return .zero
        }
        let hourDiff = endDateHour - startDateHour
        let startDate = self
        let endDate = addingTimeInterval(Double(hourDiff) * 3600.0)
        let diffSeconds = Int(endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970)
        let minutes = diffSeconds / 60
        return minutes
    }
}
