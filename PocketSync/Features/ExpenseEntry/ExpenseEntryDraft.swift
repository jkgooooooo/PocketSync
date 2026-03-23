//
//  ExpenseEntryDraft.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct ExpenseEntryDraft {
    var rawAmount: String = ""
    var selectedWalletID: UUID?
    var selectedCategory: ExpenseCategory?
    var memo: String = ""

    var amount: Int {
        Int(rawAmount) ?? 0
    }

    var isValid: Bool {
        amount > 0 && selectedWalletID != nil && selectedCategory != nil
    }

    mutating func appendAmount(_ value: String) {
        let next = rawAmount + value
        let normalized = String(Int(next) ?? 0)
        rawAmount = normalized == "0" ? "" : normalized
    }

    mutating func deleteLastDigit() {
        guard !rawAmount.isEmpty else { return }
        rawAmount.removeLast()
    }

    mutating func reset(defaultWalletID: UUID?) {
        rawAmount = ""
        selectedWalletID = defaultWalletID
        selectedCategory = nil
        memo = ""
    }
}
