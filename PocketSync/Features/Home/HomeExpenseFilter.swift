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
    case husband
    case wife

    var title: String {
        switch self {
        case .all:
            "전체"
        case .shared:
            "공동"
        case .husband:
            "남편"
        case .wife:
            "아내"
        }
    }

    var navigationTitle: String {
        switch self {
        case .all:
            "전체 지출내역"
        case .shared:
            "공동 생활비"
        case .husband:
            "남편 지출내역"
        case .wife:
            "아내 지출내역"
        }
    }

    var tint: Color {
        switch self {
        case .all:
            PocketSyncTheme.accent
        case .shared:
            PocketSyncTheme.warning
        case .husband:
            PocketSyncTheme.accent
        case .wife:
            PocketSyncTheme.rose
        }
    }

    func matches(_ expense: ExpenseFeedItem) -> Bool {
        switch self {
        case .all:
            true
        case .shared:
            expense.walletKind == .shared
        case .husband:
            expense.walletKind == .husbandAllowance
        case .wife:
            expense.walletKind == .wifeAllowance
        }
    }
}
