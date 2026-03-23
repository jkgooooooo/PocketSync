//
//  Household.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

struct Household: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var baseDay: Int
    var currencyCode: String

    init(
        id: UUID = UUID(),
        name: String,
        baseDay: Int,
        currencyCode: String = "KRW"
    ) {
        self.id = id
        self.name = name
        self.baseDay = baseDay
        self.currencyCode = currencyCode
    }
}
