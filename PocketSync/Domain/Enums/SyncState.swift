//
//  SyncState.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation

enum SyncState: String, Codable {
    case pending
    case synced
    case failed
}
