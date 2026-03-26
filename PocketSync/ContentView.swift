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
            HomeDashboardView()
            .tag(0)
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .font(.system(size: 24, weight: .semibold))
                        Text("홈")
                    }
                }

            QuickExpenseView {
                selectedTab = 0
            }
                .tag(1)
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                        Text("지출")
                    }
                }

            RecurringExpenseView()
                .tag(2)
                .tabItem {
                    VStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 24, weight: .semibold))
                        Text("고정비")
                    }
                }
        }
        .tint(PocketSyncTheme.ink)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HouseholdStore.preview)
    }
}
