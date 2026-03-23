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

                Text("\(item.amount.currency) · \(item.dateText) · \(item.wallet)")
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
    let log: ExpenseLog
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Text(shortTime)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(PocketSyncTheme.secondaryText)
                    .frame(width: 54, alignment: .trailing)
                    .padding(.top, 2)

                Spacer(minLength: 0)
            }

            VStack(spacing: 0) {
                Circle()
                    .stroke(walletColor, lineWidth: 3)
                    .frame(width: 14, height: 14)
                    .background(
                        Circle()
                            .fill(PocketSyncTheme.card)
                            .frame(width: 8, height: 8)
                    )

                Rectangle()
                    .fill(walletColor.opacity(isLast ? 0 : 0.45))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .padding(.top, 4)
            }
            .frame(width: 18)

            VStack(alignment: .leading, spacing: 6) {
                Text(log.memo)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Text(walletTag)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(walletColor)

                    Text(log.category)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                }
                .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(log.amount.currency)
                        .font(.title3.weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(PocketSyncTheme.ink)

                    Text(log.owner)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, isLast ? 0 : 18)
        }
        .frame(minHeight: 62, alignment: .top)
    }

    private var shortTime: String {
        if log.date.contains("오전") || log.date.contains("오후") {
            return log.date
                .replacingOccurrences(of: "오늘 ", with: "")
                .replacingOccurrences(of: "어제 ", with: "")
        }

        return log.date
    }

    private var walletTag: String {
        if log.wallet.contains("공동") {
            return "#집안일"
        }
        if log.wallet.contains("아내") {
            return "#아내"
        }
        return "#남편"
    }

    private var walletColor: Color {
        if log.wallet.contains("공동") {
            return PocketSyncTheme.warning
        }
        if log.wallet.contains("아내") {
            return PocketSyncTheme.rose
        }
        return PocketSyncTheme.accent
    }
}

struct FixedExpenseManageRow: View {
    let item: FixedExpense

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(PocketSyncTheme.ink)
                Spacer()
                Text(item.status)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(item.status == "완료" ? PocketSyncTheme.moss : PocketSyncTheme.coral)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background((item.status == "완료" ? PocketSyncTheme.moss : PocketSyncTheme.coral).opacity(0.12))
                    .clipShape(Capsule())
            }

            HStack {
                Text(item.amount.currency)
                Spacer()
                Text(item.dateText)
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(PocketSyncTheme.ink)

            HStack {
                Label(item.wallet, systemImage: "tray.full")
                Spacer()
                Label("자동 생성", systemImage: "repeat")
            }
            .font(.footnote)
            .foregroundStyle(PocketSyncTheme.ink.opacity(0.7))
        }
        .padding(18)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(PocketSyncTheme.line, lineWidth: 1)
        }
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
