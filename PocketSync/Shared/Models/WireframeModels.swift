//
//  WireframeModels.swift
//  PocketSync
//
//  Created by Codex on 3/23/26.
//

import Foundation
import SwiftUI

struct WalletPlan: Identifiable {
    let id = UUID()
    let name: String
    let limit: String
    let note: String
}

struct DashboardWallet: Identifiable {
    let id = UUID()
    let name: String
    let budget: Int
    let spent: Int
    let accent: Color
}

struct FixedExpense: Identifiable {
    let id = UUID()
    let name: String
    let amount: Int
    let dateText: String
    let wallet: String
    let status: String
}

struct ExpenseLog: Identifiable {
    let id = UUID()
    let category: String
    let wallet: String
    let owner: String
    let amount: Int
    let date: String
    let memo: String
}

struct SharedPersonalActivity: Identifiable {
    let id = UUID()
    let owner: String
    let category: String
    let amount: Int
    let date: String
    let memo: String
}

struct PrivateRecurringShare: Identifiable {
    let id = UUID()
    let owner: String
    let name: String
    let amount: Int
    let category: String
    let schedule: String
}

struct BudgetSnapshot: Identifiable {
    let id = UUID()
    let title: String
    let spent: Int
    let budget: Int
}
