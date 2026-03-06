## 1. Goal
Connect onboarding inputs to a single local `AppState` source of truth, then have `RootView`, `Today`, and `Profile` all read from that same state so the app shows one consistent user profile and target summary across the iOS app.

## 2. Scope
Included:
- Move onboarding-owned profile fields out of local view state and into shared app state.
- Use shared app state to decide whether the app shows onboarding or the main tabs.
- Replace hardcoded `Today` and `Profile` values with values derived from the shared onboarding/profile state.
- Keep all work inside `apps/ios` and SwiftUI.

Excluded:
- Backend, Supabase, auth, upload, AI analysis, persistence, or cross-device sync.
- New product areas outside the current MVP.
- Full meal logging logic beyond the existing placeholder intake numbers.

## 3. Existing context
- `apps/ios/KalApp.swift` already creates `AppState` and injects it via `.environmentObject`, so the app already has the right top-level dependency flow.
- `apps/ios/AppState.swift` currently only owns `isOnboardingCompleted` and `selectedTab`, plus simple tab/onboarding actions.
- `apps/ios/RootView.swift` is empty, so the onboarding-vs-main-app entry decision is not implemented yet.
- `apps/ios/MainTabView.swift` is already correctly bound to `appState.selectedTab` and likely needs little or no change.
- `apps/ios/PlaceholdersView.swift` contains:
  - `OnboardingView` with local `@State` fields for sex, age, height, weight, activity, and goal.
  - `TodayPlaceholderView` with hardcoded calorie and macro targets.
  - `ProfilePlaceholderView` with hardcoded profile and goal values.
- There is no existing target-calculation or profile model elsewhere in `apps/ios`, so iteration 2 needs a small local state shape added in or near `AppState`.

## 4. Affected files
Modify:
- `apps/ios/AppState.swift`
- `apps/ios/RootView.swift`
- `apps/ios/PlaceholdersView.swift`

Likely unchanged:
- `apps/ios/KalApp.swift`
- `apps/ios/MainTabView.swift`

Optional only if you want to keep `AppState.swift` small:
- Create a small local model file in `apps/ios` for onboarding/profile/target types.

## 5. Data model / state impact
Add shared local state to `AppState` for the onboarding/profile data:
- Sex
- Age
- Height
- Current weight
- Activity level
- Goal

Also add derived or stored target state for:
- Daily calories
- Protein
- Carbs
- Fat

Recommended minimal shape:
- One profile/onboarding data object in `AppState`
- One derived daily target object in `AppState`
- Keep `isOnboardingCompleted` and `selectedTab` as-is

Behavioral state changes:
- `OnboardingView` binds directly to shared app state instead of local view-only state.
- `completeOnboarding()` should validate the shared onboarding values, mark onboarding complete, and ensure targets are available for `Today` and `Profile`.
- No API, backend, or persistence contract changes.

## 6. UX impact
Happy path:
- User enters onboarding values.
- On completion, `RootView` switches to the tab UI.
- `Today` shows targets based on the same shared onboarding data.
- `Profile` shows the same profile values and target summary from the same shared state.

Loading state:
- None needed for this iteration; all state is local and synchronous.

Empty state:
- Before onboarding completion, the app should always show onboarding.
- If target values are missing because onboarding is incomplete, `Today` and `Profile` should not be reachable through the normal flow.

Error state:
- Completion should be blocked if numeric onboarding fields are invalid or empty.
- Keep validation lightweight and local; no backend error handling is needed.

Success state:
- User lands in `Today` after completion and sees personalized values instead of hardcoded placeholders.

## 7. Edge cases
- Numeric text fields contain non-numeric input or partial values.
- Zero or unrealistic values are entered for age, height, or weight.
- User completes onboarding, then navigates to `Profile`; values must match exactly what was entered.
- `Today` target display must not crash if targets cannot be calculated.
- App relaunch behavior is still temporary unless persistence is added later; this plan assumes state resets on fresh launch.

## 8. Acceptance criteria
- `RootView` conditionally shows onboarding or `MainTabView` based on `appState.isOnboardingCompleted`.
- `OnboardingView` no longer owns separate local profile fields as the source of truth.
- Shared `AppState` contains the onboarding/profile values needed by onboarding, today, and profile.
- `TodayPlaceholderView` no longer uses hardcoded target values for calories/macros.
- `ProfilePlaceholderView` no longer uses hardcoded profile/goal values.
- Completing onboarding updates shared state and routes the user into the main tab flow.
- `Today` and `Profile` reflect the same underlying profile/target data.
- No backend or persistence work is introduced.

## 9. Suggested implementation order
1. Extend `AppState` with a minimal profile/onboarding state shape and derived target values.
2. Implement `RootView` as the single app entry switch between onboarding and tabs.
3. Rewire `OnboardingView` to bind directly to shared `AppState`.
4. Update `completeOnboarding()` so it validates inputs, derives targets, and marks onboarding complete.
5. Replace hardcoded `Today` values with shared target data from `AppState`.
6. Replace hardcoded `Profile` values with shared profile and target data from `AppState`.
7. Do a quick pass to ensure `MainTabView` still behaves correctly with the existing selected-tab logic.

## 10. Risks / assumptions
- The repo currently has no target-calculation logic in `apps/ios`, so iteration 2 must either add a very small local calculator or explicitly keep targets as simple derived placeholders from onboarding data.
- "Single source of truth" implies onboarding fields should live in `AppState`, not be copied from local form state on submit.
- Without persistence, onboarding will reset on relaunch; this is acceptable only if iteration 2 is intentionally local-state-only.
- If you want editable profile updates after onboarding, that is a separate follow-up slice and should not be bundled into this iteration unless requested.
