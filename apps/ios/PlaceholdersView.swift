import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            Form {
                Section("About You") {
                    Picker("Sex", selection: $appState.profile.sex) {
                        ForEach(ProfileSex.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    }

                    TextField("Age", text: $appState.profile.ageInput)
                        .keyboardType(.numberPad)

                    TextField("Height (cm)", text: $appState.profile.heightCmInput)
                        .keyboardType(.numberPad)

                    TextField("Current Weight (kg)", text: $appState.profile.currentWeightKgInput)
                        .keyboardType(.decimalPad)
                }

                Section("Lifestyle") {
                    Picker("Activity Level", selection: $appState.profile.activityLevel) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            Text(level.rawValue)
                        }
                    }

                    Picker("Goal", selection: $appState.profile.goal) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            Text(goal.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button("Complete Onboarding") {
                        appState.completeOnboarding()
                    }
                    .disabled(!appState.canCompleteOnboarding)
                    .frame(maxWidth: .infinity, alignment: .center)
                } footer: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Targets and meal estimates are placeholders for now.")
                        if let validationMessage = appState.onboardingValidationMessage {
                            Text(validationMessage)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Welcome to Kal")
        }
    }
}

struct TodayPlaceholderView: View {
    @EnvironmentObject private var appState: AppState

    private var target: DailyTarget {
        appState.dailyTarget ?? .empty
    }

    private var caloriesEaten: Int {
        appState.selectedDayConsumedCalories
    }

    private var proteinEaten: Int {
        appState.selectedDayConsumedProtein
    }

    private var carbsEaten: Int {
        appState.selectedDayConsumedCarbs
    }

    private var fatEaten: Int {
        appState.selectedDayConsumedFat
    }

    private var dayMeals: [LoggedMeal] {
        appState.selectedDayMeals
    }

    private var caloriesRemaining: Int {
        max(target.calories - caloriesEaten, 0)
    }

    private var selectedDayLabel: String {
        if Calendar.current.isDateInToday(appState.selectedDate) {
            return "Today"
        }
        if Calendar.current.isDateInYesterday(appState.selectedDate) {
            return "Yesterday"
        }

        return appState.selectedDate.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Daily Log")
                        .font(.largeTitle.bold())

                    dateNavigationRow

                    calorieSummaryCard
                    macroProgressCard
                    dayMealsCard

                    Button {
                        appState.openScanMeal()
                    } label: {
                        Label("Scan a Meal", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(16)
            }
        }
    }

    private var dateNavigationRow: some View {
        HStack {
            Button {
                appState.goToPreviousDay()
            } label: {
                Image(systemName: "chevron.left")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)

            Spacer()

            Text(selectedDayLabel)
                .font(.headline)

            Spacer()

            Button {
                appState.goToNextDay()
            } label: {
                Image(systemName: "chevron.right")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.bordered)
            .disabled(!appState.canGoToNextDay)
        }
    }

    private var calorieSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Calories")
                .font(.headline)

            HStack {
                statPill(title: "Target", value: "\(target.calories)")
                statPill(title: "Eaten", value: "\(caloriesEaten)")
                statPill(title: "Remaining", value: "\(caloriesRemaining)")
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var dayMealsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Meals")
                .font(.headline)

            if dayMeals.isEmpty {
                Text("No meals logged for this day.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(dayMeals) { meal in
                    mealRow(meal)
                    if meal.id != dayMeals.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func mealRow(_ meal: LoggedMeal) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(meal.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(meal.loggedAt, style: .time)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                Text("\(meal.calories) kcal • P \(meal.protein)g • C \(meal.carbs)g • F \(meal.fat)g")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(meal.source.rawValue)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.background, in: Capsule())
            }
        }
    }

    private var macroProgressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Macro Progress")
                .font(.headline)

            macroRow(name: "Protein", eaten: proteinEaten, target: target.protein)
            macroRow(name: "Carbs", eaten: carbsEaten, target: target.carbs)
            macroRow(name: "Fat", eaten: fatEaten, target: target.fat)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func macroRow(name: String, eaten: Int, target: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                Spacer()
                Text("\(eaten) / \(target) g")
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: Double(eaten), total: Double(max(target, 1)))
        }
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct ScanMealPlaceholderView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isAnalyzing = false
    @State private var mealDraft: MealDraft?

    var body: some View {
        NavigationStack {
            List {
                Section("Meal Photo") {
                    Button("Take Photo") {
                        runMockScan(with: .takePhoto)
                    }
                        .buttonStyle(.borderedProminent)
                        .disabled(isAnalyzing)

                    Button("Choose Photo") {
                        runMockScan(with: .choosePhoto)
                    }
                    .disabled(isAnalyzing)

                    Button("Add Manually") {
                        startManualAdd()
                    }
                    .disabled(isAnalyzing)
                }

                Section("How Kal Estimates Meals") {
                    Text("Kal uses AI to estimate calories and macros from your meal photo.")
                    Text("You will always be able to review and edit the estimate before saving.")
                }

                if isAnalyzing {
                    Section("Analyzing") {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Estimating meal nutrition...")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Scan Meal")
            .navigationDestination(item: $mealDraft) { draft in
                MealReviewView(initialDraft: draft) { savedMeal in
                    appState.saveMeal(savedMeal)
                    appState.selectedTab = .today
                    mealDraft = nil
                    isAnalyzing = false
                }
            }
        }
    }

    private func runMockScan(with preset: MockMealPreset) {
        guard !isAnalyzing else { return }
        isAnalyzing = true

        Task {
            try? await Task.sleep(nanoseconds: 900_000_000)
            await MainActor.run {
                mealDraft = preset.makeDraft()
                isAnalyzing = false
            }
        }
    }

    private func startManualAdd() {
        guard !isAnalyzing else { return }
        mealDraft = MealDraft.manualDefault()
    }
}

struct HistoryPlaceholderView: View {
    var body: some View {
        TodayPlaceholderView()
    }
}

struct ProfilePlaceholderView: View {
    @EnvironmentObject private var appState: AppState

    private var target: DailyTarget {
        appState.dailyTarget ?? .empty
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Stats") {
                    profileRow(title: "Sex", value: appState.profile.sex.rawValue)
                    profileRow(title: "Age", value: appState.profile.ageInput)
                    profileRow(title: "Height", value: "\(appState.profile.heightCmInput) cm")
                    profileRow(title: "Weight", value: "\(appState.profile.currentWeightKgInput) kg")
                }

                Section("Goal") {
                    profileRow(title: "Goal", value: appState.profile.goal.rawValue)
                    profileRow(title: "Activity", value: appState.profile.activityLevel.rawValue)
                    profileRow(title: "Daily Target", value: "\(target.calories) kcal")
                }

                Section("Settings") {
                    Text("Notification Preferences")
                    Text("Units")
                    Text("Help & Support")
                }
            }
            .navigationTitle("Profile")
        }
    }

    private func profileRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

