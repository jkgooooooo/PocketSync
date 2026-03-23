//
//  ExpenseCategory.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food
    case transport
    case shopping
    case cafe
    case subscription
    case utility
    case living
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .food:
            "식비"
        case .transport:
            "교통"
        case .shopping:
            "쇼핑"
        case .cafe:
            "카페"
        case .subscription:
            "구독"
        case .utility:
            "공과금"
        case .living:
            "생활"
        case .other:
            "기타"
        }
    }

    static let entryOrder: [ExpenseCategory] = [
        .food,
        .transport,
        .living,
        .shopping,
        .cafe,
        .subscription,
        .utility,
        .other
    ]
}
