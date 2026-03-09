import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("wateringRemindersEnabled") private var wateringRemindersEnabled = false
    @AppStorage("defaultWateringInterval") private var defaultWateringInterval = 7

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: isDarkMode ? "moon.fill" : "sun.max.fill")
                    }
                    .tint(Color("LeafGreen"))
                }

                Section("Notifications") {
                    Toggle(isOn: $wateringRemindersEnabled) {
                        Label("Watering Reminders", systemImage: "bell.fill")
                    }
                    .tint(Color("LeafGreen"))
                }

                Section("Defaults") {
                    Stepper(value: $defaultWateringInterval, in: 1...30) {
                        Label("Water every \(defaultWateringInterval) days", systemImage: "drop.fill")
                    }
                }

                Section("About") {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Developer", systemImage: "person.fill")
                        Spacer()
                        Text("Leafy Team")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("Built with", systemImage: "swift")
                        Spacer()
                        Text("SwiftUI + SwiftData")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    } label: {
                        Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("EarthBrown"))
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
