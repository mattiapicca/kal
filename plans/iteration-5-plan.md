## 1. Goal
Implement Iteration 5 as a UX structure update inside `apps/ios`: replace the separate Today-vs-History mental model with one day-based Daily Log experience where the user can move across days, see totals for the selected day, and add meals into that selected date context without changing the app's local-only architecture.

## 2. Scope
Included:
- Work only in `apps/ios`.
- SwiftUI-only changes.
- A single day-based Daily Log UI reused from the current Today/History work.
- Minimal shared-state support for a selected day.
- Daily totals and meal list derived from the selected day.
- Saving scanned/manual meals into the selected day instead of always into the current `Date()`.
- A transitional, low-risk handling of the `History` tab without restructuring navigation.

Explicitly excluded:
- Backend, Supabase, auth, persistence, APIs, real AI, camera, photo picker, uploads.
- Editing/deleting past meals.
- Multi-screen navigation redesign.
- New architecture layers, repositories, or view models.
- Any work outside `apps/ios`.

## 3. Existing context
The current implementation is already close to this iteration, but it is still hard-coded around "today" in shared state and save behavior.

Key repo facts:
- `apps/ios/AppState.swift` owns shared local meal state and currently derives only today-specific computed values.
- `apps/ios/PlaceholdersView.swift` already contains:
  - a real `TodayPlaceholderView`
  - a scan/manual add flow
  - a `MealReviewView`
  - a grouped `HistoryPlaceholderView`
- `apps/ios/MainTabView.swift` still presents separate `Today` and `History` tabs, which is the safest place to preserve app navigation for now.

The two concrete date-coupling points that must change are:

```70:73:apps/ios/AppState.swift
savedMeals
    .filter { Calendar.current.isDate($0.loggedAt, inSameDayAs: Date()) }
    .sorted { $0.loggedAt > $1.loggedAt }
```

```558:568:apps/ios/PlaceholdersView.swift
LoggedMeal(
    id: UUID(),
    name: trimmedName,
    calories: parsedCalories,
    protein: parsedProtein,
    carbs: parsedCarbs,
    fat: parsedFat,
    loggedAt: Date(),
    source: source
)
```

Concrete interpretation:
- The current Today screen is already a good base for a Daily Log screen.
- The current History grouping logic can be reduced because day browsing will move into the main log screen.
- The smallest safe change is to add one shared `selectedDate`, replace today-only derivations with selected-day derivations, and keep the existing tabs/nav shell intact.

## 4. Proposed user flow
1. User opens the current `Today` tab.
2. The screen title/content becomes `Daily Log`, centered on `appState.selectedDate`.
3. At the top of the screen, the user sees:
- a back chevron to go to the previous day
- the selected day label
- a forward chevron to go to the next day
- the forward chevron is disabled when the selected day is today, so future dates are not allowed
4. Daily calorie and macro totals update immediately based on meals whose `loggedAt` falls on the selected day.
5. The meal list below shows only meals for the selected day.
6. If the user taps `Scan a Meal` or uses the scan tab, the existing fake scan/manual flow still runs.
7. On save, the meal is written into the selected day context, not always into the real current day.
8. After save, the app returns to the Daily Log screen and keeps the same selected date visible so the user immediately sees the new meal in context.
9. The `History` tab remains temporarily in the tab bar, but instead of being a separate grouped-history concept, it becomes a transitional entry point to the same day-based Daily Log browsing experience.

Concrete navigation choice:
- Day navigation uses simple back/forward chevrons.
- No future browsing.
- No date picker in this iteration.
- No jump-to-calendar or deep history navigation.

## 5. State changes needed
Minimal shared-state impact in `AppState`:
- Add `@Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())`
- Keep `savedMeals` unchanged as the source of truth.
- Replace Today-specific derivation with date-scoped helpers:
  - `func meals(for date: Date) -> [LoggedMeal]`
  - `func consumedCalories(for date: Date) -> Int`
  - `func consumedProtein(for date: Date) -> Int`
  - `func consumedCarbs(for date: Date) -> Int`
  - `func consumedFat(for date: Date) -> Int`
