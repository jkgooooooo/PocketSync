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

    init(
        household: Household,
        currentUserID: UUID,
        users: [UserProfile],
        wallets: [Wallet],
        expenses: [Expense]
    ) {
        self.household = household
        self.currentUserID = currentUserID
        self.users = users
        self.wallets = wallets
        self.expenses = expenses
    }

    var currentUser: UserProfile? {
        users.first { $0.id == currentUserID }
    }

    var activeWallets: [Wallet] {
        wallets
            .filter(\.isActive)
            .sorted { lhs, rhs in
                lhs.kind.sortOrder < rhs.kind.sortOrder
            }
    }

    var expenseFeedItems: [ExpenseFeedItem] {
        expenses
            .filter { !$0.isDeleted }
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

    func wallet(for id: UUID) -> Wallet? {
        wallets.first { $0.id == id }
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
                amount: 5_800,
                category: .cafe,
                memo: "스타벅스",
                spentAt: date(hour: 14, minute: 10),
                createdByUserID: wife.id
            ),
            Expense(
                householdID: household.id,
                walletID: husbandWallet.id,
                amount: 29_000,
                category: .subscription,
                memo: "ChatGPT",
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
                amount: 24_000,
                category: .living,
                memo: "정수기 필터",
                spentAt: date(daysAgo: 2, hour: 12, minute: 0),
                createdByUserID: husband.id
            ),
            Expense(
                householdID: household.id,
                walletID: wifeWallet.id,
                amount: 31_000,
                category: .shopping,
                memo: "올리브영",
                spentAt: date(daysAgo: 4, hour: 18, minute: 15),
                createdByUserID: wife.id
            )
        ]

        return HouseholdStore(
            household: household,
            currentUserID: husband.id,
            users: [husband, wife],
            wallets: [sharedWallet, husbandWallet, wifeWallet],
            expenses: expenses
        )
    }()
}
