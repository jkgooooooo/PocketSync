//
//  ExpenseListView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct ExpenseListView: View {
    let expenses: [ExpenseFeedItem]
    let title: String

    private var sections: [ExpenseFeedSection] {
        expenses.groupedByDay
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(PocketSyncTheme.ink)
                    Text("총 \(expenses.count)개 내역")
                        .font(.subheadline)
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 0) {
                    if expenses.isEmpty {
                        ExpenseListEmptyStateView(title: title)
                            .padding(.top, 8)
                    } else {
                        ForEach(sections) { section in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(section.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(PocketSyncTheme.secondaryText)

                                ExpenseFeedSectionCard(items: section.items)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
        .navigationTitle("전체 보기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ExpenseListEmptyStateView: View {
    let title: String

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: "tray")
                .font(.title2)
                .foregroundStyle(PocketSyncTheme.secondaryText)
            Text("\(title)이 비어 있습니다")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PocketSyncTheme.ink)
            Text("조건에 맞는 지출이 아직 없습니다.")
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
