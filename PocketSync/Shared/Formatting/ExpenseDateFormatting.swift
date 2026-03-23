//
//  ExpenseDateFormatting.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

extension Date {
    var expenseTimelineLabel: String {
        let calendar = Calendar.current

        if calendar.isDateInToday(self) {
            return "오늘 \(Self.timeFormatter.string(from: self))"
        }

        if calendar.isDateInYesterday(self) {
            return "어제 \(Self.timeFormatter.string(from: self))"
        }

        return Self.dayFormatter.string(from: self)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }()
}
