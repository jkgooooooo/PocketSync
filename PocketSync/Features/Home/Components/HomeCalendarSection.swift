//
//  HomeCalendarSection.swift
//  PocketSync
//
//  Created by Codex on 3/26/26.
//

import SwiftUI

struct HomeCalendarSection: View {
    let monthDisplayTitle: String
    let shouldShowTodayButton: Bool
    let isExpanded: Bool
    let shouldUseMatchedSelection: Bool
    let weekDates: [Date]
    let monthGridDates: [Date?]
    let weekdaySymbols: [String]
    let selectedDate: Date
    let namespace: Namespace.ID
    let weeklyActivityLevel: (Date) -> Double
    let monthlyActivityLevel: (Date) -> Double
    let onShowMonthPicker: () -> Void
    let onJumpToToday: () -> Void
    let onToggleExpanded: () -> Void
    let onSelectDate: (Date) -> Void
    let onNavigateMonth: (Int) -> Void

    private var weekCalendarHeight: CGFloat { 74 }

    private var monthCalendarHeight: CGFloat {
        let weekRowCount = max(1, Int(ceil(Double(monthGridDates.count) / 7.0)))
        let headerHeight: CGFloat = 18
        let cellHeight: CGFloat = 42
        let rowSpacing: CGFloat = 10
        return headerHeight + CGFloat(weekRowCount) * cellHeight + CGFloat(weekRowCount) * rowSpacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: onShowMonthPicker) {
                    HStack(spacing: 6) {
                        Text(monthDisplayTitle)
                            .font(.headline.weight(.semibold))
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(PocketSyncTheme.ink)
                }
                .buttonStyle(.plain)

                Spacer()

                HStack(spacing: 8) {
                    if shouldShowTodayButton {
                        Button(action: onJumpToToday) {
                            Text("오늘")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(PocketSyncTheme.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(PocketSyncTheme.accent.opacity(0.10))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: onToggleExpanded) {
                        HStack(spacing: 6) {
                            Text(isExpanded ? "접기" : "펼치기")
                                .font(.footnote.weight(.semibold))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }

            ZStack(alignment: .top) {
                WeeklyStripCalendarView(
                    dates: weekDates,
                    selectedDate: selectedDate,
                    namespace: namespace,
                    isSelectionSource: !isExpanded,
                    shouldUseMatchedSelection: shouldUseMatchedSelection,
                    activityLevel: weeklyActivityLevel,
                    onSelect: onSelectDate
                )
                .opacity(isExpanded ? 0 : 1)
                .scaleEffect(isExpanded ? 0.985 : 1, anchor: .top)
                .offset(y: isExpanded ? -10 : 0)
                .blur(radius: isExpanded ? 4 : 0)
                .allowsHitTesting(!isExpanded)
                .zIndex(isExpanded ? 0 : 1)

                MonthCalendarView(
                    weekdaySymbols: weekdaySymbols,
                    dates: monthGridDates,
                    selectedDate: selectedDate,
                    namespace: namespace,
                    isSelectionSource: isExpanded,
                    shouldUseMatchedSelection: shouldUseMatchedSelection,
                    activityLevel: monthlyActivityLevel,
                    onSelect: onSelectDate
                )
                .opacity(isExpanded ? 1 : 0)
                .scaleEffect(isExpanded ? 1 : 0.985, anchor: .top)
                .offset(y: isExpanded ? 0 : 10)
                .blur(radius: isExpanded ? 0 : 4)
                .allowsHitTesting(isExpanded)
                .zIndex(isExpanded ? 1 : 0)
            }
            .frame(height: isExpanded ? monthCalendarHeight : weekCalendarHeight, alignment: .top)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        guard abs(value.translation.width) > abs(value.translation.height) else {
                            return
                        }

                        if value.translation.width < -28 {
                            onNavigateMonth(1)
                        } else if value.translation.width > 28 {
                            onNavigateMonth(-1)
                        }
                    }
            )
            .animation(.smooth(duration: 0.3), value: isExpanded)
        }
        .padding(16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: PocketSyncTheme.shadow.opacity(0.05), radius: 12, y: 6)
    }
}
