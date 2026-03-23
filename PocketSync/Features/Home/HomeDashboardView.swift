//
//  HomeDashboardView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct HomeDashboardView: View {
    let onAddExpense: () -> Void
    @State private var selectedFilter: HomeExpenseFilter = .all

    private let recentExpenses = [
        ExpenseLog(category: "식비", wallet: "공동 생활비", owner: "정근", amount: 42_000, date: "오늘 오후 7:40", memo: "주말 장보기"),
        ExpenseLog(category: "카페", wallet: "아내 용돈", owner: "캐리", amount: 5_800, date: "오늘 오후 2:10", memo: "스타벅스"),
        ExpenseLog(category: "구독", wallet: "남편 용돈", owner: "정근", amount: 29_000, date: "어제 오전 9:00", memo: "ChatGPT"),
        ExpenseLog(category: "교통", wallet: "아내 용돈", owner: "캐리", amount: 18_400, date: "어제 오전 8:35", memo: "택시"),
        ExpenseLog(category: "생활", wallet: "공동 생활비", owner: "정근", amount: 24_000, date: "3월 21일", memo: "정수기 필터"),
        ExpenseLog(category: "쇼핑", wallet: "아내 용돈", owner: "캐리", amount: 31_000, date: "3월 19일", memo: "올리브영")
    ]

    private var filteredExpenses: [ExpenseLog] {
        recentExpenses.filter { expense in
            selectedFilter.matches(expense)
        }
    }

    private var previewExpenses: [ExpenseLog] {
        Array(filteredExpenses.prefix(4))
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("지출내역")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(PocketSyncTheme.ink)
                                Text("내 지출과 배우자 지출을 시간순으로 같이 봅니다.")
                                    .font(.subheadline)
                                    .foregroundStyle(PocketSyncTheme.secondaryText)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(HomeExpenseFilter.allCases, id: \.self) { filter in
                                    Button {
                                        selectedFilter = filter
                                    } label: {
                                        FilterChip(title: filter.title, isSelected: selectedFilter == filter)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        VStack(alignment: .leading, spacing: 0) {
                            if previewExpenses.isEmpty {
                                EmptyExpenseStateView(filterTitle: selectedFilter.title)
                            } else {
                                ForEach(Array(previewExpenses.enumerated()), id: \.element.id) { index, expense in
                                    ExpenseTimelineRow(log: expense, isLast: index == previewExpenses.count - 1)
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        NavigationLink {
                            ExpenseListView(expenses: filteredExpenses, title: selectedFilter.navigationTitle)
                        } label: {
                            HStack {
                                Text("전체 보기")
                                    .font(.body.weight(.semibold))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.footnote.weight(.bold))
                            }
                            .foregroundStyle(PocketSyncTheme.accent)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(PocketSyncTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(PocketSyncTheme.line.opacity(0.35), lineWidth: 1)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 120)
                    }
                }
                .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
                .navigationTitle("홈")
                .navigationBarTitleDisplayMode(.inline)

                Button(action: onAddExpense) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                            .font(.headline.weight(.black))
                        Text("지출 등록")
                            .font(.headline.weight(.black))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 18)
                    .background(PocketSyncTheme.accent)
                    .clipShape(Capsule())
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

private enum HomeExpenseFilter: CaseIterable {
    case all
    case shared
    case husband
    case wife

    var title: String {
        switch self {
        case .all:
            "전체"
        case .shared:
            "공동"
        case .husband:
            "남편"
        case .wife:
            "아내"
        }
    }

    var navigationTitle: String {
        switch self {
        case .all:
            "전체 지출내역"
        case .shared:
            "공동 생활비"
        case .husband:
            "남편 지출내역"
        case .wife:
            "아내 지출내역"
        }
    }

    func matches(_ expense: ExpenseLog) -> Bool {
        switch self {
        case .all:
            true
        case .shared:
            expense.wallet.contains("공동")
        case .husband:
            expense.wallet.contains("남편")
        case .wife:
            expense.wallet.contains("아내")
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
        .padding(.vertical, 32)
    }
}
