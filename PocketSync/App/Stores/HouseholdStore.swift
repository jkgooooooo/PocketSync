//
//  HouseholdStore.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation
import Combine

@MainActor
final class HouseholdStore: ObservableObject {
    @Published var household: Household
    @Published var currentUserID: UUID
    @Published var users: [UserProfile]
    @Published var wallets: [Wallet]
    @Published var expenses: [Expense]
    @Published var customCategories: [ExpenseCategory]
    @Published var isSignedIn: Bool

    init(
        household: Household,
        currentUserID: UUID,
        users: [UserProfile],
        wallets: [Wallet],
        expenses: [Expense],
        customCategories: [ExpenseCategory] = [],
        isSignedIn: Bool = false
    ) {
        self.household = household
        self.currentUserID = currentUserID
        self.users = users
        self.wallets = wallets
        self.expenses = expenses
        self.customCategories = customCategories
        self.isSignedIn = isSignedIn
    }

    var currentUser: UserProfile? {
        users.first { $0.id == currentUserID }
    }

    var activeWallets: [Wallet] {
        accessibleWallets
            .filter(\.isActive)
            .sorted { lhs, rhs in
                lhs.kind.sortOrder < rhs.kind.sortOrder
            }
    }

    var availableCategories: [ExpenseCategory] {
        ExpenseCategory.defaultCategories + customCategories.sorted { lhs, rhs in
            if lhs.group == rhs.group {
                return lhs.title.localizedCompare(rhs.title) == .orderedAscending
            }

            return lhs.group.rawValue < rhs.group.rawValue
        }
    }

    var visibleExpenses: [Expense] {
        expenses.filter { expense in
            guard !expense.isDeleted else { return false }
            guard let wallet = wallet(for: expense.walletID) else { return false }
            return canAccess(wallet: wallet)
        }
    }

    var expenseFeedItems: [ExpenseFeedItem] {
        visibleExpenses
            .sorted { $0.spentAt > $1.spentAt }
            .compactMap { expense in
                guard
                    let wallet = wallet(for: expense.walletID),
                    let owner = user(for: expense.createdByUserID)
                else {
                    return nil
                }

                return ExpenseFeedItem(
                    id: expense.id,
                    memo: expense.memo,
                    categoryGroupTitle: expense.category.groupTitle,
                    categoryTitle: expense.category.title,
                    walletTitle: wallet.kind.title,
                    walletTagTitle: walletTagTitle(for: wallet),
                    walletKind: wallet.kind,
                    ownerName: owner.name,
                    amount: expense.amount,
                    spentAt: expense.spentAt,
                    dateText: expense.spentAt.expenseTimelineLabel
                )
            }
    }

    private var accessibleWallets: [Wallet] {
        wallets
            .filter(canAccess(wallet:))
    }

    func wallet(for id: UUID) -> Wallet? {
        wallets.first { $0.id == id }
    }

    func expense(for id: UUID) -> Expense? {
        visibleExpenses.first { $0.id == id }
    }

    func user(for id: UUID) -> UserProfile? {
        users.first { $0.id == id }
    }

    private func walletTagTitle(for wallet: Wallet) -> String {
        if wallet.kind == .shared {
            return "#공동"
        }

        if wallet.ownerUserID == currentUserID {
            return "#나"
        }

        return "#상대방"
    }

    private func canAccess(wallet: Wallet) -> Bool {
        if wallet.kind == .shared {
            return true
        }

        return wallet.ownerUserID == currentUserID
    }

    private func canModify(expense: Expense) -> Bool {
        guard let wallet = wallet(for: expense.walletID) else {
            return false
        }

        guard canAccess(wallet: wallet) else {
            return false
        }

        return expense.createdByUserID == currentUserID || wallet.kind == .shared
    }

    func addExpense(
        amount: Int,
        category: ExpenseCategory,
        memo: String,
        walletID: UUID,
        spentAt: Date = .now
    ) {
        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let expense = Expense(
            householdID: household.id,
            walletID: walletID,
            amount: amount,
            category: category,
            memo: trimmedMemo.isEmpty ? category.title : trimmedMemo,
            spentAt: spentAt,
            createdByUserID: currentUserID
        )

        expenses.insert(expense, at: 0)
    }

