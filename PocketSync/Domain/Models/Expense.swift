//
//  Expense.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct Expense: Identifiable, Codable, Hashable {
    let id: UUID
    let householdID: UUID
    let walletID: UUID
    let amount: Int
    let category: ExpenseCategory
    let memo: String
    let spentAt: Date
    let createdByUserID: UUID
    var updatedAt: Date
    var syncState: SyncState
    var isDeleted: Bool

    init(
        id: UUID = UUID(),
        householdID: UUID,
        walletID: UUID,
        amount: Int,
        category: ExpenseCategory,
        memo: String,
        spentAt: Date = .now,
        createdByUserID: UUID,
        updatedAt: Date = .now,
        syncState: SyncState = .pending,
        isDeleted: Bool = false
    ) {
        self.id = id
        self.householdID = householdID
        self.walletID = walletID
        self.amount = amount
        self.category = category
        self.memo = memo
        self.spentAt = spentAt
        self.createdByUserID = createdByUserID
        self.updatedAt = updatedAt
        self.syncState = syncState
        self.isDeleted = isDeleted
    }
}
