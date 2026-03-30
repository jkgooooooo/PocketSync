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
    @State private var selectedExpense: ExpenseFeedItem?

    private var calendar: Calendar {
        Calendar.current
    }

    private var filteredExpenses: [ExpenseFeedItem] {
        householdStore.expenseFeedItems.filter { expense in
            selectedFilter.matches(expense)
        }
    }

    private var displayedMonthExpenses: [ExpenseFeedItem] {
        filteredExpenses.filter { expense in
            calendar.isDate(expense.spentAt, equalTo: displayedMonth, toGranularity: .month)
        }
    }

    private var recentExpenses: [ExpenseFeedItem] {
        Array(displayedMonthExpenses.prefix(5))
    }

    private var recentExpenseSections: [ExpenseFeedSection] {
        recentExpenses.groupedByDay
    }

    private var monthSpend: Int {
        displayedMonthExpenses.reduce(0) { $0 + $1.amount }
    }

    private var monthExpenseCount: Int {
        displayedMonthExpenses.count
    }

    private var monthContextTitle: String {
        if calendar.isDate(displayedMonth, equalTo: .now, toGranularity: .month) {
            return "이번 달"
        }

        return HomeCalendarSupport.monthDisplayTitle(for: displayedMonth)
    }

    private var monthOverviewText: String {
        if monthExpenseCount == 0 {
            return "\(monthContextTitle) 등록된 지출이 없습니다"
        }

        return "\(monthContextTitle) \(monthExpenseCount)건 기록"
    }

    private var monthlyCategorySummaries: [MonthlyCategorySummary] {
        let grouped = Dictionary(grouping: displayedMonthExpenses, by: \.categoryTitle)

        return grouped
            .map { categoryTitle, items in
                MonthlyCategorySummary(
                    categoryTitle: categoryTitle,
                    amount: items.reduce(0) { $0 + $1.amount },
                    count: items.count
                )
            }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.categoryTitle < rhs.categoryTitle
                }

                return lhs.amount > rhs.amount
            }
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
                            Text(monthOverviewText)
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

                    MonthSpendCard(
                        title: "\(monthContextTitle) 총 지출",
                        amountText: monthSpend.currency,
                        countText: monthExpenseCount == 0 ? "등록된 지출 없음" : "총 \(monthExpenseCount)건"
                    )
                    .padding(.horizontal, 20)

                    HomeSectionCard(
                        title: "최근 지출내역",
                        trailing: {
                            if displayedMonthExpenses.count > recentExpenses.count {
                                NavigationLink {
                                    ExpenseListView(
                                        expenses: displayedMonthExpenses,
                                        title: "\(selectedFilter.navigationTitle) · \(monthContextTitle)"
                                    )
                                } label: {
                                    HomeSectionLinkLabel(
                                        title: "전체보기",
                                        detail: "\(displayedMonthExpenses.count)건"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    ) {
                        if recentExpenses.isEmpty {
                            EmptyExpenseStateView(
                                title: "최근 지출이 없습니다",
                                detail: "\(monthContextTitle)에 등록된 내역이 아직 없습니다."
                            )
                        } else {
                            VStack(alignment: .leading, spacing: 18) {
                                ForEach(recentExpenseSections) { section in
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(section.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(PocketSyncTheme.secondaryText)

                                        ExpenseFeedSectionCard(items: section.items) { expense in
                                            selectedExpense = expense
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    HomeSectionCard(title: "\(monthContextTitle) 요약") {
                        if monthlyCategorySummaries.isEmpty {
                            EmptyExpenseStateView(
                                title: "요약할 지출이 없습니다",
                                detail: "지출을 등록하면 카테고리별 합계가 여기에 표시됩니다."
                            )
                        } else {
                            VStack(spacing: 0) {
                                ForEach(Array(monthlyCategorySummaries.prefix(4).enumerated()), id: \.element.categoryTitle) { index, summary in
                                    MonthlySummaryRow(summary: summary)

                                    if index < min(monthlyCategorySummaries.count, 4) - 1 {
                                        Divider()
                                            .overlay(PocketSyncTheme.line.opacity(0.10))
                                    }
                                }
                            }
                            .background(PocketSyncTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
                }
            }
            .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("홈")
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
            .sheet(item: $selectedExpense) { expense in
                if let editableExpense = householdStore.expense(for: expense.id) {
                    EditExpenseView(expense: editableExpense)
                }
            }
        }
    }
}

private struct MonthlyCategorySummary {
    let categoryTitle: String
    let amount: Int
    let count: Int
}

private struct MonthSpendCard: View {
    let title: String
    let amountText: String
    let countText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)

            Text(amountText)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(PocketSyncTheme.ink)

            Text(countText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: PocketSyncTheme.shadow.opacity(0.05), radius: 12, y: 6)
    }
}

private struct HomeSectionCard<Content: View, Trailing: View>: View {
    let title: String
    @ViewBuilder var trailing: Trailing
    @ViewBuilder var content: Content

    init(
        title: String,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Spacer()

                trailing
            }

            content
        }
    }
}

private struct HomeSectionLinkLabel: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
            Text(detail)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
        }
        .foregroundStyle(PocketSyncTheme.ink)
    }
}

private struct MonthlySummaryRow: View {
    let summary: MonthlyCategorySummary

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Circle()
                .fill(PocketSyncTheme.accent.opacity(0.14))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: "won.sign.circle.fill")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(PocketSyncTheme.accent)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(summary.categoryTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text("\(summary.count)건")
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.secondaryText)
            }

            Spacer()

            Text(summary.amount.currency)
                .font(.body.weight(.bold))
                .foregroundStyle(PocketSyncTheme.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
    }
}

private struct EmptyExpenseStateView: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)
            Text(detail)
                .font(.footnote)
                .foregroundStyle(PocketSyncTheme.secondaryText)
                .multilineTextAlignment(.center)
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
