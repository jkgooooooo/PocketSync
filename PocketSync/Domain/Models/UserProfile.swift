//
//  UserProfile.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    let id: UUID
    let householdID: UUID
    var name: String
    var role: UserRole

    init(
        id: UUID = UUID(),
        householdID: UUID,
        name: String,
        role: UserRole
    ) {
        self.id = id
        self.householdID = householdID
        self.name = name
        self.role = role
    }
}
