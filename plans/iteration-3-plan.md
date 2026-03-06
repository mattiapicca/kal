## 1. Goal
Build the first believable local meal-logging loop in the iOS app so a user can start from `Scan Meal`, go through a fake scan, review and edit a mock estimate, save it into shared in-memory state, and immediately see the result reflected in `Today` and `History` during the current app session.

## 2. Scope
Included:
- iOS-only work inside `apps/ios`.
- SwiftUI-only implementation.
- A fake scan flow with mock meal output.
- A meal review screen with lightweight editing and validation.
- Shared local app state for saved meals.
- `Today` totals derived from saved meals in session.
- `History` rendered from saved meals in session.

Excluded:
- Backend, Supabase, auth, persistence, APIs, camera, photo picker, real AI, uploads, or storage.
- Broad architecture changes, new tabs, or non-MVP features.
- Refactoring the app into many new files unless absolutely needed for compile clarity.

## 3. Existing context
- `apps/ios/KalApp.swift` already creates a single `AppState` and injects it into the app, so shared session state is already set up.
- `apps/ios/AppState.swift` already owns onboarding completion, profile data, daily targets, validation messaging, and selected tab state. That makes it the right place for saved meal state as well.
- `apps/ios/MainTabView.swift` already binds the selected tab to `appState.selectedTab`, so the scan loop can reuse existing tab navigation instead of adding app-wide routing.
- `apps/ios/PlaceholdersView.swift` currently holds all screen implementations:
  - `TodayPlaceholderView` still uses fixed consumed calorie/macro constants.
  - `ScanMealPlaceholderView` is only buttons plus static explanatory text.
  - `HistoryPlaceholderView` is entirely hardcoded sample data.
  - `ProfilePlaceholderView` already reads from shared `AppState`, so Iteration 2’s shared-state pattern is in place.
- The current codebase is intentionally small, so the safest Iteration 3 plan is to extend the existing `AppState` and replace the three placeholder screens with minimal real local behavior rather than introducing view models or a new flow framework.

## 4. Proposed user flow
1. User opens `Scan Meal` from the tab bar or the existing `Scan a Meal` button on `Today`.
2. `ScanMealPlaceholderView` shows the existing fake entry points, but they now trigger a mock scan instead of doing nothing.
3. The simplest mock strategy is:
   - Keep `Take Photo` and `Choose Photo`.
   - Map each button to one of a small set of hardcoded meal presets with believable calories/macros.
   - Show a short local loading state so the flow feels like an analysis step.
4. After the fake scan finishes, navigate within the existing `NavigationStack` from `ScanMealPlaceholderView` to a new `MealReviewView`.
5. `MealReviewView` shows editable fields for:
   - meal name
   - calories
   - protein
   - carbs
   - fat
6. User can either go back without saving or tap `Save Meal`.
7. On save:
   - validate the edited values
   - append the saved meal into shared `AppState`
   - switch back to `Today` for immediate feedback
8. `Today` recomputes consumed totals from saved meals and updates remaining calories/macros.
9. `History` reads the same shared meals array and shows the saved meals from the current app session.

Navigation approach:
- Keep `ScanMealPlaceholderView` as the owner of the scan/review flow.
- Use its existing `NavigationStack` and a local optional draft meal with `navigationDestination(item:)`.
- This avoids global routing, keeps the review screen scoped to the scan tab, and stays compile-friendly.

## 5. State changes needed
Shared state in `AppState`:
- Add a local in-memory array such as `savedMeals: [LoggedMeal]`.
- Add a minimal local meal model for saved meals with:
  - `id`
  - `name`
  - `calories`
  - `protein`
  - `carbs`
  - `fat`
  - `loggedAt`
- Add computed totals derived from `savedMeals`:
  - consumed calories
  - consumed protein
  - consumed carbs
  - consumed fat
- Add one small mutation API such as `saveMeal(_:)` to centralize app-state updates.

Local scan/review state in `ScanMealPlaceholderView` and `MealReviewView`:
- selected mock preset or entry button source
- fake loading flag
- optional draft meal for navigation
- local validation message for review edits

Important boundary:
- Shared `AppState` should only own saved meals and derived consumption totals.
- Draft review state should stay local to the scan flow so `AppState` does not become a dumping ground for temporary UI state.

Today totals computation:
- Replace the hardcoded consumed constants with sums from `appState.savedMeals`.
- `Today` keeps using `dailyTarget` from Iteration 2.
- Remaining calories should be `max(target.calories - consumedCalories, 0)`.
- Macro rows should use the same consumed sums instead of fixed values.

History rendering:
- Replace hardcoded grouped sample meals with `appState.savedMeals`.
- Render in reverse chronological order so the latest save appears first.
- Keep the first version flat and simple rather than recreating grouped sections unless the builder can do it without extra complexity.
- Show a clear empty state when there are no saved meals yet.

## 6. Data model changes
No backend or persistence changes.

Local Swift-only model additions:
- `LoggedMeal`: the saved meal shape stored in shared state.
- `MealDraft`: a lightweight editable review shape used only during the scan/review flow.
- `MockMealPreset` or equivalent: a tiny enum/static list used to seed believable fake analysis results.

