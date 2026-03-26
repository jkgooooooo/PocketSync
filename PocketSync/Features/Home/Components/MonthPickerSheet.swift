//
//  MonthPickerSheet.swift
//  PocketSync
//
//  Created by Codex on 3/26/26.
//

import SwiftUI

struct MonthPickerSheet: View {
    let years: [Int]
    let selectedMonth: Date
    let initialVisibleMonth: Date
    let monthSpend: (Date) -> Int
    let onSelect: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)
    private var initialVisibleYear: Int {
        calendar.component(.year, from: initialVisibleMonth)
    }
    private var currentMonth: Date {
        HomeCalendarSupport.startOfMonth(for: .now, calendar: calendar)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [.sectionHeaders]) {
                        ForEach(years.reversed(), id: \.self) { year in
                            Section {
                                LazyVGrid(columns: columns, spacing: 10) {
                                    ForEach(1...12, id: \.self) { month in
                                        if let date = date(year: year, month: month) {
                                            let isSelected = calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month)
                                            let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                                            let spend = monthSpend(date)
                                            let level = spendLevel(in: year, spend: spend)

                                            Button {
                                                onSelect(date)
                                            } label: {
                                                VStack(alignment: .leading, spacing: 10) {
                                                    HStack(alignment: .center, spacing: 6) {
                                                        Text("\(month)월")
                                                            .font(.subheadline.weight(.semibold))
                                                            .foregroundStyle(isSelected ? .white : PocketSyncTheme.ink)

                                                        if isCurrentMonth {
                                                            Circle()
                                                                .fill(isSelected ? Color.white.opacity(0.95) : PocketSyncTheme.accent)
                                                                .frame(width: 6, height: 6)
                                                        }
                                                    }

                                                    Text(spend == 0 ? "지출 없음" : spend.currency)
                                                        .font(.caption)
                                                        .foregroundStyle(isSelected ? .white.opacity(0.9) : PocketSyncTheme.secondaryText)

                                                    if spend > 0 {
                                                        Capsule()
                                                            .fill(isSelected ? Color.white.opacity(0.95) : PocketSyncTheme.accent.opacity(level))
                                                            .frame(height: 4)
                                                    }
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(14)
                                                .background(isSelected ? PocketSyncTheme.accent : PocketSyncTheme.panel)
                                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                                .overlay {
                                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                        .stroke(isSelected ? Color.clear : PocketSyncTheme.line.opacity(0.10), lineWidth: 1)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            header: {
                                HStack {
                                    Text("\(String(year))년")
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.ink)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                                .background(PocketSyncTheme.screenBackground)
                                .zIndex(1)
                                .id(year)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo(initialVisibleYear, anchor: .top)
                    }
                }
            }
            .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("연도와 월 선택")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func date(year: Int, month: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return calendar.date(from: components)
    }

    private func spendLevel(in year: Int, spend: Int) -> Double {
        let maxSpend = (1...12)
            .compactMap { month in date(year: year, month: month) }
            .map(monthSpend)
            .max() ?? 0

        guard maxSpend > 0, spend > 0 else {
            return 0.12
        }

        return max(0.14, Double(spend) / Double(maxSpend))
    }
}
