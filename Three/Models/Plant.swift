import Foundation
import SwiftData

@Model
final class Plant {
    var id: UUID
    var name: String
    var nickname: String
    var species: PlantSpecies
    var location: PlantLocation
    var imageData: Data?
    var dateAdded: Date
    var lastWatered: Date?
    var wateringIntervalDays: Int
    var lastFertilized: Date?
    var fertilizingIntervalDays: Int
    var healthStatus: HealthStatus
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \CareEvent.plant)
    var careEvents: [CareEvent]

    @Relationship(deleteRule: .cascade, inverse: \GrowthPhoto.plant)
    var growthPhotos: [GrowthPhoto]

    init(
        name: String,
        nickname: String = "",
        species: PlantSpecies,
        location: PlantLocation = .livingRoom,
        imageData: Data? = nil,
        wateringIntervalDays: Int = 7,
        fertilizingIntervalDays: Int = 30,
        healthStatus: HealthStatus = .healthy,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.nickname = nickname
        self.species = species
        self.location = location
        self.imageData = imageData
        self.dateAdded = Date()
        self.lastWatered = nil
        self.wateringIntervalDays = wateringIntervalDays
        self.lastFertilized = nil
        self.fertilizingIntervalDays = fertilizingIntervalDays
        self.healthStatus = healthStatus
        self.notes = notes
        self.careEvents = []
        self.growthPhotos = []
    }

    var daysSinceLastWatered: Int? {
        guard let lastWatered else { return nil }
        return Calendar.current.dateComponents([.day], from: lastWatered, to: Date()).day
    }

    var daysUntilNextWatering: Int? {
        guard let lastWatered else { return nil }
        guard let nextDate = Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: lastWatered) else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day
    }

    var needsWaterToday: Bool {
        guard let daysUntil = daysUntilNextWatering else { return lastWatered == nil }
        return daysUntil <= 0
    }

    var daysSinceLastFertilized: Int? {
        guard let lastFertilized else { return nil }
        return Calendar.current.dateComponents([.day], from: lastFertilized, to: Date()).day
    }

    var daysUntilNextFertilizing: Int? {
        guard let lastFertilized else { return nil }
        guard let nextDate = Calendar.current.date(byAdding: .day, value: fertilizingIntervalDays, to: lastFertilized) else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day
    }

    var needsFertilizerToday: Bool {
        guard let daysUntil = daysUntilNextFertilizing else { return lastFertilized == nil }
        return daysUntil <= 0
    }

    var displayName: String {
        nickname.isEmpty ? name : nickname
    }
}
