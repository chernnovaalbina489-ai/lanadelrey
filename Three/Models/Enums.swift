import SwiftUI

enum PlantSpecies: String, Codable, CaseIterable, Identifiable {
    case succulent
    case tropical
    case flowering
    case herb
    case fern
    case cactus
    case vine
    case tree

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .succulent: "Succulent"
        case .tropical: "Tropical"
        case .flowering: "Flowering"
        case .herb: "Herb"
        case .fern: "Fern"
        case .cactus: "Cactus"
        case .vine: "Vine"
        case .tree: "Tree"
        }
    }

    var iconName: String {
        switch self {
        case .succulent: "leaf.fill"
        case .tropical: "leaf.arrow.circlepath"
        case .flowering: "camera.macro"
        case .herb: "carrot.fill"
        case .fern: "leaf"
        case .cactus: "bolt.fill"
        case .vine: "wind"
        case .tree: "tree.fill"
        }
    }
}

enum PlantLocation: String, Codable, CaseIterable, Identifiable {
    case livingRoom
    case bedroom
    case kitchen
    case bathroom
    case balcony
    case office
    case garden

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .livingRoom: "Living Room"
        case .bedroom: "Bedroom"
        case .kitchen: "Kitchen"
        case .bathroom: "Bathroom"
        case .balcony: "Balcony"
        case .office: "Office"
        case .garden: "Garden"
        }
    }

    var iconName: String {
        switch self {
        case .livingRoom: "sofa.fill"
        case .bedroom: "bed.double.fill"
        case .kitchen: "fork.knife"
        case .bathroom: "shower.fill"
        case .balcony: "sun.max.fill"
        case .office: "desktopcomputer"
        case .garden: "tree.fill"
        }
    }
}

enum HealthStatus: String, Codable, CaseIterable, Identifiable {
    case thriving
    case healthy
    case needsAttention
    case struggling
    case dormant

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .thriving: "Thriving"
        case .healthy: "Healthy"
        case .needsAttention: "Needs Attention"
        case .struggling: "Struggling"
        case .dormant: "Dormant"
        }
    }

    var color: Color {
        switch self {
        case .thriving: .green
        case .healthy: .teal
        case .needsAttention: .yellow
        case .struggling: .orange
        case .dormant: .gray
        }
    }
}

enum CareType: String, Codable, CaseIterable, Identifiable {
    case watering
    case fertilizing
    case repotting
    case pruning
    case pestTreatment
    case rotating

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .watering: "Watering"
        case .fertilizing: "Fertilizing"
        case .repotting: "Repotting"
        case .pruning: "Pruning"
        case .pestTreatment: "Pest Treatment"
        case .rotating: "Rotating"
        }
    }

    var iconName: String {
        switch self {
        case .watering: "drop.fill"
        case .fertilizing: "leaf.arrow.circlepath"
        case .repotting: "arrow.up.bin.fill"
        case .pruning: "scissors"
        case .pestTreatment: "ladybug.fill"
        case .rotating: "arrow.triangle.2.circlepath"
        }
    }
}
