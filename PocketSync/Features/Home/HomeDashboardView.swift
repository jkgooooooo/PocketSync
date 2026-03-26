//
//  HomeDashboardView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI
import UIKit

struct HomeDashboardView: View {
    @EnvironmentObject private var householdStore: HouseholdStore
    @Namespace private var calendarNamespace
    @State private var selectedFilter: HomeExpenseFilter = .all
    @State private var selectedDate = Calendar.current.startOfDay(for: .now)
    @State private var displayedMonth = Calendar.current.startOfDay(for: .now)
    @State private var isCalendarExpanded = false
    @State private var isMonthPickerPresented = false
    @State private var isCalendarTransitioning = false

    private var calendar: Calendar {
        Calendar.current
    }

    private var filteredExpenses: [ExpenseFeedItem] {
        householdStore.expenseFeedItems.filter { expense in
            selectedFilter.matches(expense)
        }
    }

    private var selectedDateExpenses: [ExpenseFeedItem] {
        filteredExpenses.filter { expense in
            calendar.isDate(expense.spentAt, inSameDayAs: selectedDate)
        }
    }

    private var previewExpenses: [ExpenseFeedItem] {
        Array(selectedDateExpenses.prefix(4))
    }

    private var previewSections: [ExpenseFeedSection] {
        previewExpenses.groupedByDay
    }

    private var selectedDateTitle: String {
        HomeCalendarSupport.selectedDateTitle(for: selectedDate, calendar: calendar)
    }

    private var selectedDateSpendText: String {
        selectedDateExpenses.reduce(0) { $0 + $1.amount }.currency
    }

    private var visibleCountText: String {
        if selectedDateExpenses.isEmpty {
            return "\(selectedDateTitle) 지출이 없습니다"
        }

        let visibleCount = previewExpenses.count
        let totalCount = selectedDateExpenses.count
        let baseText = "\(selectedDateTitle) \(totalCount)건 · \(selectedDateSpendText)"

        if totalCount > visibleCount {
            return "\(baseText) · 최근 \(visibleCount)개만 먼저 보여줍니다"
        }

        return baseText
    }

    private var weekDates: [Date] {
        HomeCalendarSupport.weekDates(for: selectedDate, calendar: calendar)
    }

    private var monthDisplayTitle: String {
        HomeCalendarSupport.monthDisplayTitle(for: displayedMonth)
    }

    private var monthGridDates: [Date?] {
        HomeCalendarSupport.monthGridDates(for: displayedMonth, calendar: calendar)
    }

    private var weekdaySymbols: [String] {
        HomeCalendarSupport.weekdaySymbols(calendar: calendar)
    }

    private func activity(for date: Date) -> DayActivity {
        let items = filteredExpenses.filter { expense in
            calendar.isDate(expense.spentAt, inSameDayAs: date)
        }

        let totalAmount = items.reduce(0) { $0 + $1.amount }

        return DayActivity(count: items.count, amount: totalAmount)
    }

    private func activityLevel(for date: Date, scope: [Date]) -> Double {
        let maxAmount = scope.map { activity(for: $0).amount }.max() ?? 0
        let dayAmount = activity(for: date).amount

        guard maxAmount > 0, dayAmount > 0 else {
            return 0
        }

        return max(0.18, Double(dayAmount) / Double(maxAmount))
    }

    private var shouldShowTodayButton: Bool {
        !calendar.isDate(selectedDate, inSameDayAs: .now)
            || !calendar.isDate(displayedMonth, equalTo: .now, toGranularity: .month)
    }

    private var availableYears: [Int] {
        HomeCalendarSupport.availableYears(for: filteredExpenses.map(\.spentAt), calendar: calendar)
    }