Recommended validation before save:
- meal name must be non-empty after trimming
- calories must parse to an integer and be greater than 0
- protein, carbs, and fat must parse to integers and be 0 or greater
- optionally cap obviously absurd values with simple upper bounds so accidental input does not break the UI

## 7. Affected files
Modify:
- `apps/ios/AppState.swift`
- `apps/ios/PlaceholdersView.swift`

Likely unchanged:
- `apps/ios/KalApp.swift`
- `apps/ios/MainTabView.swift`
- `apps/ios/RootView.swift`

Prefer not to create new files for Iteration 3 unless `PlaceholdersView.swift` becomes too crowded. The minimal path is to keep the new review view and local meal types near the existing placeholder screens.

## 8. Step-by-step implementation plan
1. Extend `AppState` with the smallest meal-logging state needed for this iteration.
- Add a saved meal model.
- Add `@Published` session meals storage.
- Add computed consumed totals.
- Add a small `saveMeal` method.

2. Replace `TodayPlaceholderView`’s hardcoded consumed constants with values derived from `AppState`.
- Keep the existing target card structure.
- Compute eaten and remaining values from shared state.
- Preserve the existing `Scan a Meal` button behavior.

3. Upgrade `ScanMealPlaceholderView` from static placeholder to a real fake scan entry point.
- Keep the current buttons for continuity.
- Attach each button to a hardcoded mock preset.
- Add a small loading state to simulate analysis.

4. Add a minimal review destination view within the scan flow.
- Navigate from scan to review using local navigation state.
- Pre-fill the review form with believable mock values.
- Keep the UI narrow: one meal name field and numeric fields for calories/macros.

5. Add lightweight validation before save.
- Disable save for clearly invalid values where easy.
- Re-run final validation on tap.
- Show one inline validation message rather than introducing a full error system.

6. Save confirmed meals into `AppState`.
- Convert the local review draft into a saved meal.
- Append it to shared state.
- Return the user to `Today` by switching `selectedTab` to `.today`.

7. Replace `HistoryPlaceholderView`’s hardcoded grouped content with a list sourced from shared state.
- Show saved meals from the current session only.
- Render newest first.
- Add a simple empty state message when no meals exist.

8. Do a final compile-safety pass.
- Keep all types local and explicit.
- Avoid introducing async work except the minimal fake scan delay if used.
- Avoid broad refactors while wiring the flow.

## 9. Edge cases
- User enters the review screen and backs out without saving: nothing should be added to shared state.
- User clears the meal name or a numeric field during edit: save should be blocked and the validation message should explain why.
- User saves multiple meals in one session: `Today` totals should accumulate correctly and `History` should show all saved meals.
- User opens `History` before saving any meal: show an empty state instead of hardcoded content or a blank list.
- User opens `Today` before logging any meal: eaten totals should be zero, not mock constants.
- Numeric inputs in the review form should avoid negative values and malformed text.
- If `dailyTarget` is unexpectedly missing, `Today` should still render safely using the existing empty fallback rather than crashing.
- Because state is in-memory only, all logged meals disappear on app relaunch; that is expected in this iteration.

## 10. Risks / things to avoid
- Do not move scan/review temporary state into `AppState`; only saved meals need to be shared.
- Do not introduce a fake service layer, repository, or view model abstraction for this small local loop.
- Do not add persistence, networking, camera integration, or AI orchestration under the guise of “preparing for later.”
- Do not keep the old hardcoded Today consumed values or hardcoded History meals alongside the new shared state, or the app will show inconsistent information.
- Do not overcomplicate History grouping; a simple reverse-chronological session list is enough for this slice.
- Do not build a broad meal schema with itemization or ingredient breakdown yet; Iteration 3 only needs meal-level calories/macros.
- Avoid save flows that leave the user stranded in the scan tab after confirmation; returning to `Today` gives the clearest feedback that the loop worked.

## 11. Definition of Done
- User can open `Scan Meal` and start a fake scan from the current screen.
- A believable mock analysis result appears in a meal review screen.
- User can edit meal name, calories, protein, carbs, and fat before saving.
- Save is blocked for invalid values with lightweight inline validation.
- Saving a meal writes it into shared in-memory `AppState`.
- `Today` no longer uses hardcoded consumed constants and instead reflects saved meals from the current session.
- `History` no longer shows hardcoded sample meals and instead renders saved meals from the current session.
- Saving more than one meal accumulates correctly in `Today` and displays all meals in `History`.
- The implementation stays inside `apps/ios`, uses SwiftUI only, and avoids speculative architecture.

## 12. Suggested builder handoff
Implement Iteration 3 as a narrow local-state slice centered on `AppState.swift` and `PlaceholdersView.swift`.

Builder guidance:
- Keep `AppState` responsible for saved meals and derived totals only.
- Keep scan/loading/review draft state local to the scan flow.
- Use the existing `NavigationStack` in `ScanMealPlaceholderView` for review navigation.
- Reuse the current screen structure instead of extracting a new architecture.
- Favor one or two believable hardcoded meal presets over a generic mock engine.
- Return the user to `Today` after save so the end-to-end loop is obvious.
