//
//  QuickExpenseView.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import SwiftUI
import UIKit

struct QuickExpenseView: View {
    @EnvironmentObject private var householdStore: HouseholdStore
    let onSaveCompleted: (() -> Void)?

    @State private var draft = ExpenseEntryDraft()
    @State private var amountInput = ""
    @State private var isCategoryManagementExpanded = false
    @State private var customCategoryTitle = ""
    @State private var didAutoScrollToCategory = false
    @State private var isLoginRequiredAlertPresented = false
    @FocusState private var isAmountFieldFocused: Bool

    private let categorySectionID = "expense-category-section"

    init(onSaveCompleted: (() -> Void)? = nil) {
        self.onSaveCompleted = onSaveCompleted
    }

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
        householdStore.availableCategories
    }

    private var suggestedMemos: [String] {
        draft.selectedCategory?.suggestedMemos ?? []
    }

    private var trimmedCustomCategoryTitle: String {
        customCategoryTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var customCategoryAlreadyExists: Bool {
        categoryOptions.contains {
            $0.title.compare(trimmedCustomCategoryTitle, options: .caseInsensitive) == .orderedSame
        }
    }

    private var canAddCustomCategory: Bool {
        !trimmedCustomCategoryTitle.isEmpty && !customCategoryAlreadyExists
    }

    private var saveButtonTitle: String {
        guard let wallet = selectedWallet, draft.amount > 0 else {
            return "지출 저장"
        }

        return "\(wallet.kind.title)에서 \(draft.amount.currency) 저장"
    }

    private var selectedWalletSubtitle: String {
        guard let wallet = selectedWallet else {
            return "주머니를 선택하면 여기서 바로 저장할 수 있습니다."
        }

        return walletDescription(for: wallet)
    }

    private var saveButtonTint: Color {
        if draft.isValid {
            return PocketSyncTheme.positive
        }

        if draft.amount > 0 {
            return PocketSyncTheme.accent
        }

        return PocketSyncTheme.secondaryText
    }

    private var amountHelperText: String {
        if draft.amount > 0 {
            return draft.amount.koreanCurrencyText
        }

        return "금액을 입력하세요"
    }

    private var contextDateText: String {
        Self.contextDateFormatter.string(from: .now)
    }

    private var selectedSpendDateText: String {
        Self.selectedDateFormatter.string(from: draft.spentAt)
    }

    private var selectedSpendTimeText: String {
        Self.selectedTimeFormatter.string(from: draft.spentAt)
    }

    private var monthSpendText: String {
        householdStore.visibleExpenses
            .filter { Calendar.current.isDate($0.spentAt, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
            .currency
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(contextDateText)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(PocketSyncTheme.ink)

                        Text("이번 달 지출 \(monthSpendText)")
                            .font(.footnote)
                            .foregroundStyle(PocketSyncTheme.secondaryText)
                    }
                    .padding(.horizontal, 4)

                    SectionBlock("금액") {
                        VStack(alignment: .leading, spacing: 16) {
                            ZStack(alignment: .leading) {
                                if amountInput.isEmpty {
                                    Text("0")
                                        .font(.system(size: 60, weight: .heavy, design: .rounded))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                                }

                                HStack(alignment: .firstTextBaseline, spacing: 10) {
                                    TextField("", text: $amountInput)
                                        .keyboardType(.numberPad)
                                        .textInputAutocapitalization(.never)
                                        .focused($isAmountFieldFocused)
                                        .font(.system(size: amountInput.isEmpty ? 56 : 60, weight: .heavy, design: .rounded))
                                        .foregroundStyle(PocketSyncTheme.ink)

                                    Text("원")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                }
                            }
                            .frame(minHeight: 108)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(PocketSyncTheme.glassStroke, lineWidth: 1)
                            }
                            .shadow(color: PocketSyncTheme.shadow.opacity(0.55), radius: 14, y: 7)
                            .animation(.spring(response: 0.22, dampingFraction: 0.84), value: amountInput.isEmpty)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(amountHelperText)
                                    .font(.footnote)
                                    .foregroundStyle(PocketSyncTheme.secondaryText)

                                if draft.amount > 0 {
                                    Text("카테고리를 고르면 바로 저장할 수 있습니다.")
                                        .font(.caption)
                                        .foregroundStyle(PocketSyncTheme.tertiaryText)
                                }
                            }
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
                        VStack(alignment: .leading, spacing: 14) {
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

                            Button {
                                guard householdStore.isSignedIn else {
                                    isLoginRequiredAlertPresented = true
                                    triggerSelectionHaptic()
                                    return
                                }

                                withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                                    isCategoryManagementExpanded.toggle()
                                }
                                triggerSelectionHaptic()
                            } label: {
                                CategoryAddChip(isExpanded: isCategoryManagementExpanded)
                            }
                            .buttonStyle(.plain)

                            if !householdStore.isSignedIn {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "lock.circle")
                                        .font(.headline)
                                        .foregroundStyle(PocketSyncTheme.accent)

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("카테고리 추가는 로그인 후 사용할 수 있습니다")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(PocketSyncTheme.ink)

                                        Text("내 카테고리를 저장하고 다른 기기에서도 이어서 쓰려면 로그인이 필요합니다.")
                                            .font(.footnote)
                                            .foregroundStyle(PocketSyncTheme.secondaryText)
                                    }
                                }
                                .padding(14)
                                .background(PocketSyncTheme.card.opacity(0.84))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
                                }
                            }

                            if householdStore.isSignedIn, isCategoryManagementExpanded {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("카테고리 추가")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.ink)

                                    TextField("예: 반려동물, 보험, 경조사", text: $customCategoryTitle)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .font(.body)
                                        .padding(.horizontal, 16)
                                        .frame(minHeight: 50)
                                        .background(PocketSyncTheme.card.opacity(0.84), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
                                        }

                                    if customCategoryAlreadyExists {
                                        Text("같은 이름의 카테고리가 이미 있습니다.")
                                            .font(.caption)
                                            .foregroundStyle(PocketSyncTheme.coral)
                                    } else {
                                        Text("자주 쓰는 항목이 없으면 원하는 이름으로 추가해서 바로 선택할 수 있습니다.")
                                            .font(.caption)
                                            .foregroundStyle(PocketSyncTheme.secondaryText)
                                    }

                                    Button {
                                        addCustomCategory()
                                    } label: {
                                        HStack {
                                            Text("카테고리 추가")
                                                .font(.subheadline.weight(.semibold))
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .font(.subheadline.weight(.bold))
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                        .background(canAddCustomCategory ? PocketSyncTheme.accent : PocketSyncTheme.secondaryText, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                    .disabled(!canAddCustomCategory)
                                }
                                .padding(14)
                                .background(PocketSyncTheme.card.opacity(0.84))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(PocketSyncTheme.line.opacity(0.12), lineWidth: 1)
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }
                    .id(categorySectionID)

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

                            Text(selectedWalletSubtitle)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(PocketSyncTheme.secondaryText)

                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 10) {
                                    TextField("예: 스타벅스, 장보기, 택시", text: $draft.memo)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .font(.body)

                                    Image(systemName: "mic.fill")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(PocketSyncTheme.secondaryText)
                                        .padding(8)
                                        .background(PocketSyncTheme.panel, in: Circle())
                                }
                                .padding(.horizontal, 16)
                                .frame(minHeight: 56)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(PocketSyncTheme.glassStroke, lineWidth: 1)
                                }
                                .shadow(color: PocketSyncTheme.shadow.opacity(0.42), radius: 12, y: 6)

                                if !suggestedMemos.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("빠른 메모")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(PocketSyncTheme.secondaryText)

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
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .padding(.horizontal, 20)
                        .background(saveButtonTint)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(
                            color: draft.amount > 0 ? saveButtonTint.opacity(draft.isValid ? 0.28 : 0.18) : .clear,
                            radius: 18,
                            y: 10
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!draft.isValid)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .onChange(of: draft.amount) { oldValue, newValue in
                guard oldValue == 0, newValue > 0, !didAutoScrollToCategory else { return }
                didAutoScrollToCategory = true

                withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                    proxy.scrollTo(categorySectionID, anchor: .top)
                }
            }
        }
        .background(PocketSyncTheme.screenBackground.ignoresSafeArea())
        .onAppear {
            if draft.selectedWalletID == nil {
                draft.selectedWalletID = householdStore.activeWallets.first?.id
            }
            amountInput = formattedAmountInput(from: draft.rawAmount)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isAmountFieldFocused = true
            }
        }
        .onChange(of: amountInput) { _, newValue in
            let digits = newValue.filter(\.isNumber)
            draft.rawAmount = digits

            let formatted = formattedAmountInput(from: digits)
            if formatted != newValue {
                amountInput = formatted
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("완료") {
                    isAmountFieldFocused = false
                }
            }
        }
        .alert("로그인 후 사용할 수 있어요", isPresented: $isLoginRequiredAlertPresented) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("카테고리 추가, 저장, 동기화는 로그인 이후에 열어두겠습니다.")
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.86), value: draft.selectedCategory)
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
            walletID: walletID,
            spentAt: draft.spentAt
        )

        draft.reset(defaultWalletID: householdStore.activeWallets.first?.id)
        didAutoScrollToCategory = false
        amountInput = ""
        triggerSuccessHaptic()
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

    private func formattedAmountInput(from rawValue: String) -> String {
        guard let amount = Int(rawValue), amount > 0 else {
            return rawValue
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: amount)) ?? rawValue
    }

    private func triggerSelectionHaptic() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    private func walletDescription(for wallet: Wallet) -> String {
        switch wallet.kind {
        case .shared:
            return "둘이 함께 사용 하는 공동 생활비"
        case .husbandAllowance:
            return "개인 지출일 때 선택"
        case .wifeAllowance:
            return "공유를 켜면 나중에 상대방에게도 보여줄 수 있습니다"
        }
    }

    private func applySuggestedMemoIfNeeded(for category: ExpenseCategory) {
        let trimmedMemo = draft.memo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedMemo.isEmpty else { return }

        draft.memo = category.suggestionSeed
    }

    private func addCustomCategory() {
        guard let category = householdStore.addCustomCategory(title: trimmedCustomCategoryTitle, group: .living) else {
            return
        }

        customCategoryTitle = ""
        draft.selectedCategory = category
        applySuggestedMemoIfNeeded(for: category)
        triggerSelectionHaptic()
    }

    private static let contextDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter
    }()

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