    private func monthSpend(for monthDate: Date) -> Int {
        filteredExpenses
            .filter { expense in
                calendar.isDate(expense.spentAt, equalTo: monthDate, toGranularity: .month)
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func navigateMonth(by offset: Int) {
        guard let targetMonth = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else {
            return
        }

        jumpToMonth(targetMonth)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func jumpToToday() {
        let today = calendar.startOfDay(for: .now)
        selectedDate = today
        displayedMonth = HomeCalendarSupport.startOfMonth(for: today, calendar: calendar)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func jumpToMonth(_ monthDate: Date) {
        let normalizedMonth = HomeCalendarSupport.startOfMonth(for: monthDate, calendar: calendar)
        displayedMonth = normalizedMonth

        let selectedDay = calendar.component(.day, from: selectedDate)
        if let adjustedDate = HomeCalendarSupport.clampedDate(in: normalizedMonth, matchingDay: selectedDay, calendar: calendar) {
            selectedDate = adjustedDate
        } else if let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: normalizedMonth)) {
            selectedDate = firstDay
        }
    }

    private func select(date: Date) {
        let normalizedDate = calendar.startOfDay(for: date)
        selectedDate = normalizedDate
        displayedMonth = HomeCalendarSupport.startOfMonth(for: normalizedDate, calendar: calendar)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(visibleCountText)
                                .font(.subheadline)
                                .foregroundStyle(PocketSyncTheme.secondaryText)
                        }

                        HomeCalendarSection(
                            monthDisplayTitle: monthDisplayTitle,
                            shouldShowTodayButton: shouldShowTodayButton,
                            isExpanded: isCalendarExpanded,
                            shouldUseMatchedSelection: isCalendarTransitioning,
                            weekDates: weekDates,
                            monthGridDates: monthGridDates,
                            weekdaySymbols: weekdaySymbols,
                            selectedDate: selectedDate,
                            namespace: calendarNamespace,
                            weeklyActivityLevel: { date in
                                activityLevel(for: date, scope: weekDates)
                            },
                            monthlyActivityLevel: { date in
                                activityLevel(for: date, scope: monthGridDates.compactMap { $0 })
                            },
                            onShowMonthPicker: {
                                isMonthPickerPresented = true
                            },
                            onJumpToToday: jumpToToday,
                            onToggleExpanded: {
                                isCalendarTransitioning = true
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                                    isCalendarExpanded.toggle()
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    isCalendarTransitioning = false
                                }
                            },
                            onSelectDate: select(date:),
                            onNavigateMonth: navigateMonth(by:)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(HomeExpenseFilter.allCases, id: \.self) { filter in
                                Button {
                                    selectedFilter = filter
                                } label: {
                                    FilterChip(
                                        title: filter.title,
                                        isSelected: selectedFilter == filter,
                                        tint: filter.tint
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, -8)

                    VStack(alignment: .leading, spacing: 0) {
                        if previewExpenses.isEmpty {
                            EmptyExpenseStateView(filterTitle: selectedFilter.title)
                        } else {
                            ForEach(previewSections) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(section.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)

                                    ExpenseFeedSectionCard(items: section.items)
                                }
                                .padding(.bottom, 24)
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    Group {
                        if selectedDateExpenses.count > previewExpenses.count {
                            NavigationLink {
                                ExpenseListView(
                                    expenses: selectedDateExpenses,
                                    title: "\(selectedFilter.navigationTitle) · \(selectedDateTitle)"
                                )
                            } label: {
                                HStack(spacing: 8) {
                                    Text("전체 내역 보기")
                                        .font(.body.weight(.semibold))
                                    Spacer()
                                    Text("\(selectedDateExpenses.count)개")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.bold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                }
                                .foregroundStyle(PocketSyncTheme.ink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(PocketSyncTheme.panel)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
                                }
                                .shadow(color: PocketSyncTheme.shadow.opacity(0.05), radius: 10, y: 6)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 28)
                }
            }
            .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("최근 지출")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isMonthPickerPresented) {
                MonthPickerSheet(
                    years: availableYears,
                    selectedMonth: displayedMonth,
                    initialVisibleMonth: calendar.startOfDay(for: .now),
                    monthSpend: { monthDate in
                        monthSpend(for: monthDate)
                    },
                    onSelect: { monthDate in
                        jumpToMonth(monthDate)
                        isMonthPickerPresented = false
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

private struct EmptyExpenseStateView: View {
    let filterTitle: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Text("\(filterTitle) 지출이 없습니다")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)
            Text("이 조건에 맞는 지출이 아직 없습니다.")
                .font(.footnote)
                .foregroundStyle(PocketSyncTheme.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
        }
    }
}