- Add selected-day convenience wrappers if they reduce view churn:
  - `selectedDayMeals`
  - `selectedDayConsumedCalories`
  - `selectedDayConsumedProtein`
  - `selectedDayConsumedCarbs`
  - `selectedDayConsumedFat`
- Add minimal date-navigation helpers:
  - `func goToPreviousDay()`
  - `func goToNextDay()`
  - `var canGoToNextDay: Bool`

Important choice:
- Do not move scan draft state into `AppState`.
- Only `selectedDate` is added to shared state.
- Draft form values, loading flags, and navigation remain local in `ScanMealPlaceholderView` / `MealReviewView`.

Recommended compatibility choice:
- Either remove `todayMeals` / `todayConsumed*` and update usages directly, or keep them as wrappers around `Date()` temporarily if that makes the builder pass safer.
- The new Daily Log screen should use selected-day helpers, not today-only helpers.

## 6. Data model changes
No backend or API contract changes.

Local Swift-only changes:
- Keep `LoggedMeal` as-is structurally.
- Do not add a new persistence model.
- Do not add a new date-only field.
- Keep `loggedAt: Date` as the single timestamp source of truth.

Required save-behavior change:
- Meal save must build `loggedAt` from `selectedDate` instead of hard-coding `Date()`.

Concrete choice for timestamp creation:
- Use the selected day for year/month/day.
- Reuse the current clock time for hour/minute/second.
- This preserves rough ordering while ensuring the meal belongs to the selected log day.

Recommended helper shape:
- `func loggedDateForSelectedDay(now: Date = Date()) -> Date`
- Internally combine `selectedDate` day components with `now` time components via `Calendar.current.date(from:)`
- If date composition fails unexpectedly, fall back to `selectedDate`

This is safer than always saving at midnight, because it keeps meal rows naturally ordered and avoids stacking all manually added past-day meals at `00:00`.

## 7. Affected files
Modify:
- `apps/ios/AppState.swift`
- `apps/ios/PlaceholdersView.swift`

Likely unchanged:
- `apps/ios/KalApp.swift`
- `apps/ios/RootView.swift`
- `apps/ios/MainTabView.swift`

Optional tiny change only if the builder wants clearer tab copy:
- `apps/ios/MainTabView.swift` for a label tweak only

Preferred minimal path:
- Keep `MainTabView.swift` unchanged and handle the transitional History-tab behavior inside `PlaceholdersView.swift`.

## 8. Step-by-step implementation plan
1. Add minimal selected-date state to `AppState`.
- Introduce `selectedDate` normalized to start-of-day.
- Add `canGoToNextDay`, `goToPreviousDay()`, and `goToNextDay()`.

2. Generalize meal derivation from “today” to “any day”.
- Replace today-only filtering with `meals(for:)`.
- Add selected-day totals derived from `selectedDate`.
- Keep the logic in `AppState`, not in the view.

3. Add one helper for save-date composition.
- Build a `Date` on the selected day using current clock time.
- Reuse it everywhere a meal is saved.
- Avoid sprinkling calendar math into multiple views.

4. Convert `TodayPlaceholderView` into the canonical Daily Log screen.
- Keep the existing summary-card layout.
- Add a top date-navigation row with back/forward chevrons and a selected-day label.
- Rename screen copy from `Today` to `Daily Log`.
- Replace “Meals Logged Today” with selected-day wording such as `Meals` or `Meals for This Day`.
- Derive totals and meal list from `selectedDate`.

5. Keep forward navigation safe.
- Disable the forward button when `selectedDate` is today.
- Do not allow tapping into future dates.
- If defensive clamping is needed in `goToNextDay()`, stop at today.

6. Update save behavior in `MealReviewView`.
- Keep the form and validation largely unchanged.
- Replace `loggedAt: Date()` with the selected-day-composed timestamp.
- Update button copy from `Save Meal to Today` to neutral wording such as `Save Meal`.

