## 1. Goal
Implement a tighter local meal-tracking loop for Iteration 4 inside `apps/ios` by improving shared in-memory meal data, making `Today` truly today-based, grouping `History` by day, strengthening meal review/save validation, and adding a simple manual add path that avoids the fake scan step when the user already knows the meal.

## 2. Scope
Included:
- Work only in `apps/ios`.
- SwiftUI-only changes.
- In-memory/shared local state only.
- A more robust `LoggedMeal` representation for local UX.
- `Today` showing today-only totals, remaining calories, macro progress, and today’s meal list.
- `History` grouped by day and sorted correctly.
- A manual add / quick add path that reuses the current scan/review navigation.
- Lightweight meal review validation and save-flow cleanup.

Explicitly excluded:
- Backend, Supabase, auth, persistence, APIs, real AI, camera, photo picker, uploads.
- Broad redesigns, new architecture layers, or feature creep.
- Ingredient-level modeling, meal photos, editing past meals, deletion flows, or analytics.

## 3. Existing context
- `apps/ios/KalApp.swift` creates a single shared `AppState`, so Iteration 3 already uses one in-memory source of truth for the session.
- `apps/ios/AppState.swift` currently holds onboarding state, daily target, selected tab, and `savedMeals`.
- `LoggedMeal` already exists in `AppState.swift`, but it is only strong enough for a flat session log. Current consumed totals sum across all `savedMeals`, not meals from the current day.
- `apps/ios/MainTabView.swift` already gives the app the four-tab structure, and the selected tab is controlled by `appState.selectedTab`.
- `apps/ios/PlaceholdersView.swift` currently contains all major screens:
  - `TodayPlaceholderView` shows calories/macros from `appState`, but those totals currently include every saved meal in memory.
  - `ScanMealPlaceholderView` already has mock scan buttons, fake loading, and `navigationDestination(item:)` into `MealReviewView`.
  - `MealReviewView` already supports editing and basic validation, then saves into shared state and returns to `Today`.
  - `HistoryPlaceholderView` is still a flat reverse-chronological list rather than day-grouped history.
- Because the current app is intentionally compact, the narrowest safe Iteration 4 path is to keep working inside `AppState.swift` and `PlaceholdersView.swift`, not introduce view models or a new routing layer.

## 4. Proposed user flow
1. User lands on `Today` and sees:
   - today's consumed calories
   - remaining calories vs target
   - macro progress
   - a compact list of meals logged today
2. If no meal has been logged today, `Today` still shows the summary cards plus a light empty state for the meal list and the existing primary action to log a meal.
3. User taps `Scan a Meal` from `Today` or opens the `Scan Meal` tab directly.
4. In `ScanMealPlaceholderView`, user sees three lightweight entry paths:
   - `Take Photo` -> existing mock scan delay -> review screen
   - `Choose Photo` -> existing mock scan delay -> review screen
   - `Add Manually` or `Quick Add` -> no fake scan delay -> same review screen with blank/default values
5. `MealReviewView` stays the single save screen for both scanned and manual flows.
6. On save, the form validates required fields and numeric ranges, converts the draft into a `LoggedMeal`, appends it to shared state, and returns the user to `Today`.
7. `Today` refreshes immediately from shared state.
8. `History` shows all saved meals grouped by day, newest day first, newest meal first within each day.

## 5. State changes needed
The smallest robust Iteration 4 state change is to keep one stronger saved-meal model and derive everything else from it.

Recommended `LoggedMeal` shape:
- `id: UUID`
- `name: String`
- `calories: Int`
- `protein: Int`
- `carbs: Int`
- `fat: Int`
- `loggedAt: Date`
- `source: LoggedMealSource`

Recommended `LoggedMealSource`:
- `.scanMock`
- `.manual`

Why this is the simplest robust representation:
- `loggedAt` is enough to derive "today only" behavior and day-grouped history.
- `source` is the only extra field worth adding now because it cleanly distinguishes scan vs manual add without pulling in future-only complexity.
- No need to add photo, notes, meal type, IDs from APIs, or per-item nutrition breakdown.

