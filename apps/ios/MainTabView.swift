import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            TodayPlaceholderView()
                .tag(KalTab.today)
                .tabItem {
                    Label("Today", systemImage: "sun.max")
                }

            ScanMealPlaceholderView()
                .tag(KalTab.scanMeal)
                .tabItem {
                    Label("Scan Meal", systemImage: "camera")
                }

            HistoryPlaceholderView()
                .tag(KalTab.history)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ProfilePlaceholderView()
                .tag(KalTab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
