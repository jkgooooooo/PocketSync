//
//  QuickExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct QuickExpenseView: View {
    private let categories = ["식비", "교통", "쇼핑", "카페", "구독", "공과금", "기타"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroPanel(
                    eyebrow: "Quick Add",
                    title: "지출을 바로 넣고\n끝냅니다.",
                    subtitle: "금액, 주머니, 카테고리만 선택하면 저장됩니다."
                )

                SectionBlock("금액") {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("12,000원")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(PocketSyncTheme.ink)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                            ForEach(["1", "2", "3", "4", "5", "6", "7", "8", "9", "00", "0", "삭제"], id: \.self) { key in
                                KeypadKey(title: key)
                            }
                        }
                    }
                }

                SectionBlock("주머니 선택") {
                    HStack(spacing: 12) {
                        WalletChip(title: "남편 용돈", tint: PocketSyncTheme.accent, isSelected: false)
                        WalletChip(title: "아내 용돈", tint: PocketSyncTheme.rose, isSelected: false)
                        WalletChip(title: "공동 생활비", tint: PocketSyncTheme.positive, isSelected: true)
                    }
                }

                SectionBlock("카테고리") {
                    FlexibleChipLayout(items: categories) { title in
                        CategoryChip(title: title, isSelected: title == "식비")
                    }
                }

                Button {
                } label: {
                    Text("공동 생활비에서 12,000원 저장")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(PocketSyncTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
    }
}
