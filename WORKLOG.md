# PocketSync Worklog

## Product Direction

- App concept: Korean couple household spending control app
- Project name: `PocketSync`
- Core wallets:
  - `공동 생활비`
  - `남편 용돈`
  - `아내 용돈`
- Privacy rule:
  - both users can see all expense history
  - personal allowance remaining balance is hidden from the spouse

## Current UI State

- Navigation is simplified to 3 tabs:
  - `홈`
  - `지출`
  - `고정비`
- Home is no longer a dashboard. It is a timeline-style expense feed.
- Home includes:
  - wallet filter chips: `전체`, `공동`, `남편`, `아내`
  - recent expense preview
  - `전체 보기` entry into a full expense history screen
  - direct `지출 등록` CTA
- `전체 보기` follows the currently selected home filter.
- Recurring screen is focused on fixed expenses and subscriptions.
- Visual direction is flat and iOS-like:
  - no gradients
  - white background
  - system color based styling

## Implementation Status

- Replaced the Xcode template structure with a feature-first SwiftUI structure
- Moved screen code out of `ContentView.swift`
- Added shared components and theme layers under `Shared/`
- Implemented timeline-style expense rows
- Implemented functional home filtering by wallet type
- Improved timeline text layout for narrow screens:
  - line 1: memo
  - line 2: wallet tag + category
  - line 3: amount + owner
- Kept app data in mock models for now

## Main Files

- `PocketSync/ContentView.swift`
- `PocketSync/Features/Home/HomeDashboardView.swift`
- `PocketSync/Features/Home/ExpenseListView.swift`
- `PocketSync/Features/ExpenseEntry/QuickExpenseView.swift`
- `PocketSync/Features/Recurring/RecurringExpenseView.swift`
- `PocketSync/Features/Setup/StartSetupView.swift`
- `PocketSync/Features/Insights/ExpenseInsightView.swift`
- `PocketSync/Shared/Components/*`
- `PocketSync/Shared/Theme/PocketSyncTheme.swift`
- `PocketSync/Shared/Models/WireframeModels.swift`
- `PocketSync/Shared/Formatting/CurrencyFormatting.swift`

## Architecture Direction

- Source of truth should be household-owned data, not device-owned data
- Expense sync should work across both spouses' devices
- Expense records are shared
- Balance visibility should be controlled in the UI layer
- Recommended next state architecture:
  - SwiftData for local persistence
  - CloudKit for sync
  - entities:
    - `Household`
    - `HouseholdMember`
    - `Wallet`
    - `Expense`
    - `RecurringExpense`

## Next Steps

1. Implement actual expense creation from `QuickExpenseView`
2. Replace mock arrays with app state/store
3. Wire home and full list to real persisted data
4. Add SwiftData models and persistence
5. Add CloudKit sync and spouse sharing flow
6. Apply balance visibility rules by current user

## Repo State

- Build verification was done with `xcodebuild` and a temporary derived data path
- Current branch: `main`
- Remote: `origin -> https://github.com/jkgooooooo/PocketSync.git`
