//
//  RecurringExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct RecurringExpenseView: View {
    private let fixedExpenses = [
        FixedExpense(name: "관리비", amount: 180_000, dateText: "매월 25일", wallet: "공동 생활비", status: "예정"),
        FixedExpense(name: "정수기", amount: 24_000, dateText: "매월 27일", wallet: "공동 생활비", status: "예정"),
        FixedExpense(name: "인터넷", amount: 38_500, dateText: "매월 10일", wallet: "공동 생활비", status: "완료")
    ]

    private let subscriptions = [
        FixedExpense(name: "넷플릭스", amount: 17_000, dateText: "매월 12일", wallet: "공동 생활비", status: "완료"),
        FixedExpense(name: "유튜브 프리미엄", amount: 14_900, dateText: "매월 18일", wallet: "남편 용돈", status: "완료"),
        FixedExpense(name: "ChatGPT", amount: 29_000, dateText: "매월 21일", wallet: "남편 용돈", status: "완료")
    ]

    private let privateShares = [
        PrivateRecurringShare(owner: "남편", name: "ChatGPT", amount: 29_000, category: "개인 구독", schedule: "매월 21일"),
        PrivateRecurringShare(owner: "아내", name: "핸드폰비", amount: 65_000, category: "개인 통신", schedule: "매월 9일")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HeroPanel(
                        eyebrow: "Recurring",
                        title: "매달 빠지는 돈을\n한 번에 정리합니다.",
                        subtitle: "고정지출, 구독, 개인 정기지출을 따로 봅니다."
                    )

                    HStack(spacing: 12) {
                        compactStat(title: "고정지출", value: "\(fixedExpenses.count)개", accent: PocketSyncTheme.positive)
                        compactStat(title: "구독", value: "\(subscriptions.count)개", accent: PocketSyncTheme.accent)
                        compactStat(title: "공유 항목", value: "\(privateShares.count)개", accent: PocketSyncTheme.rose)
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("고정지출")
                        ForEach(fixedExpenses) { item in
                            FixedExpenseManageRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("구독")
                        ForEach(subscriptions) { item in
                            FixedExpenseManageRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("개인 정기지출 공유")
                        ForEach(privateShares) { item in
                            PrivateRecurringShareRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("고정비")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func compactStat(title: String, value: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(accent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PocketSyncTheme.line, lineWidth: 1)
        }
    }

    private func sectionTitle(_ value: String) -> some View {
        Text(value)
            .font(.title3.weight(.black))
            .foregroundStyle(PocketSyncTheme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