Recommended `AppState` additions/refinements:
- Keep `@Published var savedMeals: [LoggedMeal]`.
- Replace global consumed-total assumptions with today-specific derived properties:
  - `todayMeals`
  - `todayConsumedCalories`
  - `todayConsumedProtein`
  - `todayConsumedCarbs`
  - `todayConsumedFat`
- Keep `saveMeal(_:)`.
- Optionally add one small helper for sorted meals, but avoid adding UI-specific grouping structures into `AppState`.

How `Today` should derive today-only meals and totals:
- Filter `savedMeals` with `Calendar.current.isDate(meal.loggedAt, inSameDayAs: Date())`.
- Sort the filtered meals by `loggedAt` descending.
- Reduce only those meals for calories/macros.
- Compute remaining calories as `max(target.calories - todayConsumedCalories, 0)`.

This is an important Iteration 4 correction because the current totals in `AppState.swift` include all in-memory meals, not just today's.

## 6. Data model changes
Local Swift-only changes:
- Extend `LoggedMeal` with `source`.
- Add `LoggedMealSource` enum.
- Keep `MealDraft` local to the scan/review flow.
- For manual add, either:
  - reuse `MealDraft` with an empty/default initializer, or
  - add a lightweight `MealDraft.manualDefault()` helper.

No backend, persistence, API, or auth contract changes.

## 7. Affected files
Modify:
- `apps/ios/AppState.swift`
- `apps/ios/PlaceholdersView.swift`

Likely unchanged:
- `apps/ios/MainTabView.swift`
- `apps/ios/RootView.swift`
- `apps/ios/KalApp.swift`

Do not create extra files unless `PlaceholdersView.swift` becomes unreasonably hard to follow during implementation. For this iteration, keeping the work in the current files is the more appropriate choice.

## 8. Step-by-step implementation plan
1. Tighten the shared saved-meal model in `AppState.swift`.
- Add `LoggedMealSource`.
- Extend `LoggedMeal` with `source`.
- Keep the model meal-level only.

2. Change shared derived state from "all session meals" to "today-only meals".
- Add `todayMeals` computed property using `Calendar.current`.
- Add today-only calorie and macro totals derived from `todayMeals`.
- Keep `savedMeals` as the full session history.

3. Keep `saveMeal(_:)` minimal.
- Accept a finished `LoggedMeal`.
- Append to `savedMeals`.
- Do not mix temporary draft state into `AppState`.

4. Upgrade `TodayPlaceholderView` to a real today screen without making it heavy.
- Keep the existing summary-card pattern.
- Use today-only totals instead of global session totals.
- Add a compact meal list below the summary.
- If there are no meals today, show a lightweight empty state inside the screen rather than a full-screen takeover.
- Keep the existing `Scan a Meal` primary action.

5. Implement the simplest "today meal list" presentation.
- Use a basic vertical stack or lightweight `List`/`ForEach` of today's meals.
- Each row should show:
  - meal name
  - calories and macros in one compact line
  - logged time
  - optional small source label if useful
- Do not add row expansion, editing, swipe actions, or nested cards.

6. Add a simple manual add path inside `ScanMealPlaceholderView`.
- Add a third action such as `Add Manually`.
- Reuse the same `NavigationStack` and `navigationDestination(item:)`.
- For manual add, skip fake analysis and push directly to `MealReviewView` with a blank/default draft.
- Keep navigation local to the scan tab; do not add global routing.

7. Keep scan and manual flows converging into one review screen.
- `Take Photo` and `Choose Photo` continue using mock presets.
- `Add Manually` opens the same review form.
- The only difference should be how the initial draft is created and which `source` is assigned on save.

8. Clean up `MealReviewView` validation and save UX.
- Keep the current inline validation message approach.
- Tighten `canAttemptSave` so it reflects parseable numeric values, not just non-empty strings.
- Trim whitespace from meal name before validation.
- Use the same numeric range validation already present, keeping it lightweight.
- Clear or update the validation message as inputs change so the screen feels less sticky after corrections.
- Keep the footer reminding the user that values are estimates.
- For manual add, slightly adjust copy if needed so it does not imply the meal came from a scan.

