//
//  HomeExpenseFilter.swift
//  PocketSync
//
//  Created by Codex on 3/26/26.
//

import SwiftUI

enum HomeExpenseFilter: CaseIterable {
    case all
    case shared
    case mine

    var title: String {
        switch self {
        case .all:
            "전체"
        case .shared:
            "공동"
        case .mine:
            "내 지출"
        }
    }

    var navigationTitle: String {
        switch self {
        case .all:
            "전체 지출내역"
        case .shared:
            "공동 생활비"
        case .mine:
            "내 지출내역"
        }
    }

    var tint: Color {
        switch self {
        case .all:
            PocketSyncTheme.accent
        case .shared:
            PocketSyncTheme.warning
        case .mine:
            PocketSyncTheme.accent
        }
    }

    func matches(_ expense: ExpenseFeedItem) -> Bool {
        switch self {
        case .all:
            true
        case .shared:
            expense.walletKind == .shared
        case .mine:
            expense.walletKind != .shared
        }
    }
}
