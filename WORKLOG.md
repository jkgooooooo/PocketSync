# PocketSync Worklog

## Current Product Direction

- App concept: Korean household spending control app for couples
- Core wallets: `공동 생활비`, `남편 용돈`, `아내 용돈`
- Privacy rule:
  - expense history is shared between both users
  - remaining allowance balance is hidden from the spouse

## Current Implementation Status

- Replaced the Xcode template app structure with a feature-based SwiftUI structure
- Split UI into `Features/` and `Shared/` instead of keeping everything in `ContentView.swift`
- Simplified the main navigation to:
  - Home
  - Add Expense
  - Recurring
- Reworked home into a timeline-style expense feed
- Added a home CTA button that switches directly to the expense tab
- Added preview list behavior on home with a dedicated `전체 보기` screen
- Added working home filters:
  - `전체`
  - `공동`
  - `남편`
  - `아내`
- Filter selection now changes the visible expense data immediately
- `전체 보기` also respects the currently selected filter
- Changed the overall visual direction to a flatter iOS-style UI
- Removed gradient backgrounds and set the app background to white

## Files Added Or Restructured

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

## Important UX Decisions

- Home should prioritize readable expense history, not dashboard overload
- Expense registration should be reachable directly from home
- Recurring expenses and subscriptions should live in a separate screen
- Shared data model should be household-owned, not device-owned
- Expense entries should sync across both spouses' apps

## Next Recommended Steps

1. Implement real expense creation flow from `QuickExpenseView`
2. Replace mock arrays with local app state/store
3. Design the data model for:
   - `Household`
   - `HouseholdMember`
   - `Wallet`
   - `Expense`
   - `RecurringExpense`
4. Connect SwiftData persistence
5. Add CloudKit sync and household sharing
6. Add spouse-safe visibility rules for balance display

## Notes

- Current data shown in the app is mock data only
- Build verification was done with `xcodebuild` using a temp derived data path
- Git remote is not currently configured in this local repository
