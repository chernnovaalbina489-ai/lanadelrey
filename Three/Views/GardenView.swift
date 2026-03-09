import SwiftUI
import SwiftData

struct GardenView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.dateAdded, order: .reverse) private var allPlants: [Plant]
    @State private var selectedSpecies: PlantSpecies?

    private var filteredPlants: [Plant] {
        if let species = selectedSpecies {
            return allPlants.filter { $0.species == species }
        }
        return allPlants
    }

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        VStack(spacing: 0) {
            speciesChips
                .padding(.vertical, 8)

            if filteredPlants.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(filteredPlants.enumerated()), id: \.element.id) { index, plant in
                            NavigationLink(destination: PlantDetailView(plant: plant)) {
                                PlantCardView(plant: plant)
                            }
                            .buttonStyle(.plain)
                            .staggeredAppear(index: index)
                            .contextMenu {
                                Button {
                                    quickWater(plant)
                                } label: {
                                    Label("Water Now", systemImage: "drop.fill")
                                }
                                Button(role: .destructive) {
                                    deletePlant(plant)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private var speciesChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                OrganicChip(title: "All", icon: "square.grid.2x2.fill", isSelected: selectedSpecies == nil) {
                    withAnimation(.snappy) { selectedSpecies = nil }
                }
                ForEach(PlantSpecies.allCases) { species in
                    OrganicChip(title: species.displayName, icon: species.iconName, isSelected: selectedSpecies == species) {
                        withAnimation(.snappy) {
                            selectedSpecies = selectedSpecies == species ? nil : species
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "leaf")
                .font(.system(size: 64))
                .foregroundStyle(Color("LeafGreen").opacity(0.4))
            Text("Your garden is empty")
                .font(.title2.bold())
                .foregroundStyle(Color("EarthBrown"))
            Text("Tap + to add your first plant")
                .font(.subheadline)
                .foregroundStyle(Color("EarthBrown").opacity(0.6))
            Spacer()
        }
    }

    private func quickWater(_ plant: Plant) {
        let event = CareEvent(type: .watering, plant: plant)
        modelContext.insert(event)
        plant.careEvents.append(event)
        plant.lastWatered = Date()
    }

    private func deletePlant(_ plant: Plant) {
        withAnimation {
            modelContext.delete(plant)
        }
    }
}

struct OrganicChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color("LeafGreen") : Color("SoftBeige"))
            .foregroundStyle(isSelected ? .white : Color("EarthBrown"))
            .clipShape(Capsule())
        }
    }
}

struct PlantCardView: View {
    let plant: Plant

    private var speciesEmoji: String {
        switch plant.species {
        case .succulent: return "🪴"
        case .tropical: return "🌿"
        case .flowering: return "🌸"
        case .herb: return "🌱"
        case .fern: return "🍀"
        case .cactus: return "🌵"
        case .vine: return "🌾"
        case .tree: return "🌳"
        }
    }

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("SoftBeige"))
                    .aspectRatio(1, contentMode: .fit)

                if let imageData = plant.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                } else {
                    Text(speciesEmoji)
                        .font(.system(size: 48))
                }
            }
            .overlay(alignment: .topTrailing) {
                WaterDropIndicator(plant: plant)
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.displayName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("EarthBrown"))
                    .lineLimit(1)

                Text(plant.species.displayName)
                    .font(.caption)
                    .foregroundStyle(Color("EarthBrown").opacity(0.6))
                    .lineLimit(1)

                HealthBar(status: plant.healthStatus)
            }
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color("EarthBrown").opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct HealthBar: View {
    let status: HealthStatus

    private var progress: Double {
        switch status {
        case .thriving: return 1.0
        case .healthy: return 0.8
        case .needsAttention: return 0.5
        case .struggling: return 0.3
        case .dormant: return 0.15
        }
    }

    private var barColor: Color {
        switch status {
        case .thriving, .healthy: return Color("LeafGreen")
        case .needsAttention: return .yellow
        case .struggling: return .orange
        case .dormant: return .gray
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color("EarthBrown").opacity(0.1))

                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}

struct WaterDropIndicator: View {
    let plant: Plant

    private var filledDrops: Int {
        guard let daysUntil = plant.daysUntilNextWatering else { return 0 }
        let interval = max(plant.wateringIntervalDays, 1)
        let ratio = Double(daysUntil) / Double(interval)
        if ratio > 0.66 { return 3 }
        if ratio > 0.33 { return 2 }
        if ratio > 0 { return 1 }
        return 0
    }

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < filledDrops ? "drop.fill" : "drop")
                    .font(.system(size: 10))
                    .foregroundStyle(index < filledDrops ? Color.blue.opacity(0.8) : Color("EarthBrown").opacity(0.3))
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        GardenView()
    }
    .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