9. Save flow refinement.
- Build the `LoggedMeal` with `Date()` and the correct `source`.
- Call `appState.saveMeal`.
- Return to `Today` by setting `appState.selectedTab = .today`.
- Reset local scan state cleanly so the scan tab is ready for the next entry.

10. Upgrade `HistoryPlaceholderView` into grouped day history.
- Group `savedMeals` by `Calendar.current.startOfDay(for: meal.loggedAt)`.
- Sort day sections descending.
- Sort meals within each day by `loggedAt` descending.
- Use a simple section header label such as `Today`, `Yesterday`, or a formatted date if the builder can do it cheaply; otherwise a straightforward formatted date is enough.
- Keep the empty state when no meals exist.

11. Verify edge behavior inside the current local-only app loop.
- No meals today -> Today summary still renders safely with zeros.
- A meal saved yesterday in seeded previews or future manual testing should not count toward today totals.
- Multiple meals same day accumulate correctly in summary and list.
- History order stays correct across multiple days.

## 9. Edge cases
- User has saved meals in memory, but none were logged today: `Today` must show zero consumed for today and not accidentally include older meals.
- User manually adds a meal with blank name: save blocked with clear inline validation.
- User types non-numeric or partially numeric macro input: save blocked without crashing.
- User enters huge values by mistake: existing range checks should reject them.
- User backs out of review: nothing is saved.
- User starts a mock scan, then navigates away: local scan state should not leave the screen in a broken loading/review state.
- Multiple meals logged within the same minute: sort should still work using `loggedAt`.
- Day grouping around midnight should rely on `Calendar.current`, not string formatting hacks.

## 10. Risks / things to avoid
- Do not keep using the current all-session consumed totals for `Today`; that would make the UX wrong as soon as meals span more than one day.
- Do not store grouped history sections in shared state; grouping belongs in the view layer or a tiny derived helper, not persisted app state.
- Do not introduce a new service, repository, or MVVM layer for this slice.
- Do not create separate review screens for scan vs manual add; one screen is enough.
- Do not add fake camera/photo-picker scaffolding while implementing manual add.
- Do not over-design `LoggedMeal`; meal-level nutrition plus `loggedAt` and `source` is enough for Iteration 4.
- Do not make `Today` visually heavy with too many cards, charts, or nested containers.
- Do not expand into edit/delete/history-detail flows in the same iteration.

## 11. Definition of Done
- `LoggedMeal` is robust enough for current local UX and includes a minimal `source`.
- `Today` derives meals using today-only filtering, not all saved meals.
- `Today` shows:
  - consumed calories for today
  - remaining calories vs target
  - macro progress for today
  - a compact list of meals logged today
- `History` groups meals by day and sorts both sections and rows correctly.
- `Scan Meal` includes a simple manual add path that reuses current navigation.
- `MealReviewView` provides lightweight but solid validation for both mock-scan and manual flows.
- Saving a meal updates shared in-memory state and immediately reflects in `Today` and `History`.
- All changes stay inside `apps/ios`, use SwiftUI, and avoid speculative architecture.

## 12. Suggested builder handoff
Recommendation: **one builder pass**.

Why one pass is better here:
- The work is tightly coupled across just `AppState.swift` and `PlaceholdersView.swift`.
- `Today`, `History`, and the save/manual flow all depend on the same `LoggedMeal` and today-only derivation.
- Splitting it into two passes would create temporary mismatch risk between the model and UI.

Builder handoff:
- Update `AppState.swift` first so the today-only derivation is correct before touching UI.
- Then update `PlaceholdersView.swift` in one coherent pass:
  - `TodayPlaceholderView`
  - `ScanMealPlaceholderView`
  - `MealReviewView`
  - `HistoryPlaceholderView`
- Keep `MainTabView.swift`, `RootView.swift`, and `KalApp.swift` unchanged unless a tiny label/copy adjustment becomes necessary.
