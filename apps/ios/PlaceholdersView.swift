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

    // Explicitly mocked for this iteration.
    private let caloriesEaten = 1_240
    private let proteinEaten = 78
    private let carbsEaten = 130
    private let fatEaten = 38

    private var target: DailyTarget {
        appState.dailyTarget ?? .empty
    }

    private var caloriesRemaining: Int {
        max(target.calories - caloriesEaten, 0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Today")
                        .font(.largeTitle.bold())

                    calorieSummaryCard
                    macroProgressCard

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
            ProgressView(value: Double(eaten), total: Double(target))
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
    var body: some View {
        NavigationStack {
            List {
                Section("Meal Photo") {
                    Button("Take Photo") {}
                        .buttonStyle(.borderedProminent)

                    Button("Choose Photo") {}
                }

                Section("How Kal Estimates Meals") {
                    Text("Kal uses AI to estimate calories and macros from your meal photo.")
                    Text("You will always be able to review and edit the estimate before saving.")
                }
            }
            .navigationTitle("Scan Meal")
        }
    }
}

struct HistoryPlaceholderView: View {
    private let groupedMeals: [(day: String, meals: [HistoryMeal])] = [
        (
            day: "Today",
            meals: [
                HistoryMeal(name: "Chicken Bowl", calories: 620, protein: 45, carbs: 58, fat: 19),
                HistoryMeal(name: "Greek Yogurt + Berries", calories: 280, protein: 20, carbs: 24, fat: 9)
            ]
        ),
        (
            day: "Yesterday",
            meals: [
                HistoryMeal(name: "Salmon + Rice", calories: 710, protein: 42, carbs: 65, fat: 27)
            ]
        )
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedMeals, id: \.day) { group in
                    Section(group.day) {
                        ForEach(group.meals) { meal in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.name)
                                    .font(.headline)
                                Text("\(meal.calories) kcal • P \(meal.protein)g • C \(meal.carbs)g • F \(meal.fat)g")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
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

private struct HistoryMeal: Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
}