7. Preserve scan/manual flow and return behavior.
- Keep `ScanMealPlaceholderView` as the owner of scan/manual draft state.
- On save, continue switching back to the Today tab for minimal disruption.
- Do not reset `selectedDate` on save; the user should return to the same day they were logging against.

8. Introduce the safest transitional History handling.
- Keep the `History` tab present in the tab bar this iteration.
- Replace the old grouped-history screen body with the same day-based Daily Log content or a thin wrapper around that content.
- Do not maintain two separate date-browsing UIs.
- If needed, change only the screen title/copy so both tabs clearly point to the same concept.

Recommended concrete choice:
- Extract shared Daily Log content inside `PlaceholdersView.swift`.
- Have both `TodayPlaceholderView` and `HistoryPlaceholderView` render that same content.
- `Today` remains the primary entry.
- `History` is temporarily just another entry into day browsing, preserving tab structure without a broader nav change.

9. Keep visual and architectural scope tight.
- No new files unless `PlaceholdersView.swift` becomes too messy.
- No refactor into MVVM.
- No separate daily-log service or model layer.

10. Verify behavior against the current app loop.
- Today still works when `selectedDate` is today.
- Going to yesterday shows yesterday-only totals.
- Adding a meal while viewing yesterday saves into yesterday.
- Returning to the Daily Log shows the saved meal on that same selected date.
- History tab no longer presents an alternative grouped-history concept.

## 9. Edge cases
- User has no meals on the selected day: totals show zero and the meal list shows a lightweight empty state.
- User browses backward across many days with no meals: screen still renders safely with zeros and empty list.
- User is on today: forward navigation is disabled.
- User is on yesterday and saves a meal: the meal must appear under yesterday, not under today.
- User enters invalid nutrition values: current validation should still block save.
- User starts from the `History` tab and adds a meal: it should save into the currently selected shared day context.
- Multiple meals saved on a past day should sort by composed `loggedAt` descending.
- Calendar boundaries must use `Calendar.current`, not string comparisons.
- If `selectedDate` somehow drifts into the future through a bug, `goToNextDay()` should clamp at today rather than allow forward browsing.

## 10. Risks / things to avoid
- Do not turn this into a tab-bar redesign.
- Do not keep separate Today and History data-derivation logic alive in parallel.
- Do not introduce a second history-specific grouped UI while also adding day navigation.
- Do not add a date picker, calendar grid, or custom history browser in this iteration.
- Do not push date composition logic into multiple views.
- Do not add persistence or backend hooks.
- Do not reset `selectedDate` to today after every save, or the selected-day workflow breaks.
- Do not rename too many symbols just for conceptual purity if that creates avoidable compile churn.
- Do not change app-wide routing just to remove the temporary `History` tab now.

## 11. Definition of Done
- A shared `selectedDate` exists in `AppState` with minimal modeling impact.
- Daily totals and meal list are derived from `selectedDate`, not hard-coded to `Date()`.
- The main daily log screen supports back/forward day navigation.
- Future dates cannot be navigated to.
- Saving a meal from scan/manual uses the selected day context.
- The save CTA and screen copy no longer imply “today-only” behavior.
- The user returns to the log and sees the saved meal on the same selected date.
- The `History` tab remains temporarily but no longer represents a separate history paradigm; it points to the unified day-based browsing experience.
- All work stays inside `apps/ios`, uses SwiftUI, and preserves current working flows.

## 12. Suggested builder handoff
Implement this in one focused builder pass across `AppState.swift` and `PlaceholdersView.swift`.

Builder guidance:
- Start in `AppState.swift`: add `selectedDate`, day navigation helpers, selected-day derivation helpers, and the selected-day timestamp helper for save.
- Then update `TodayPlaceholderView` into the canonical Daily Log UI.
- Update `MealReviewView` save behavior and copy to be date-neutral.
- Finish by replacing `HistoryPlaceholderView` with a thin wrapper around the same Daily Log content instead of maintaining separate grouped-history UX.
- Keep `MainTabView.swift` unchanged unless a tiny tab label tweak is absolutely needed.
