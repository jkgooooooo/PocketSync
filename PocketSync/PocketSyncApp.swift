//
//  PocketSyncApp.swift
//  PocketSync
//
//  Created by 고정근 on 3/23/26.
//

import SwiftUI

@main
struct PocketSyncApp: App {
    @StateObject private var householdStore = HouseholdStore.preview

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(householdStore)
        }
    }
}
