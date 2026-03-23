//
//  ExpenseInsightView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct ExpenseInsightView: View {
    private let logs = [
        ExpenseLog(category: "식비", wallet: "공동 생활비", owner: "정근", amount: 42_000, date: "3월 23일", memo: "주말 장보기"),
        ExpenseLog(category: "구독", wallet: "내 용돈", owner: "정근", amount: 29_000, date: "3월 21일", memo: "ChatGPT")
    ]

    private let sharedActivities = [
        SharedPersonalActivity(owner: "캐리", category: "카페", amount: 5_800, date: "3월 21일", memo: "스타벅스"),
        SharedPersonalActivity(owner: "캐리", category: "쇼핑", amount: 31_000, date: "3월 19일", memo: "올리브영"),
        SharedPersonalActivity(owner: "캐리", category: "교통", amount: 2_800, date: "3월 18일", memo: "버스/지하철")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroPanel(
                    eyebrow: "기록보다 패턴",
                    title: "누가 썼는지보다\n어느 주머니가 새는지 봅니다.",
                    subtitle: "지출 내역은 서로 다 보고, 개인 용돈의 남은 잔액만 숨깁니다."
                )

                SectionBlock("보기 범위") {
                    HStack(spacing: 12) {
                        FilterChip(title: "전체", isSelected: true)
                        FilterChip(title: "공동 생활비", isSelected: false)
                        FilterChip(title: "개인 공유", isSelected: false)
                    }
                }

                SectionBlock("필터") {
                    FlexibleChipLayout(items: ["3월", "정근", "식비", "공동 생활비", "고정 제외"]) { title in
                        FilterChip(title: title, isSelected: title == "3월")
                    }
                }

                SectionBlock("핵심 경고") {
                    VStack(spacing: 12) {
                        AlertLine(text: "식비 예산 24% 초과", tone: PocketSyncTheme.coral)
                        AlertLine(text: "구독료 이번 달 3건 증가", tone: PocketSyncTheme.blush)
                        AlertLine(text: "이번 달 가장 많이 쓴 항목은 식비", tone: PocketSyncTheme.ink)
                    }
                }

                SectionBlock("카테고리 비중") {
                    VStack(spacing: 12) {
                        InsightBar(label: "식비", percent: 0.44, tint: PocketSyncTheme.moss)
                        InsightBar(label: "구독", percent: 0.21, tint: PocketSyncTheme.coral)
                        InsightBar(label: "쇼핑", percent: 0.18, tint: PocketSyncTheme.blush)
                        InsightBar(label: "기타", percent: 0.17, tint: PocketSyncTheme.ink.opacity(0.6))
                    }
                }

                SectionBlock("지출 내역") {
                    VStack(spacing: 12) {
                        ForEach(logs) { log in
                            ExpenseLogRow(log: log)
                        }
                    }
                }

                SectionBlock("배우자 개인지출 공유") {
                    VStack(spacing: 12) {
                        ForEach(sharedActivities) { item in
                            SharedPersonalActivityRow(item: item)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
    }
}