private struct MealDraft: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var calories: String
    var protein: String
    var carbs: String
    var fat: String
    var source: LoggedMealSource
}

private extension MealDraft {
    static func manualDefault() -> MealDraft {
        MealDraft(
            name: "",
            calories: "",
            protein: "",
            carbs: "",
            fat: "",
            source: .manual
        )
    }
}

private enum MockMealPreset {
    case takePhoto
    case choosePhoto

    func makeDraft() -> MealDraft {
        switch self {
        case .takePhoto:
            return MealDraft(
                name: "Chicken Rice Bowl",
                calories: "620",
                protein: "42",
                carbs: "58",
                fat: "20",
                source: .scanMock
            )
        case .choosePhoto:
            return MealDraft(
                name: "Turkey Sandwich",
                calories: "480",
                protein: "32",
                carbs: "45",
                fat: "18",
                source: .scanMock
            )
        }
    }
}

private struct MealReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let onSave: (LoggedMeal) -> Void

    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var source: LoggedMealSource
    @State private var validationMessage: String?

    init(initialDraft: MealDraft, onSave: @escaping (LoggedMeal) -> Void) {
        self.onSave = onSave
        _name = State(initialValue: initialDraft.name)
        _calories = State(initialValue: initialDraft.calories)
        _protein = State(initialValue: initialDraft.protein)
        _carbs = State(initialValue: initialDraft.carbs)
        _fat = State(initialValue: initialDraft.fat)
        _source = State(initialValue: initialDraft.source)
    }

    var body: some View {
        Form {
            Section("Review Estimate") {
                Text(source == .manual ? "Enter your meal details." : "Review and adjust the estimated meal details.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField("Meal Name", text: $name)
                TextField("Calories", text: $calories)
                    .keyboardType(.numberPad)
                TextField("Protein (g)", text: $protein)
                    .keyboardType(.numberPad)
                TextField("Carbs (g)", text: $carbs)
                    .keyboardType(.numberPad)
                TextField("Fat (g)", text: $fat)
                    .keyboardType(.numberPad)
            }

            if let validationMessage {
                Section {
                    Text(validationMessage)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Save Meal") {
                    saveMeal()
                }
                .disabled(!canAttemptSave)
            } footer: {
                Text("Nutrition values are estimated. Review and adjust before saving.")
            }
        }
        .navigationTitle("Meal Review")
        .onChange(of: name) { _ in validationMessage = nil }
        .onChange(of: calories) { _ in validationMessage = nil }
        .onChange(of: protein) { _ in validationMessage = nil }
        .onChange(of: carbs) { _ in validationMessage = nil }
        .onChange(of: fat) { _ in validationMessage = nil }
    }

    private var canAttemptSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty
            && Int(calories) != nil
            && Int(protein) != nil
            && Int(carbs) != nil
            && Int(fat) != nil
    }

    private func saveMeal() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            validationMessage = "Add a meal name before saving."
            return
        }

        guard let parsedCalories = Int(calories), (1...5_000).contains(parsedCalories) else {
            validationMessage = "Calories must be a number between 1 and 5000."
            return
        }

        guard let parsedProtein = Int(protein), (0...500).contains(parsedProtein) else {
            validationMessage = "Protein must be between 0 and 500 g."
            return
        }

        guard let parsedCarbs = Int(carbs), (0...800).contains(parsedCarbs) else {
            validationMessage = "Carbs must be between 0 and 800 g."
            return
        }

        guard let parsedFat = Int(fat), (0...300).contains(parsedFat) else {
            validationMessage = "Fat must be between 0 and 300 g."
            return
        }

        validationMessage = nil
        onSave(
            LoggedMeal(
                id: UUID(),
                name: trimmedName,
                calories: parsedCalories,
                protein: parsedProtein,
                carbs: parsedCarbs,
                fat: parsedFat,
                loggedAt: appState.loggedDateForSelectedDay(),
                source: source
            )
        )
        dismiss()
    }
}
