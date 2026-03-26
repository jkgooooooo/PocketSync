//
//  HomeCalendarViews.swift
//  PocketSync
//
//  Created by Codex on 3/26/26.
//

import SwiftUI

struct WeeklyStripCalendarView: View {
    let dates: [Date]
    let selectedDate: Date
    let namespace: Namespace.ID
    let isSelectionSource: Bool
    let shouldUseMatchedSelection: Bool
    let activityLevel: (Date) -> Double
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 8
            let totalSpacing = spacing * CGFloat(max(0, dates.count - 1))
            let availableWidth = max(0, proxy.size.width - totalSpacing)
            let cellWidth = availableWidth / CGFloat(max(1, dates.count))

            HStack(spacing: spacing) {
                ForEach(dates, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let level = activityLevel(date)

                    Button {
                        onSelect(date)
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(isSelected ? Color.clear : PocketSyncTheme.panel)

                            if isSelected {
                                if shouldUseMatchedSelection {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(PocketSyncTheme.accent)
                                        .matchedGeometryEffect(
                                            id: "calendar-selection-\(date.calendarTransitionKey)",
                                            in: namespace,
                                            isSource: isSelectionSource
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(PocketSyncTheme.accent)
                                }
                            }

                            VStack(spacing: 8) {
                                Text(Self.weekdayFormatter.string(from: date))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(isSelected ? .white.opacity(0.92) : PocketSyncTheme.secondaryText)

                                Text("\(calendar.component(.day, from: date))")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)

                                Capsule()
                                    .fill(isSelected ? Color.white.opacity(0.92) : PocketSyncTheme.accent.opacity(level))
                                    .frame(width: isSelected ? 18 : max(6, 18 * level), height: 4)
                            }
                        }
                        .frame(width: cellWidth, height: 74)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .strokeBorder(
                                    isSelected ? Color.clear : (calendar.isDateInToday(date) ? PocketSyncTheme.accent.opacity(0.32) : PocketSyncTheme.line.opacity(0.1)),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 74)
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter
    }()
}

struct MonthCalendarView: View {
    let weekdaySymbols: [String]
    let dates: [Date?]
    let selectedDate: Date
    let namespace: Namespace.ID
    let isSelectionSource: Bool
    let shouldUseMatchedSelection: Bool
    let activityLevel: (Date) -> Double
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 18)
                }

                ForEach(Array(dates.enumerated()), id: \.offset) { _, date in
                    if let date {
                        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                        let isToday = calendar.isDateInToday(date)
                        let level = activityLevel(date)

                        Button {
                            onSelect(date)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(isSelected ? Color.clear : (isToday ? PocketSyncTheme.accent.opacity(0.12) : Color.clear))

                                if isSelected {
                                    if shouldUseMatchedSelection {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(PocketSyncTheme.accent)
                                            .matchedGeometryEffect(
                                                id: "calendar-selection-\(date.calendarTransitionKey)",
                                                in: namespace,
                                                isSource: isSelectionSource
                                            )
                                    } else {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(PocketSyncTheme.accent)
                                    }
                                }

                                VStack(spacing: 6) {
                                    Text("\(calendar.component(.day, from: date))")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)

                                    Circle()
                                        .fill(isSelected ? Color.white.opacity(0.92) : PocketSyncTheme.accent.opacity(level))
                                        .frame(width: max(4, 10 * level), height: max(4, 10 * level))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        isSelected ? Color.clear : (isToday ? PocketSyncTheme.accent.opacity(0.36) : Color.clear),
                                        lineWidth: 1
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear
                            .frame(height: 42)
                    }
                }
            }
        }
        .padding(.horizontal, 1)
    }
}
