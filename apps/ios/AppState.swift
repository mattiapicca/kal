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

final class AppState: ObservableObject {
    @Published var isOnboardingCompleted = false
    @Published var selectedTab: KalTab = .today
    @Published var profile = UserProfile()
    @Published var dailyTarget: DailyTarget?
    @Published var onboardingValidationMessage: String?

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