    @discardableResult
    func updateExpense(
        id: UUID,
        amount: Int,
        category: ExpenseCategory,
        memo: String,
        walletID: UUID,
        spentAt: Date
    ) -> Bool {
        guard let index = expenses.firstIndex(where: { $0.id == id }) else {
            return false
        }

        let existingExpense = expenses[index]
        guard canModify(expense: existingExpense) else {
            return false
        }

        guard amount > 0, let targetWallet = wallet(for: walletID), canAccess(wallet: targetWallet) else {
            return false
        }

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        expenses[index] = Expense(
            id: existingExpense.id,
            householdID: existingExpense.householdID,
            walletID: walletID,
            amount: amount,
            category: category,
            memo: trimmedMemo.isEmpty ? category.title : trimmedMemo,
            spentAt: spentAt,
            createdByUserID: existingExpense.createdByUserID,
            updatedAt: .now,
            syncState: .pending,
            isDeleted: false
        )
        return true
    }

    @discardableResult
    func deleteExpense(id: UUID) -> Bool {
        guard let index = expenses.firstIndex(where: { $0.id == id }) else {
            return false
        }

        guard canModify(expense: expenses[index]) else {
            return false
        }

        expenses[index].updatedAt = .now
        expenses[index].syncState = .pending
        expenses[index].isDeleted = true
        return true
    }

    @discardableResult
    func addCustomCategory(title: String, group: ExpenseCategoryGroup) -> ExpenseCategory? {
        guard isSignedIn else { return nil }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return nil }

        if let existing = availableCategories.first(where: {
            $0.group == group && $0.title.compare(trimmedTitle, options: .caseInsensitive) == .orderedSame
        }) {
            return existing
        }

        let category = ExpenseCategory.custom(title: trimmedTitle, group: group)
        customCategories.append(category)
        return category
    }
}

extension HouseholdStore {
    static let preview: HouseholdStore = {
        let household = Household(name: "PocketSync 가족", baseDay: 1)

        let husband = UserProfile(householdID: household.id, name: "정근", role: .husband)
        let wife = UserProfile(householdID: household.id, name: "캐리", role: .wife)

        let sharedWallet = Wallet(
            householdID: household.id,
            kind: .shared,
            monthlyBudget: 1_200_000
        )
        let husbandWallet = Wallet(
            householdID: household.id,
            kind: .husbandAllowance,
            monthlyBudget: 450_000,
            ownerUserID: husband.id
        )
        let wifeWallet = Wallet(
            householdID: household.id,
            kind: .wifeAllowance,
            monthlyBudget: 450_000,
            ownerUserID: wife.id
        )

        let calendar = Calendar.current
        let now = Date()

        func date(daysAgo: Int = 0, hour: Int, minute: Int) -> Date {
            let base = calendar.date(byAdding: .day, value: -daysAgo, to: now) ?? now
            return calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: base
            ) ?? base
        }

        let expenses = [
            Expense(
                householdID: household.id,
                walletID: sharedWallet.id,
                amount: 42_000,
                category: .food,
                memo: "주말 장보기",
                spentAt: date(hour: 19, minute: 40),
                createdByUserID: husband.id
            ),
            Expense(
                householdID: household.id,
                walletID: wifeWallet.id,
                amount: 65_000,
                category: .phoneBill,
                memo: "통신비 자동결제",
                spentAt: date(hour: 14, minute: 10),
                createdByUserID: wife.id
            ),
            Expense(
                householdID: household.id,
                walletID: husbandWallet.id,
                amount: 18_000,
                category: .food,
                memo: "점심",
                spentAt: date(daysAgo: 1, hour: 9, minute: 0),
                createdByUserID: husband.id
            ),
            Expense(
                householdID: household.id,
                walletID: wifeWallet.id,
                amount: 18_400,
                category: .transport,
                memo: "택시",
                spentAt: date(daysAgo: 1, hour: 8, minute: 35),
                createdByUserID: wife.id
            ),
            Expense(
                householdID: household.id,
                walletID: sharedWallet.id,
                amount: 230_000,
                category: .maintenance,
                memo: "관리비",
                spentAt: date(daysAgo: 2, hour: 12, minute: 0),
                createdByUserID: husband.id
            ),
            Expense(
                householdID: household.id,
                walletID: wifeWallet.id,
                amount: 12_000,
                category: .leisure,
                memo: "간식",
                spentAt: date(daysAgo: 4, hour: 18, minute: 15),
                createdByUserID: wife.id
            )
        ]

        return HouseholdStore(
            household: household,
            currentUserID: husband.id,
            users: [husband, wife],
            wallets: [sharedWallet, husbandWallet, wifeWallet],
            expenses: expenses,
            customCategories: [],
            isSignedIn: false
        )
    }()
}
