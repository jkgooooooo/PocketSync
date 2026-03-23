//
//  ExpenseFeedItem.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct ExpenseFeedItem: Identifiable, Hashable {
    let id: UUID
    let memo: String
    let categoryTitle: String
    let walletTitle: String
    let walletTagTitle: String
    let walletKind: WalletKind
    let ownerName: String
    let amount: Int
    let spentAt: Date
    let dateText: String
}
