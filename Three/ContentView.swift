import SwiftUI
import SwiftData

enum GardenSegment: String, CaseIterable {
    case garden = "Garden"
    case care = "Care"
    case journal = "Journal"
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.dateAdded, order: .reverse) private var allPlants: [Plant]
    @State private var selectedSegment: GardenSegment = .garden
    @State private var showingAddPlant = false
    @State private var showingStats = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedSegment) {
                    ForEach(GardenSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)

                Group {
                    switch selectedSegment {
                    case .garden:
                        GardenView()
                    case .care:
                        CareView()
                    case .journal:
                        JournalView()
                    }
                }
                .animation(AppAnimation.smooth, value: selectedSegment)
            }
            .background(Color("Cream"))
            .navigationTitle("Plant Care")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color("EarthBrown"))
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        showingStats = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(Color("EarthBrown"))
                    }
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("LeafGreen"))
                    }
                }
            }
            .fullScreenCover(isPresented: $showingAddPlant) {
                AddPlantView()
            }
            .sheet(isPresented: $showingStats) {
                StatsView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
        .tint(Color("LeafGreen"))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
