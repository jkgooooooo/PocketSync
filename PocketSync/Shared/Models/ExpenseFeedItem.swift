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
    let categoryGroupTitle: String
    let categoryTitle: String
    let walletTitle: String
    let walletTagTitle: String
    let walletKind: WalletKind
    let ownerName: String
    let amount: Int
    let spentAt: Date
    let dateText: String
}

struct ExpenseFeedSection: Identifiable {
    let date: Date
    let title: String
    let items: [ExpenseFeedItem]

    var id: Date { date }
}

extension Array where Element == ExpenseFeedItem {
    var groupedByDay: [ExpenseFeedSection] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: self) { item in
            calendar.startOfDay(for: item.spentAt)
        }

        return grouped
            .sorted { $0.key > $1.key }
            .map { date, items in
                ExpenseFeedSection(
                    date: date,
                    title: date.expenseSectionTitle,
                    items: items.sorted { $0.spentAt > $1.spentAt }
                )
            }
    }
}
