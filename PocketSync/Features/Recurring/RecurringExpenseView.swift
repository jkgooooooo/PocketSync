//
//  RecurringExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct RecurringExpenseView: View {
    private let fixedExpenses = [
        FixedExpense(name: "관리비", amount: 180_000, symbol: "building.2", dueDay: 25, wallet: "공동 생활비", paymentSource: "신한 체크 · 자동이체", status: "예정"),
        FixedExpense(name: "정수기", amount: 24_000, symbol: "drop", dueDay: 27, wallet: "공동 생활비", paymentSource: "국민 체크 · 자동이체", status: "예정"),
        FixedExpense(name: "인터넷", amount: 38_500, symbol: "wifi", dueDay: 10, wallet: "공동 생활비", paymentSource: "우리 카드 · 자동결제", status: "완료")
    ]

    private let subscriptions = [
        FixedExpense(name: "넷플릭스", amount: 17_000, symbol: "tv", dueDay: 12, wallet: "공동 생활비", paymentSource: "현대 카드 · 자동결제", status: "완료"),
        FixedExpense(name: "유튜브 프리미엄", amount: 14_900, symbol: "play.rectangle.fill", dueDay: 18, wallet: "남편 용돈", paymentSource: "신한 카드 · 자동결제", status: "완료"),
        FixedExpense(name: "ChatGPT", amount: 29_000, symbol: "sparkles.rectangle.stack", dueDay: 21, wallet: "남편 용돈", paymentSource: "Apple 결제 · 자동결제", status: "완료")
    ]

    private let privateShares = [
        PrivateRecurringShare(owner: "남편", name: "ChatGPT", amount: 29_000, category: "개인 구독", schedule: "매월 21일"),
        PrivateRecurringShare(owner: "아내", name: "핸드폰비", amount: 65_000, category: "개인 통신", schedule: "매월 9일")
    ]

    private var allRecurring: [FixedExpense] {
        fixedExpenses + subscriptions
    }

    private var totalRecurringAmount: Int {
        allRecurring.reduce(0) { $0 + $1.amount }
    }

    private var fixedTotalAmount: Int {
        fixedExpenses.reduce(0) { $0 + $1.amount }
    }

    private var subscriptionTotalAmount: Int {
        subscriptions.reduce(0) { $0 + $1.amount }
    }

    private var sharedTotalAmount: Int {
        privateShares.reduce(0) { $0 + $1.amount }
    }

    private var paidAmount: Int {
        allRecurring.filter { $0.status == "완료" }.reduce(0) { $0 + $1.amount }
    }

    private var progress: Double {
        guard totalRecurringAmount > 0 else { return 0 }
        return Double(paidAmount) / Double(totalRecurringAmount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    recurringSummaryCard

                    HStack(spacing: 12) {
                        compactStat(title: "고정지출", amount: fixedTotalAmount, count: fixedExpenses.count, accent: PocketSyncTheme.positive)
                        compactStat(title: "구독", amount: subscriptionTotalAmount, count: subscriptions.count, accent: PocketSyncTheme.accent)
                        compactStat(title: "공유 항목", amount: sharedTotalAmount, count: privateShares.count, accent: PocketSyncTheme.rose)
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("고정지출", subtitle: "이번 달 빠져나갈 생활 필수비")
                        ForEach(fixedExpenses) { item in
                            FixedExpenseManageRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("구독", subtitle: "매달 자동 결제되는 서비스")
                        ForEach(subscriptions) { item in
                            FixedExpenseManageRow(item: item)
                        }
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle("개인 정기지출 공유", subtitle: "상대방도 알아야 할 개인 정기비")
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

    private var recurringSummaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("이번 달 고정비")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)

            Text(totalRecurringAmount.currency)
                .font(.system(size: 34, weight: .black, design: .rounded))
                .foregroundStyle(PocketSyncTheme.ink)

            Text("숨만 쉬어도 나가는 돈입니다. \(paidAmount.currency) 납부 완료")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(PocketSyncTheme.line.opacity(0.2))
                        Capsule()
                            .fill(PocketSyncTheme.accent)
                            .frame(width: proxy.size.width * progress)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("진행률 \(Int(progress * 100))%")
                    Spacer()
                    Text("\(allRecurring.filter { $0.status == "완료" }.count) / \(allRecurring.count)건 완료")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: PocketSyncTheme.shadow.opacity(0.05), radius: 12, y: 6)
        .padding(.horizontal, 20)
    }

    private func compactStat(title: String, amount: Int, count: Int, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Text(amount.currency)
                .font(.headline.weight(.black))
                .foregroundStyle(accent)
            Text("\(count)건")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
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

    private func sectionTitle(_ value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title2.weight(.black))
                .foregroundStyle(PocketSyncTheme.ink)
            Text(subtitle)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
