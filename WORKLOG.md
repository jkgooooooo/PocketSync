# PocketSync Worklog

## 1. Product Definition

- App name: `PocketSync`
- Product type: Korean couple spending control app
- Core concept:
  - household spending is shared
  - personal allowance is separated
  - expense history is visible to both users
  - personal remaining balance is hidden from spouse

## 2. Core Wallet Model

- Fixed wallet structure:
  - `공동 생활비`
  - `남편 용돈`
  - `아내 용돈`
- Important product rule:
  - users can record expenses into any wallet
  - example: husband can create an expense in wife's allowance wallet
  - this is valid because data belongs to the household, not the device

## 3. Current Information Disclosure Rule

- Shared expense history: visible to both users
- Personal remaining balance:
  - visible only to owner
  - should eventually be controlled at the UI layer
- List UI currently prioritizes wallet identity over person name

## 4. Current Navigation

- App is currently simplified to 3 tabs:
  - `홈`
  - `지출`
  - `고정비`
- Current tab ownership:
  - Home = timeline feed of expense history
  - Expense = quick expense entry
  - Recurring = fixed expenses and subscriptions

## 5. Current Design Direction

- Visual direction was intentionally simplified after multiple iterations
- Current style decisions:
  - no gradients
  - white background
  - iOS-like flat styling
  - system color based accents
  - reduced dashboard complexity
- The previous dashboard-heavy direction was explicitly rejected
- The user preferred:
  - a feed-oriented home
  - less clutter
  - Apple HIG-compatible tone

## 6. Home Screen Direction

- Home is no longer a dashboard
- Home is now a timeline-style spending feed
- Main behaviors on home:
  - wallet filter chips:
    - `전체`
    - `공동`
    - `남편`
    - `아내`
  - recent expense preview only
  - `전체 보기` opens full list screen
  - floating `지출 등록` button switches to expense tab
- Full list screen respects current home filter

## 7. Current Timeline Row Rule

- Timeline list has gone through several revisions
- Rejected variants:
  - showing spouse name and spouse tag together
  - using `#집안일`
  - splitting category onto an awkward middle row
- Current accepted display rule:
  - wallet tag is shown
  - owner name is hidden from row
  - category is shown as the final metadata line
- Current row layout:
  - line 1: `메모 + #공동/#나/#상대방`
  - line 2: `금액`
  - line 3: `카테고리`
- Current tag rule:
  - shared wallet -> `#공동`
  - current user's personal wallet -> `#나`
  - spouse wallet -> `#상대방`

## 8. Current Category Direction

- The old fixed 3-column chip layout was too rigid and looked broken
- Category input is now moving toward a real chip flow layout
- Current category order for entry:
  - `식비`
  - `교통`
  - `생활`
  - `쇼핑`
  - `카페`
  - `구독`
  - `공과금`
  - `기타`
- Reason:
  - early categories should match common daily spending patterns
  - less frequent categories should appear later

## 9. Category Customization Direction

- A `+ 추가` chip was added in the expense entry screen
- It is currently a placeholder action with an alert
- Intended future behavior:
  - users can create custom categories
  - users can remove custom categories
  - default categories should remain available
- Current product stance:
  - quick entry first
  - category management should be a separate follow-up flow

## 10. Actual Expense Entry Implementation Status

- Expense entry is no longer a pure mockup
- Currently implemented:
  - keypad amount input
  - wallet selection
  - category selection
  - optional memo input
  - validation before save
  - save into shared app store
  - reset form after save
  - return to home tab after save
- Validation rule:
  - amount > 0
  - wallet selected
  - category selected

## 11. App State Direction

- The app has moved away from per-view hardcoded arrays
- Current source of truth direction:
  - shared household-level state
  - one store used by multiple screens
- Current store:
  - `HouseholdStore`
- Current screens reading from the store:
  - Home
  - Full expense list
  - Quick expense entry

## 12. Domain Model Status

- Added domain enums:
  - `ExpenseCategory`
  - `SyncState`
  - `UserRole`
  - `WalletKind`
- Added domain models:
  - `Household`
  - `UserProfile`
  - `Wallet`
  - `Expense`
