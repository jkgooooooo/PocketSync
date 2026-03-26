//
//  InsightComponents.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct MetricRow: View {
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(PocketSyncTheme.ink)
            Spacer()
            Text(value)
                .fontWeight(.bold)
                .foregroundStyle(accent)
        }
        .padding(.vertical, 4)
    }
}

struct FixedExpenseRow: View {
    let item: FixedExpense

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(statusColor.opacity(0.18))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "creditcard")
                        .foregroundStyle(statusColor)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text("\(item.amount.currency) · 매월 \(item.dueDay)일 · \(item.wallet)")
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.72))
            }

            Spacer()

            Text(item.status)
                .font(.caption.weight(.bold))
                .foregroundStyle(statusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(statusColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(16)
        .background(PocketSyncTheme.paper)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var statusColor: Color {
        switch item.status {
        case "완료":
            PocketSyncTheme.moss
        case "예정":
            PocketSyncTheme.coral
        default:
            PocketSyncTheme.blush
        }
    }
}

struct AlertLine: View {
    let text: String
    let tone: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(tone)
                .frame(width: 8, height: 8)

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)

            Spacer()
        }
        .padding(16)
        .background(tone.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct InsightBar: View {
    let label: String
    let percent: Double
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(Int(percent * 100))%")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(tint)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(PocketSyncTheme.panel)

                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(tint)
                        .frame(width: proxy.size.width * percent)
                }
            }
            .frame(height: 12)
        }
    }
}

struct ExpenseLogRow: View {
    let log: ExpenseLog

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 10) {
                Text(ownerInitial)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(walletColor)
                    .clipShape(Circle())

                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(walletColor.opacity(0.25))
                    .frame(width: 3)
            }
            .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text(log.memo)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(PocketSyncTheme.ink)
                    Spacer()
                    Text(log.amount.currency)
                        .font(.headline.weight(.black))
                        .foregroundStyle(PocketSyncTheme.coral)
                }

                HStack(spacing: 8) {
                    tag(log.owner, color: walletColor)
                    tag(log.wallet, color: PocketSyncTheme.ink.opacity(0.75))
                    Spacer()
                    Text(log.date)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PocketSyncTheme.ink.opacity(0.55))
                }

                Text(log.category)
                    .font(.subheadline)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.72))
            }
        }
        .padding(18)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(PocketSyncTheme.line, lineWidth: 1)
        }
    }

    private var ownerInitial: String {
        String(log.owner.prefix(1))
    }

    private var walletColor: Color {
        if log.wallet.contains("공동") {
            return PocketSyncTheme.moss
        }
        if log.wallet.contains("아내") {
            return PocketSyncTheme.blush
        }
        return PocketSyncTheme.gold
    }

    private func tag(_ value: String, color: Color) -> some View {
        Text(value)
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct ExpenseTimelineRow: View {
    let log: ExpenseFeedItem
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 14) {
                avatar

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(log.memo)
                            .font(.body.weight(.semibold))
                            .foregroundStyle(PocketSyncTheme.ink)
                            .lineLimit(1)

                        Text(shortTime)
                            .font(.caption)
                            .foregroundStyle(PocketSyncTheme.secondaryText)
                            .lineLimit(1)

                        Spacer(minLength: 0)
                    }

                    Text(log.categoryTitle)
                        .font(.footnote)
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                }

                Spacer(minLength: 10)

                Text(log.amount.currency)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(PocketSyncTheme.ink)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)

            if !isLast {
                Divider()
                    .overlay(PocketSyncTheme.line.opacity(0.10))
                    .padding(.leading, 58)
            }
        }
    }

    private var shortTime: String {
        Self.timeFormatter.string(from: log.spentAt)
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(walletColor)

            Text(avatarText)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 34, height: 34)
        .shadow(color: walletColor.opacity(0.18), radius: 8, y: 4)
    }

    private var avatarText: String {
        switch log.walletTagTitle {
        case "#공동":
            "공"
        case "#나":
            "나"
        default:
            "상"
        }
    }

    private var walletColor: Color {
        switch log.walletKind {
        case .shared:
            return PocketSyncTheme.warning
        case .wifeAllowance:
            return PocketSyncTheme.rose
        case .husbandAllowance:
            return PocketSyncTheme.accent
        }
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
}

