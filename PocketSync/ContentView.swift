//
//  ContentView.swift
//  PocketSync
//
//  Created by 고정근 on 3/23/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeDashboardView {
                selectedTab = 1
            }
            .tag(0)
                .tabItem {
                    Label("홈", systemImage: "list.bullet.rectangle")
                }

            QuickExpenseView()
                .tag(1)
                .tabItem {
                    Label("지출", systemImage: "plus.circle.fill")
                }

            RecurringExpenseView()
                .tag(2)
                .tabItem {
                    Label("고정비", systemImage: "calendar.badge.clock")
                }
        }
        .tint(PocketSyncTheme.ink)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
