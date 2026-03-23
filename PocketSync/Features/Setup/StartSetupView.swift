//
//  StartSetupView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct StartSetupView: View {
    private let walletPlans = [
        WalletPlan(name: "남편 용돈", limit: "월 450,000원", note: "개인 소비는 여기서만 차감"),
        WalletPlan(name: "아내 용돈", limit: "월 450,000원", note: "서로 잔액만 공유"),
        WalletPlan(name: "공동 생활비", limit: "월 1,200,000원", note: "식비, 장보기, 공과금 관리")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HeroPanel(
                    eyebrow: "PocketSync MVP",
                    title: "생활비는 함께 보고,\n용돈은 분리해서 관리합니다.",
                    subtitle: "이번 달 예산만 넣으면 3분 안에 시작됩니다."
                )

                InfoCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("첫 진입 목표는 회원가입이 아니라 주머니 구조 만들기", systemImage: "target")
                        Label("개인 주머니 잔액은 본인만 보고, 배우자는 지출 내역과 금액까지 확인", systemImage: "lock.shield")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PocketSyncTheme.ink)
                }

                SectionBlock("시작 단계") {
                    VStack(spacing: 12) {
                        SetupStepRow(number: "1", title: "사용자 이름 입력", value: "정근")
                        SetupStepRow(number: "2", title: "월 기준일 선택", value: "매월 25일")
                        SetupStepRow(number: "3", title: "기본 주머니 생성", value: "3개 자동 생성")
                        SetupStepRow(number: "4", title: "배우자 초대", value: "링크 또는 코드")
                    }
                }

                SectionBlock("기본 주머니") {
                    VStack(spacing: 12) {
                        ForEach(walletPlans) { wallet in
                            WalletPlanCard(wallet: wallet)
                        }
                    }
                }

                SectionBlock("공개 범위") {
                    VStack(spacing: 12) {
                        InputPreviewRow(label: "공동 생활비", value: "예산 · 사용액 · 잔액 공유", accent: PocketSyncTheme.moss)
                        InputPreviewRow(label: "개인 용돈", value: "본인만 잔액 확인", accent: PocketSyncTheme.coral)
                        InputPreviewRow(label: "배우자에게 보이는 정보", value: "지출 금액 · 카테고리 · 메모 · 시점", accent: PocketSyncTheme.ink)
                    }
                }

                SectionBlock("초기 입력값") {
                    VStack(spacing: 12) {
                        InputPreviewRow(label: "월 총 예산", value: "2,100,000원", accent: PocketSyncTheme.coral)
                        InputPreviewRow(label: "통화", value: "KRW", accent: PocketSyncTheme.moss)
                        InputPreviewRow(label: "초대 방식", value: "초대 링크 / 8자리 코드", accent: PocketSyncTheme.ink)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("와이어프레임 문구")
                        .font(.headline)
                    Text("생활비는 함께 보고, 용돈은 분리해서 관리합니다.")
                    Text("이번 달 예산만 넣으면 바로 시작됩니다.")
                }
                .foregroundStyle(PocketSyncTheme.ink)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PocketSyncTheme.paper)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                Button {
                } label: {
                    HStack {
                        Text("3분 안에 구조 만들기")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(PocketSyncTheme.ink)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
    }
}