struct ExpenseFeedSectionCard: View {
    let items: [ExpenseFeedItem]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, expense in
                ExpenseTimelineRow(log: expense, isLast: index == items.count - 1)
            }
        }
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: PocketSyncTheme.shadow.opacity(0.05), radius: 12, y: 6)
    }
}

struct FixedExpenseManageRow: View {
    let item: FixedExpense
    private let calendar = Calendar.current

    private var isPaid: Bool {
        item.status == "완료"
    }

    private var statusTint: Color {
        switch paymentState {
        case .paid:
            return PocketSyncTheme.moss
        case .overdue:
            return .red
        case .scheduled:
            return PocketSyncTheme.coral
        }
    }

    private var paymentState: PaymentState {
        if isPaid { return .paid }
        let today = calendar.component(.day, from: .now)
        return item.dueDay < today ? .overdue : .scheduled
    }

    private var dDayText: String? {
        let today = calendar.component(.day, from: .now)
        let delta = item.dueDay - today

        if isPaid { return nil }
        if delta < 0 { return "미납 주의" }
        if delta == 0 { return "D-Day" }
        return "D-\(delta)"
    }

    private var statusText: String {
        switch paymentState {
        case .paid:
            return "완료"
        case .overdue:
            return "미납"
        case .scheduled:
            return item.status
        }
    }

    private var trailingStatusText: String {
        switch paymentState {
        case .paid:
            return "이번 달 반영됨"
        case .overdue:
            return "납부일 지남"
        case .scheduled:
            return "이번 달 예정"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 4) {
                Text("\(item.dueDay)")
                    .font(.title3.weight(.black))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text("일")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.secondaryText)
            }
            .frame(width: 48, height: 58)
            .background(PocketSyncTheme.panel)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Circle()
                .fill(statusTint.opacity(0.12))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: item.symbol)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(statusTint)
                }

            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(item.wallet)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.secondaryText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(statusText)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(statusTint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(statusTint.opacity(0.12))
                        .clipShape(Capsule())

                    if let dDayText {
                        Text(dDayText)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(PocketSyncTheme.coral)
                    }
                }

                Text(item.paymentSource)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.amount.currency)
                    .font(.title3.weight(.black))
                    .foregroundStyle(PocketSyncTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                Text(trailingStatusText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.secondaryText)
                    .multilineTextAlignment(.trailing)
            }
            .frame(width: 96, alignment: .trailing)
        }
        .padding(18)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PocketSyncTheme.line, lineWidth: 1)
        }
        .opacity(isPaid ? 0.62 : 1)
    }

    private enum PaymentState {
        case paid
        case overdue
        case scheduled
    }
}

struct HistoryRow: View {
    let title: String
    let detail: String
    let date: String

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.72))
            }

            Spacer()

            Text(date)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.coral)
        }
        .padding(16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct SharedPersonalActivityRow: View {
    let item: SharedPersonalActivity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(PocketSyncTheme.blush.opacity(0.14))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "person.text.rectangle")
                        .foregroundStyle(PocketSyncTheme.blush)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.owner) · \(item.category)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text(item.date)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.blush)

                Text(item.memo)
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.72))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(item.amount.currency)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.coral)

                Text("잔액 비공개")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(PocketSyncTheme.ink.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct PrivateRecurringShareRow: View {
    let item: PrivateRecurringShare

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(PocketSyncTheme.ink.opacity(0.08))
                .frame(width: 42, height: 42)
                .overlay {
                    Image(systemName: "lock")
                        .foregroundStyle(PocketSyncTheme.ink)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.owner) · \(item.name)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text("\(item.category) · \(item.schedule)")
                    .font(.footnote)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.72))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(item.amount.currency)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.coral)

                Text("잔액 비공개")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(PocketSyncTheme.ink.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
        .padding(16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
