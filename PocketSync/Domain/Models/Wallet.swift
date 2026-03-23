//
//  Wallet.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct Wallet: Identifiable, Codable, Hashable {
    let id: UUID
    let householdID: UUID
    var kind: WalletKind
    var monthlyBudget: Int
    var ownerUserID: UUID?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        householdID: UUID,
        kind: WalletKind,
        monthlyBudget: Int,
        ownerUserID: UUID? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.householdID = householdID
        self.kind = kind
        self.monthlyBudget = monthlyBudget
        self.ownerUserID = ownerUserID
        self.isActive = isActive
    }
}
