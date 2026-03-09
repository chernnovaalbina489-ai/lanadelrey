import SwiftUI
import SwiftData

@main
struct ThreeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : nil)
        }
        .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self])
    }
}
