//
//  UserRole.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

enum UserRole: String, Codable, Identifiable {
    case husband
    case wife

    var id: String { rawValue }

    var title: String {
        switch self {
        case .husband:
            "남편"
        case .wife:
            "아내"
        }
    }
}
