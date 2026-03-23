//
//  QuickExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI

struct QuickExpenseView: View {
    @EnvironmentObject private var householdStore: HouseholdStore
    let onSaveCompleted: (() -> Void)?

    @State private var draft = ExpenseEntryDraft()
    @State private var isCategoryManagementHintPresented = false

    init(onSaveCompleted: (() -> Void)? = nil) {
        self.onSaveCompleted = onSaveCompleted
    }

    private let keypadValues = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "00", "0", "삭제"]

    private var amountText: String {
        max(draft.amount, 0).currency
    }

    private var availableWallets: [Wallet] {
        householdStore.activeWallets
    }

    private var selectedWallet: Wallet? {
        guard let selectedWalletID = draft.selectedWalletID else { return nil }
        return householdStore.wallet(for: selectedWalletID)
    }

    private var categoryOptions: [ExpenseCategory] {
        ExpenseCategory.entryOrder
    }

    private var saveButtonTitle: String {
        guard let wallet = selectedWallet, draft.amount > 0 else {
            return "지출 저장"
        }

        return "\(wallet.kind.title)에서 \(draft.amount.currency) 저장"
    }

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
                        Text(amountText)
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(PocketSyncTheme.ink)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
                            ForEach(keypadValues, id: \.self) { key in
                                Button {
                                    handleKeypadTap(key)
                                } label: {
                                    KeypadKey(title: key)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                SectionBlock("주머니 선택") {
                    HStack(spacing: 12) {
                        ForEach(availableWallets) { wallet in
                            Button {
                                draft.selectedWalletID = wallet.id
                            } label: {
                                WalletChip(
                                    title: wallet.kind.title,
                                    tint: tint(for: wallet.kind),
                                    isSelected: draft.selectedWalletID == wallet.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                SectionBlock("카테고리") {
                    VStack(alignment: .leading, spacing: 12) {
                        ChipFlowLayout(spacing: 10, rowSpacing: 10) {
                            ForEach(categoryOptions) { category in
                                Button {
                                    draft.selectedCategory = category
                                } label: {
                                    CategoryChip(
                                        title: category.title,
                                        isSelected: draft.selectedCategory == category
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            Button {
                                isCategoryManagementHintPresented = true
                            } label: {
                                CategoryAddChip()
                            }
                            .buttonStyle(.plain)
                        }

                        Text("나중에 사용자 카테고리를 추가하거나 삭제할 수 있게 확장할 자리입니다.")
                            .font(.footnote)
                            .foregroundStyle(PocketSyncTheme.secondaryText)
                    }
                }

                SectionBlock("메모") {
                    TextField("예: 스타벅스, 장보기, 택시", text: $draft.memo)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(PocketSyncTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(PocketSyncTheme.line, lineWidth: 1)
                        }
                }

                Button {
                    saveExpense()
                } label: {
                    Text(saveButtonTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(draft.isValid ? PocketSyncTheme.accent : PocketSyncTheme.secondaryText)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!draft.isValid)
            }
            .padding(20)
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
        .onAppear {
            if draft.selectedWalletID == nil {
                draft.selectedWalletID = householdStore.activeWallets.first?.id
            }
        }
        .alert("카테고리 관리", isPresented: $isCategoryManagementHintPresented) {
            Button("확인", role: .cancel) {}
        } message: {
            Text("다음 단계에서 사용자 카테고리 추가/삭제 기능을 붙일 예정입니다.")
        }
    }

    private func handleKeypadTap(_ key: String) {
        if key == "삭제" {
            draft.deleteLastDigit()
            return
        }

        draft.appendAmount(key)
    }

    private func saveExpense() {
        guard
            let walletID = draft.selectedWalletID,
            let category = draft.selectedCategory,
            draft.amount > 0
        else {
            return
        }

        householdStore.addExpense(
            amount: draft.amount,
            category: category,
            memo: draft.memo,
            walletID: walletID
        )

        draft.reset(defaultWalletID: householdStore.activeWallets.first?.id)
        onSaveCompleted?()
    }

    private func tint(for kind: WalletKind) -> Color {
        switch kind {
        case .shared:
            PocketSyncTheme.positive
        case .husbandAllowance:
            PocketSyncTheme.accent
        case .wifeAllowance:
            PocketSyncTheme.rose
        }
    }
}
