import Foundation
import Combine

enum KalTab: Hashable {
    case today
    case scanMeal
    case history
    case profile
}

enum ProfileSex: String, CaseIterable {
    case female = "Female"
    case male = "Male"
}

enum ActivityLevel: String, CaseIterable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
}

enum GoalType: String, CaseIterable {
    case lose = "Lose"
    case maintain = "Maintain"
    case gain = "Gain"
}

struct UserProfile {
    var sex: ProfileSex = .female
    var ageInput: String = "28"
    var heightCmInput: String = "170"
    var currentWeightKgInput: String = "72"
    var activityLevel: ActivityLevel = .moderate
    var goal: GoalType = .lose
}

struct DailyTarget {
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int

    static let empty = DailyTarget(calories: 0, protein: 0, carbs: 0, fat: 0)
}

struct LoggedMeal: Identifiable {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let loggedAt: Date
    let source: LoggedMealSource
}

enum LoggedMealSource: String {
    case scanMock = "Scan"
    case manual = "Manual"
}

final class AppState: ObservableObject {
    @Published var isOnboardingCompleted = false
    @Published var selectedTab: KalTab = .today
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var profile = UserProfile()
    @Published var dailyTarget: DailyTarget?
    @Published var onboardingValidationMessage: String?
    @Published var savedMeals: [LoggedMeal] = []

    var todayMeals: [LoggedMeal] {
        meals(for: Date())
    }

    var selectedDayMeals: [LoggedMeal] {
        meals(for: selectedDate)
    }

    var canGoToNextDay: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.startOfDay(for: selectedDate) < today
    }

    func meals(for date: Date) -> [LoggedMeal] {
        let day = Calendar.current.startOfDay(for: date)
        return savedMeals
            .filter { Calendar.current.isDate($0.loggedAt, inSameDayAs: day) }
            .sorted { $0.loggedAt > $1.loggedAt }
    }

    func consumedCalories(for date: Date) -> Int {
        meals(for: date).reduce(0) { $0 + $1.calories }
    }

    func consumedProtein(for date: Date) -> Int {
        meals(for: date).reduce(0) { $0 + $1.protein }
    }

    func consumedCarbs(for date: Date) -> Int {
        meals(for: date).reduce(0) { $0 + $1.carbs }
    }

    func consumedFat(for date: Date) -> Int {
        meals(for: date).reduce(0) { $0 + $1.fat }
    }

    var todayConsumedCalories: Int {
        consumedCalories(for: Date())
    }

    var selectedDayConsumedCalories: Int {
        consumedCalories(for: selectedDate)
    }

    var todayConsumedProtein: Int {
        consumedProtein(for: Date())
    }

    var selectedDayConsumedProtein: Int {
        consumedProtein(for: selectedDate)
    }

    var todayConsumedCarbs: Int {
        consumedCarbs(for: Date())
    }

    var selectedDayConsumedCarbs: Int {
        consumedCarbs(for: selectedDate)
    }

    var todayConsumedFat: Int {
        consumedFat(for: Date())
    }

    var selectedDayConsumedFat: Int {
        consumedFat(for: selectedDate)
    }

    func goToPreviousDay() {
        guard let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else {
            return
        }
        selectedDate = Calendar.current.startOfDay(for: previousDay)
    }

    func goToNextDay() {
        guard canGoToNextDay,
              let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return
        }

        let today = Calendar.current.startOfDay(for: Date())
        let normalizedNextDay = Calendar.current.startOfDay(for: nextDay)
        selectedDate = min(normalizedNextDay, today)
    }

    func loggedDateForSelectedDay(now: Date = Date()) -> Date {
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)

        var combinedComponents = DateComponents()
        combinedComponents.year = dayComponents.year
        combinedComponents.month = dayComponents.month
        combinedComponents.day = dayComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        combinedComponents.second = timeComponents.second
        combinedComponents.nanosecond = timeComponents.nanosecond

        return calendar.date(from: combinedComponents) ?? selectedDate
    }

    var canCompleteOnboarding: Bool {
        Int(profile.ageInput) != nil
            && Int(profile.heightCmInput) != nil
            && Double(profile.currentWeightKgInput) != nil
    }

    func completeOnboarding() {
        guard
            let age = Int(profile.ageInput),
            (13...100).contains(age),
            let heightCm = Int(profile.heightCmInput),
            (100...250).contains(heightCm),
            let weightKg = Double(profile.currentWeightKgInput),
            (30...300).contains(weightKg)
        else {
            onboardingValidationMessage = "Enter valid age, height, and weight values."
            return
        }

        dailyTarget = Self.deriveTargets(weightKg: weightKg, activityLevel: profile.activityLevel, goal: profile.goal)
        onboardingValidationMessage = nil
        isOnboardingCompleted = true
        selectedTab = .today
    }

    func openScanMeal() {
        selectedTab = .scanMeal
    }

    func saveMeal(_ meal: LoggedMeal) {
        savedMeals.append(meal)
    }

    private static func deriveTargets(weightKg: Double, activityLevel: ActivityLevel, goal: GoalType) -> DailyTarget {
        let baseCalories = Int(weightKg * 30)

        let activityAdjustment: Int
        switch activityLevel {
        case .low:
            activityAdjustment = -150
        case .moderate:
            activityAdjustment = 0
        case .high:
            activityAdjustment = 150
        }

        let goalAdjustment: Int
        switch goal {
        case .lose:
            goalAdjustment = -300
        case .maintain:
            goalAdjustment = 0
        case .gain:
            goalAdjustment = 250
        }

        let calories = max(baseCalories + activityAdjustment + goalAdjustment, 1_200)
        let protein = max(Int(weightKg * (goal == .lose ? 2.0 : 1.6)), 60)
        let fat = max(Int((Double(calories) * 0.25) / 9.0), 40)
        let carbs = max((calories - (protein * 4 + fat * 9)) / 4, 50)

        return DailyTarget(calories: calories, protein: protein, carbs: carbs, fat: fat)
    }
}
