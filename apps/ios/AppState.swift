import Foundation
import Combine

enum KalTab: Hashable {
    case today
    case scanMeal
    case history
    case profile
}

final class AppState: ObservableObject {
    @Published var isOnboardingCompleted = false
    @Published var selectedTab: KalTab = .today

    func completeOnboarding() {
        isOnboardingCompleted = true
        selectedTab = .today
    }

    func openScanMeal() {
        selectedTab = .scanMeal
    }
}
