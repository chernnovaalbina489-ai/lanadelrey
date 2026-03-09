import Foundation
import SwiftData

@Model
final class GrowthPhoto {
    var id: UUID
    var date: Date
    var imageData: Data
    var caption: String
    var plant: Plant?

    init(
        imageData: Data,
        caption: String = "",
        plant: Plant? = nil
    ) {
        self.id = UUID()
        self.date = Date()
        self.imageData = imageData
        self.caption = caption
        self.plant = plant
    }
}
