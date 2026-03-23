//
//  WalletComponents.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct SetupStepRow: View {
    let number: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            Text(number)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(PocketSyncTheme.ink)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(PocketSyncTheme.ink.opacity(0.7))
            }

            Spacer()
        }
    }
}

struct WalletPlanCard: View {
    let wallet: WalletPlan

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(wallet.name)
                .font(.headline)
                .foregroundStyle(PocketSyncTheme.ink)

            Text(wallet.limit)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.accent)

            Text(wallet.note)
                .font(.footnote)
                .foregroundStyle(PocketSyncTheme.ink.opacity(0.7))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct InputPreviewRow: View {
    let label: String
    let value: String
    let accent: Color

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(PocketSyncTheme.ink)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(accent)
        }
        .font(.subheadline)
        .padding(14)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct DashboardWalletCard: View {
    let wallet: DashboardWallet

    private var remaining: Int {
        max(wallet.budget - wallet.spent, 0)
    }

    private var ratio: Double {
        guard wallet.budget > 0 else { return 0 }
        return min(Double(wallet.spent) / Double(wallet.budget), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(wallet.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)

            Text(remaining.currency)
                .font(.title3.weight(.semibold))
                .foregroundStyle(wallet.accent)

            Text("\(wallet.spent.currency) 사용 / \(wallet.budget.currency)")
                .font(.footnote)
                .foregroundStyle(PocketSyncTheme.ink.opacity(0.68))

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(PocketSyncTheme.panel)

                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(wallet.accent)
                        .frame(width: proxy.size.width * ratio)
                }
            }
            .frame(height: 10)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WalletChip: View {
    let title: String
    let tint: Color
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : tint)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? tint : tint.opacity(0.12))
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isSelected ? .clear : tint.opacity(0.18), lineWidth: 1)
            }
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
            Text(title)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(PocketSyncTheme.ink)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(PocketSyncTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
