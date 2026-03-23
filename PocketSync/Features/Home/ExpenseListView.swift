//
//  ExpenseListView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct ExpenseListView: View {
    let expenses: [ExpenseLog]
    let title: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(PocketSyncTheme.ink)
                    Text("선택한 조건에 맞는 지출을 모두 확인합니다.")
                        .font(.subheadline)
                        .foregroundStyle(PocketSyncTheme.secondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                VStack(alignment: .leading, spacing: 0) {
                    if expenses.isEmpty {
                        Text("표시할 지출이 없습니다.")
                            .font(.subheadline)
                            .foregroundStyle(PocketSyncTheme.secondaryText)
                            .padding(.top, 8)
                    } else {
                        ForEach(Array(expenses.enumerated()), id: \.element.id) { index, expense in
                            ExpenseTimelineRow(log: expense, isLast: index == expenses.count - 1)
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
