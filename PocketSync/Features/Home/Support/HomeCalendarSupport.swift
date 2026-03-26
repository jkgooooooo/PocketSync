//
//  HomeCalendarSupport.swift
//  PocketSync
//
//  Created by Codex on 3/26/26.
//

import Foundation

struct DayActivity {
    let count: Int
    let amount: Int
}

enum HomeCalendarSupport {
    static func selectedDateTitle(for date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) {
            return "오늘"
        }

        if calendar.isDateInYesterday(date) {
            return "어제"
        }

        return selectedDateFormatter.string(from: date)
    }

    static func monthDisplayTitle(for date: Date) -> String {
        monthTitleFormatter.string(from: date)
    }

    static func weekDates(for selectedDate: Date, calendar: Calendar = .current) -> [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return [selectedDate]
        }

        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: interval.start)
        }
    }

    static func monthGridDates(for displayedMonth: Date, calendar: Calendar = .current) -> [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeekInterval = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return []
        }

        let monthStart = calendar.startOfDay(for: monthInterval.start)
        let firstGridDate = firstWeekInterval.start
        let dayCount = calendar.dateComponents([.day], from: firstGridDate, to: monthInterval.end).day ?? 0

        return (0..<dayCount).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: firstGridDate) else {
                return nil
            }

            if date < monthStart || date >= monthInterval.end {
                return nil
            }

            return date
        }
    }

    static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let symbols = weekdayFormatter.shortStandaloneWeekdaySymbols ?? ["일", "월", "화", "수", "목", "금", "토"]
        let firstWeekdayIndex = max(0, calendar.firstWeekday - 1)
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }

    static func availableYears(for expenseDates: [Date], calendar: Calendar = .current) -> [Int] {
        let expenseYears = expenseDates.map { calendar.component(.year, from: $0) }
        let currentYear = calendar.component(.year, from: .now)
        let minYear = min(expenseYears.min() ?? currentYear, currentYear)
        let maxYear = currentYear
        return Array(minYear...maxYear)
    }

    static func startOfMonth(for date: Date, calendar: Calendar = .current) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? calendar.startOfDay(for: date)
    }

    static func clampedDate(in month: Date, matchingDay day: Int, calendar: Calendar = .current) -> Date? {
        let monthRange = calendar.range(of: .day, in: .month, for: month)
        let clampedDay = min(day, monthRange?.count ?? day)
        var components = calendar.dateComponents([.year, .month], from: month)
        components.day = clampedDay
        return calendar.date(from: components)
    }

    static let selectedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter
    }()

    static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "EEEEE"
        return formatter
    }()

    static let transitionKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

extension Date {
    var calendarTransitionKey: String {
        HomeCalendarSupport.transitionKeyFormatter.string(from: self)
    }
}