- These models are storage-ready compared to old UI string models
- Important shift:
  - `Date`, `UUID`, `walletID`, `createdByUserID` are now first-class
  - no longer dependent on UI strings like `"오늘 오후 7:40"`

## 13. Feed Model Layer

- Added `ExpenseFeedItem`
- Purpose:
  - convert domain `Expense` into UI-friendly timeline data
  - keep formatting and tag derivation outside the view
- Store now derives:
  - category title
  - wallet title
  - `#공동 / #나 / #상대방`
  - formatted date label

## 14. Date Formatting Layer

- Added dedicated date formatting helper for expense feed labels
- Current behavior:
  - today -> `오늘 오후 7:40`
  - yesterday -> `어제 오전 9:00`
  - older -> `3월 21일`

## 15. Files Added Recently

- `PocketSync/App/Stores/HouseholdStore.swift`
- `PocketSync/Domain/Enums/ExpenseCategory.swift`
- `PocketSync/Domain/Enums/SyncState.swift`
- `PocketSync/Domain/Enums/UserRole.swift`
- `PocketSync/Domain/Enums/WalletKind.swift`
- `PocketSync/Domain/Models/Expense.swift`
- `PocketSync/Domain/Models/Household.swift`
- `PocketSync/Domain/Models/UserProfile.swift`
- `PocketSync/Domain/Models/Wallet.swift`
- `PocketSync/Features/ExpenseEntry/ExpenseEntryDraft.swift`
- `PocketSync/Shared/Formatting/ExpenseDateFormatting.swift`
- `PocketSync/Shared/Models/ExpenseFeedItem.swift`

## 16. Files Recently Changed

- `PocketSync/PocketSyncApp.swift`
- `PocketSync/ContentView.swift`
- `PocketSync/Features/Home/HomeDashboardView.swift`
- `PocketSync/Features/Home/ExpenseListView.swift`
- `PocketSync/Features/ExpenseEntry/QuickExpenseView.swift`
- `PocketSync/Shared/Components/FormComponents.swift`
- `PocketSync/Shared/Components/InsightComponents.swift`

## 17. Important Current Behavior

- Home feed is filtered by wallet type
- Home only shows preview rows
- Full list opens with same filter context
- Expense save updates the shared in-memory store
- Home and full list should reflect saved expenses immediately

## 18. Known Temporary Constraints

- Persistence is not implemented yet
- Current data is still memory-backed
- App restart will lose newly created expenses
- Cloud sync is not implemented yet
- `+ 추가` category action is placeholder only

## 19. Architecture Decisions Already Made

- Household-owned data is the right architecture
- Device-owned data is the wrong architecture
- Expense sync and privacy are separate concerns
- Wallet identity matters more than person nickname in list UI
- Personal balance privacy should be a view concern, not data duplication
- Entry speed matters more than advanced analytics in MVP

## 20. Rejected Product/UX Directions

- Heavy dashboard home
- gradient-heavy visual style
- showing spouse balance openly
- overloading first screen with analytics
- showing owner name and wallet tag together in the expense row
- using `#집안일` instead of `#공동`

## 21. Next Recommended Steps

1. Replace in-memory expense state with SwiftData persistence
2. Make the `+ 추가` category action real
3. Introduce custom category storage and editing
4. Add expense edit and delete
5. Move recurring expenses from mock data to store-backed data
6. Design the CloudKit household sharing layer
7. Apply owner-only balance visibility when balance UI is added back

## 22. Build Verification

- Build command used repeatedly:
  - `xcodebuild -project PocketSync.xcodeproj -scheme PocketSync -destination 'generic/platform=iOS' -derivedDataPath /tmp/PocketSyncDerivedData CODE_SIGNING_ALLOWED=NO build`
- Current state after the latest changes:
  - build succeeds

## 23. Repo State

- Current branch: `main`
- Remote:
  - `origin -> https://github.com/jkgooooooo/PocketSync.git`
- There are currently uncommitted local changes related to:
  - domain models
  - store
  - expense entry
  - timeline row
  - category layout
