//
//  WalletKind.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

enum WalletKind: String, Codable, Identifiable {
    case shared
    case husbandAllowance
    case wifeAllowance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shared:
            "공동 생활비"
        case .husbandAllowance:
            "남편 용돈"
        case .wifeAllowance:
            "아내 용돈"
        }
    }

    var ownerRole: UserRole? {
        switch self {
        case .shared:
            nil
        case .husbandAllowance:
            .husband
        case .wifeAllowance:
            .wife
        }
    }

    var sortOrder: Int {
        switch self {
        case .shared:
            0
        case .husbandAllowance:
            1
        case .wifeAllowance:
            2
        }
    }
}
