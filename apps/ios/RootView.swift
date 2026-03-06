import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isOnboardingCompleted {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}
