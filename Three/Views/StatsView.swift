import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allPlants: [Plant]
    @Query private var allPhotos: [GrowthPhoto]
    @Query(sort: \CareEvent.date, order: .reverse) private var allEvents: [CareEvent]

    @State private var appeared = false

    private var totalWaterings: Int {
        allEvents.filter { $0.type == .watering }.count
    }

    private var averageHealth: Double {
        guard !allPlants.isEmpty else { return 0 }
        let total = allPlants.reduce(0.0) { sum, plant in
            switch plant.healthStatus {
            case .thriving: sum + 5
            case .healthy: sum + 4
            case .needsAttention: sum + 3
            case .struggling: sum + 2
            case .dormant: sum + 1
            }
        }
        return total / Double(allPlants.count)
    }

    private var healthiestPlant: Plant? {
        allPlants.max { lhs, rhs in
            healthScore(lhs.healthStatus) < healthScore(rhs.healthStatus)
        }
    }

    private var needsMostAttention: Plant? {
        allPlants.min { lhs, rhs in
            healthScore(lhs.healthStatus) < healthScore(rhs.healthStatus)
        }
    }

    private var wateringStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()

        let wateringEvents = allEvents.filter { $0.type == .watering }

        for _ in 0..<365 {
            let hasWatering = wateringEvents.contains { event in
                calendar.isDate(event.date, inSameDayAs: checkDate)
            }
            let plantsNeedWater = allPlants.contains { plant in
                guard let lastWatered = plant.lastWatered else { return true }
                guard let nextDate = calendar.date(byAdding: .day, value: plant.wateringIntervalDays, to: lastWatered) else { return false }
                return calendar.compare(nextDate, to: checkDate, toGranularity: .day) == .orderedAscending
            }

            if plantsNeedWater && !hasWatering {
                break
            }
            if hasWatering || !plantsNeedWater {
                streak += 1
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    summaryCards
                    speciesBars
                    locationDistribution
                    careFrequencySection
                    highlightCards
                    streakCard
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color("Cream"))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("EarthBrown"))
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(AppAnimation.cardAppear) {
                        appeared = true
                    }
                }
            }
        }
    }

    private var summaryCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            OrganicStatCard(
                title: "Plants",
                value: allPlants.count,
                icon: "leaf.fill",
                color: Color("LeafGreen"),
                appeared: appeared
            )
            .staggeredAppear(index: 0)

            OrganicStatCard(
                title: "Waterings",
                value: totalWaterings,
                icon: "drop.fill",
                color: .blue,
                appeared: appeared
            )
            .staggeredAppear(index: 1)

            OrganicStatCard(
                title: "Photos",
                value: allPhotos.count,
                icon: "camera.fill",
                color: .teal,
                appeared: appeared
            )
            .staggeredAppear(index: 2)
        }
    }

    private var speciesBars: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Species")
                .font(.headline)
                .foregroundStyle(Color("EarthBrown"))

            let speciesCounts = Dictionary(grouping: allPlants, by: { $0.species })
            let maxCount = speciesCounts.values.map(\.count).max() ?? 1

            ForEach(PlantSpecies.allCases) { species in
                let count = speciesCounts[species]?.count ?? 0
                HStack(spacing: 10) {
                    Image(systemName: species.iconName)
                        .font(.caption)
                        .frame(width: 20)
                        .foregroundStyle(Color("LeafGreen"))

                    Text(species.displayName)
                        .font(.caption)
                        .foregroundStyle(Color("EarthBrown"))
                        .frame(width: 75, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("LeafGreen").gradient)
                            .frame(width: appeared ? geo.size.width * CGFloat(count) / CGFloat(max(maxCount, 1)) : 0)
                            .animation(AppAnimation.cardAppear.delay(AppAnimation.staggerDelay(index: PlantSpecies.allCases.firstIndex(of: species) ?? 0)), value: appeared)
                    }
                    .frame(height: 16)

                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var locationDistribution: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Location")
                .font(.headline)
                .foregroundStyle(Color("EarthBrown"))

            let locationCounts = Dictionary(grouping: allPlants, by: { $0.location })
            let maxCount = locationCounts.values.map(\.count).max() ?? 1

            ForEach(PlantLocation.allCases) { location in
                let count = locationCounts[location]?.count ?? 0
                HStack(spacing: 10) {
                    Image(systemName: location.iconName)
                        .font(.caption)
                        .frame(width: 20)
                        .foregroundStyle(Color("EarthBrown"))

                    Text(location.displayName)
                        .font(.caption)
                        .foregroundStyle(Color("EarthBrown"))
                        .frame(width: 75, alignment: .leading)

                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("EarthBrown").gradient)
                            .frame(width: appeared ? geo.size.width * CGFloat(count) / CGFloat(max(maxCount, 1)) : 0)
                            .animation(AppAnimation.cardAppear.delay(AppAnimation.staggerDelay(index: PlantLocation.allCases.firstIndex(of: location) ?? 0)), value: appeared)
                    }
                    .frame(height: 16)

                    Text("\(count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var careFrequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care Frequency")
                .font(.headline)
                .foregroundStyle(Color("EarthBrown"))

            let monthlyData = lastSixMonthsData()
            let maxCare = monthlyData.map(\.count).max() ?? 1

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(monthlyData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: 6) {
                        Text("\(data.count)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.5))

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("LeafGreen").gradient)
                            .frame(height: appeared ? max(CGFloat(data.count) / CGFloat(max(maxCare, 1)) * 100, data.count > 0 ? 8 : 2) : 2)
                            .animation(AppAnimation.cardAppear.delay(AppAnimation.staggerDelay(index: index)), value: appeared)

                        Text(data.label)
                            .font(.caption2)
                            .foregroundStyle(Color("EarthBrown").opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var highlightCards: some View {
        VStack(spacing: 12) {
            if let healthiest = healthiestPlant {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(Color("LeafGreen"))
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Healthiest Plant")
                            .font(.caption)
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        Text(healthiest.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown"))
                    }

                    Spacer()

                    Text(healthiest.healthStatus.displayName)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(healthiest.healthStatus.color.opacity(0.15))
                        .foregroundStyle(healthiest.healthStatus.color)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            if let struggling = needsMostAttention, struggling.id != healthiestPlant?.id {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Needs Most Attention")
                            .font(.caption)
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        Text(struggling.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown"))
                    }

                    Spacer()

                    Text(struggling.healthStatus.displayName)
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(struggling.healthStatus.color.opacity(0.15))
                        .foregroundStyle(struggling.healthStatus.color)
                        .clipShape(Capsule())
                }
                .padding(14)
                .background(Color.white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    private var streakCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text("Watering Streak")
                    .font(.caption)
                    .foregroundStyle(Color("EarthBrown").opacity(0.6))
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    AnimatedCounter(value: appeared ? wateringStreak : 0, font: .title2.bold(), color: Color("EarthBrown"))
                    Text("days")
                        .font(.subheadline)
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func healthScore(_ status: HealthStatus) -> Int {
        switch status {
        case .thriving: 5
        case .healthy: 4
        case .needsAttention: 3
        case .struggling: 2
        case .dormant: 1
        }
    }

    private func lastSixMonthsData() -> [(label: String, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        var result: [(label: String, count: Int)] = []

        for i in (0..<6).reversed() {
            guard let monthDate = calendar.date(byAdding: .month, value: -i, to: now) else { continue }
            let month = calendar.component(.month, from: monthDate)
            let year = calendar.component(.year, from: monthDate)

            let count = allEvents.filter { event in
                let eMonth = calendar.component(.month, from: event.date)
                let eYear = calendar.component(.year, from: event.date)
                return eMonth == month && eYear == year
            }.count

            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let label = formatter.string(from: monthDate)

            result.append((label: label, count: count))
        }

        return result
    }
}

struct OrganicStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let appeared: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            AnimatedCounter(value: appeared ? value : 0, font: .title2.bold(), color: Color("EarthBrown"))

            Text(title)
                .font(.caption)
                .foregroundStyle(Color("EarthBrown").opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
