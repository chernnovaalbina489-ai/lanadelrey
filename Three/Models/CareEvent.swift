import Foundation
import SwiftData

@Model
final class CareEvent {
    var id: UUID
    var date: Date
    var type: CareType
    var notes: String
    var plant: Plant?

    init(
        type: CareType,
        plant: Plant? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.plant = plant
        self.notes = notes
    }
}
