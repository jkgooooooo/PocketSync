//
//  EditExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/30/26.
//

import SwiftUI
import UIKit

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var householdStore: HouseholdStore

    let expenseID: UUID

    @State private var draft: ExpenseEntryDraft
    @State private var amountInput: String
    @State private var isDeleteConfirmationPresented = false
    @FocusState private var isAmountFieldFocused: Bool

    init(expense: Expense) {
        self.expenseID = expense.id
        _draft = State(
            initialValue: ExpenseEntryDraft(
                rawAmount: String(expense.amount),
                selectedWalletID: expense.walletID,
                selectedCategory: expense.category,
                memo: expense.memo,
                spentAt: expense.spentAt
            )
        )
        _amountInput = State(initialValue: Self.formattedAmountInput(from: String(expense.amount)))
    }

    private var availableWallets: [Wallet] {
        householdStore.activeWallets
    }

    private var selectedWallet: Wallet? {
        guard let selectedWalletID = draft.selectedWalletID else { return nil }
        return householdStore.wallet(for: selectedWalletID)
    }

    private var categoryOptions: [ExpenseCategory] {
        householdStore.availableCategories
    }

    private var suggestedMemos: [String] {
        draft.selectedCategory?.suggestedMemos ?? []
    }

    private var saveButtonTitle: String {
        guard let wallet = selectedWallet, draft.amount > 0 else {
            return "수정 저장"
        }

        return "\(wallet.kind.title) 지출 수정"
    }

    private var saveButtonTint: Color {
        draft.isValid ? PocketSyncTheme.accent : PocketSyncTheme.secondaryText
    }

    private var selectedSpendDateText: String {
        Self.selectedDateFormatter.string(from: draft.spentAt)
    }

    private var selectedSpendTimeText: String {
        Self.selectedTimeFormatter.string(from: draft.spentAt)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionBlock("금액") {
                        VStack(alignment: .leading, spacing: 10) {
                            TextField("금액", text: $amountInput)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .focused($isAmountFieldFocused)
                                .font(.system(size: 48, weight: .heavy, design: .rounded))
                                .foregroundStyle(PocketSyncTheme.ink)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(PocketSyncTheme.glassStroke, lineWidth: 1)
                                }

                            Text(draft.amount > 0 ? draft.amount.koreanCurrencyText : "금액을 입력하세요")
                                .font(.footnote)
                                .foregroundStyle(PocketSyncTheme.secondaryText)
                        }
                    }

                    SectionBlock("날짜") {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("선택한 날짜")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                    Text(selectedSpendDateText)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.ink)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("시간")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                    Text(selectedSpendTimeText)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.ink)
                                }
                            }

                            DatePicker(
                                "지출 날짜",
                                selection: $draft.spentAt,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)

                            DatePicker(
                                "지출 시간",
                                selection: $draft.spentAt,
                                displayedComponents: [.hourAndMinute]
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    SectionBlock("카테고리") {
                        ChipFlowLayout(spacing: 8, rowSpacing: 12) {
                            ForEach(categoryOptions) { category in
                                Button {
                                    draft.selectedCategory = category
                                    applySuggestedMemoIfNeeded(for: category)
                                    triggerSelectionHaptic()
                                } label: {
                                    CategoryChip(
                                        title: category.title,
                                        isSelected: draft.selectedCategory == category
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    SectionBlock("주머니와 메모") {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                ForEach(availableWallets) { wallet in
                                    Button {
                                        draft.selectedWalletID = wallet.id
                                        triggerSelectionHaptic()
                                    } label: {
                                        WalletSegmentButton(
                                            title: wallet.kind.title,
                                            tint: tint(for: wallet.kind),
                                            isSelected: draft.selectedWalletID == wallet.id
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            Text(walletDescription(for: selectedWallet))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(PocketSyncTheme.secondaryText)

                            VStack(alignment: .leading, spacing: 12) {
                                TextField("예: 스타벅스, 장보기, 택시", text: $draft.memo)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                    .font(.body)
                                    .padding(.horizontal, 16)
                                    .frame(minHeight: 56)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(PocketSyncTheme.glassStroke, lineWidth: 1)
                                    }

                                if !suggestedMemos.isEmpty {
                                    ChipFlowLayout(spacing: 8, rowSpacing: 8) {
                                        ForEach(suggestedMemos, id: \.self) { suggestion in
                                            Button {
                                                draft.memo = suggestion
                                                triggerSelectionHaptic()
                                            } label: {
                                                SuggestionChip(title: suggestion)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button {
                        saveExpense()
                    } label: {
                        HStack {
                            Text(saveButtonTitle)
                                .font(.headline)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .padding(.horizontal, 20)
                        .background(saveButtonTint)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!draft.isValid)

                    Button(role: .destructive) {
                        isDeleteConfirmationPresented = true
                    } label: {
                        HStack {
                            Text("지출 삭제")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "trash")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(PocketSyncTheme.coral)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .padding(.horizontal, 20)
                        .background(PocketSyncTheme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(PocketSyncTheme.coral.opacity(0.18), lineWidth: 1)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
            .navigationTitle("지출 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("완료") {
                        isAmountFieldFocused = false
                    }
                }
            }
            .onChange(of: amountInput) { _, newValue in
                let digits = newValue.filter(\.isNumber)
                draft.rawAmount = digits

                let formatted = Self.formattedAmountInput(from: digits)
                if formatted != newValue {
                    amountInput = formatted
                }
            }
            .confirmationDialog("이 지출을 삭제할까요?", isPresented: $isDeleteConfirmationPresented, titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    deleteExpense()
                }
                Button("취소", role: .cancel) { }
            } message: {
                Text("삭제하면 홈과 내역 목록에서 바로 사라집니다.")
            }
        }
    }

    private func saveExpense() {
        guard
            let walletID = draft.selectedWalletID,
            let category = draft.selectedCategory,
            draft.amount > 0
        else {
            return
        }

        guard householdStore.updateExpense(
            id: expenseID,
            amount: draft.amount,
            category: category,
            memo: draft.memo,
            walletID: walletID,
            spentAt: draft.spentAt
        ) else {
            return
        }

        triggerSuccessHaptic()
        dismiss()
    }

    private func deleteExpense() {
        guard householdStore.deleteExpense(id: expenseID) else {
            return
        }

        triggerSuccessHaptic()
        dismiss()
    }

    private func applySuggestedMemoIfNeeded(for category: ExpenseCategory) {
        let trimmedMemo = draft.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedMemo.isEmpty else { return }

        draft.memo = category.suggestionSeed
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

    private func walletDescription(for wallet: Wallet?) -> String {
        guard let wallet else {
            return "수정할 지출이 들어갈 주머니를 선택하세요."
        }

        switch wallet.kind {
        case .shared:
            return "공동 생활비로 기록됩니다."
        case .husbandAllowance:
            return "내 개인 지출로 기록됩니다."
        case .wifeAllowance:
            return "현재 사용자는 선택할 수 없는 지갑입니다."
        }
    }

    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private static func formattedAmountInput(from rawValue: String) -> String {
        guard let amount = Int(rawValue), amount > 0 else {
            return rawValue
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? rawValue
    }

    private static let selectedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()

    private static let selectedTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        return formatter
    }()
}
