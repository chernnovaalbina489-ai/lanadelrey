import SwiftUI
import SwiftData
import PhotosUI

struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let plant: Plant
    @State private var showingAddPhoto = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoCaption = ""
    @State private var waterBounce = false
    @State private var fertilizeBounce = false

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
        ScrollView {
            VStack(spacing: 20) {
                headerImage
                plantInfoSection
                waterDropsSection
                careScheduleSection
                careHistorySection
                growthPhotoGallery
            }
            .padding(.bottom, 30)
        }
        .background(Color("Cream"))
        .navigationTitle(plant.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddPhoto) {
            addPhotoSheet
        }
    }

    private var headerImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("SoftBeige"))
                .frame(height: 300)

            if let imageData = plant.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 12) {
                    Text(speciesEmoji)
                        .font(.system(size: 80))
                    Text(plant.species.displayName)
                        .font(.subheadline)
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var plantInfoSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plant.name)
                        .font(.title2.bold())
                        .foregroundStyle(Color("EarthBrown"))
                    if !plant.nickname.isEmpty {
                        Text("\"\(plant.nickname)\"")
                            .font(.subheadline)
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                    }
                }
                Spacer()
                Label(plant.species.displayName, systemImage: plant.species.iconName)
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color("LeafGreen").opacity(0.12))
                    .foregroundStyle(Color("LeafGreen"))
                    .clipShape(Capsule())
            }

            HStack(spacing: 16) {
                Label(plant.location.displayName, systemImage: plant.location.iconName)
                    .font(.caption)
                    .foregroundStyle(Color("EarthBrown").opacity(0.6))

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(plant.healthStatus.color)
                        .frame(width: 10, height: 10)
                    Text(plant.healthStatus.displayName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(plant.healthStatus.color)
                }
            }

            if !plant.notes.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                    Text(plant.notes)
                        .foregroundStyle(Color("EarthBrown").opacity(0.7))
                        .font(.subheadline)
                    Spacer()
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                Text("Added: \(plant.dateAdded.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }

    private var waterDropsSection: some View {
        HStack(spacing: 16) {
            DetailWaterDrops(plant: plant, label: "Water")
            DetailWaterDrops(plant: plant, label: "Fertilizer", isFertilizer: true)
        }
        .padding(.horizontal, 16)
    }

    private var careScheduleSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Watering")
                        .font(.headline)
                        .foregroundStyle(Color("EarthBrown"))
                    if let daysUntil = plant.daysUntilNextWatering {
                        Text(daysUntil > 0 ? "Next in \(daysUntil) days" : daysUntil == 0 ? "Due today" : "Overdue by \(abs(daysUntil)) days")
                            .font(.subheadline)
                            .foregroundStyle(daysUntil <= 0 ? .red : Color("LeafGreen"))
                    } else {
                        Text("Never watered")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Fertilizing")
                        .font(.headline)
                        .foregroundStyle(Color("EarthBrown"))
                    if let daysUntil = plant.daysUntilNextFertilizing {
                        Text(daysUntil > 0 ? "Next in \(daysUntil) days" : daysUntil == 0 ? "Due today" : "Overdue by \(abs(daysUntil)) days")
                            .font(.subheadline)
                            .foregroundStyle(daysUntil <= 0 ? .orange : Color("LeafGreen"))
                    } else {
                        Text("Never fertilized")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    waterPlant()
                } label: {
                    Label("Water Now", systemImage: "drop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PressableButtonStyle())
                .bounce(trigger: waterBounce)

                Button {
                    fertilizePlant()
                } label: {
                    Label("Fertilize", systemImage: "leaf.arrow.circlepath")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("LeafGreen"))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PressableButtonStyle())
                .bounce(trigger: fertilizeBounce)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 16)
    }

    private var careHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Care History")
                .font(.headline)
                .foregroundStyle(Color("EarthBrown"))
                .padding(.horizontal, 20)

            let sorted = plant.careEvents.sorted { $0.date > $1.date }
            if sorted.isEmpty {
                Text("No care events yet")
                    .font(.subheadline)
                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                    .padding(.horizontal, 20)
            } else {
                ForEach(Array(sorted.prefix(10).enumerated()), id: \.element.id) { index, event in
                    HStack {
                        Image(systemName: event.type.iconName)
                            .foregroundStyle(Color("LeafGreen"))
                        VStack(alignment: .leading) {
                            Text(event.type.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("EarthBrown"))
                            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(Color("EarthBrown").opacity(0.5))
                        }
                        Spacer()
                        if !event.notes.isEmpty {
                            Text(event.notes)
                                .font(.caption)
                                .foregroundStyle(Color("EarthBrown").opacity(0.5))
                                .lineLimit(1)
                        }
                    }
                    .padding(.horizontal, 20)
                    .staggeredAppear(index: index)
                }
            }
        }
    }

    private var growthPhotoGallery: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Growth Photos")
                    .font(.headline)
                    .foregroundStyle(Color("EarthBrown"))

                Spacer()

                Button {
                    showingAddPhoto = true
                } label: {
                    Label("Add", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color("LeafGreen"))
                }
            }
            .padding(.horizontal, 20)

            let sortedPhotos = plant.growthPhotos.sorted { $0.date > $1.date }
            if sortedPhotos.isEmpty {
                Text("No growth photos yet")
                    .font(.subheadline)
                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(sortedPhotos.enumerated()), id: \.element.id) { index, photo in
                            VStack(spacing: 6) {
                                if let uiImage = UIImage(data: photo.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                Text(photo.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption2)
                                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                                if !photo.caption.isEmpty {
                                    Text(photo.caption)
                                        .font(.caption2)
                                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                                        .lineLimit(1)
                                }
                            }
                            .staggeredAppear(index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    private var addPhotoSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color("LeafGreen"))

                Text("Add Growth Photo")
                    .font(.title2.bold())
                    .foregroundStyle(Color("EarthBrown"))

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("SoftBeige"))
                        .foregroundStyle(Color("EarthBrown"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            saveGrowthPhoto(data: data)
                        }
                    }
                }

                TextField("Caption (optional)", text: $photoCaption)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 30)
            .background(Color("Cream"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { showingAddPhoto = false }
                        .foregroundStyle(Color("EarthBrown"))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func waterPlant() {
        let event = CareEvent(type: .watering, plant: plant, notes: "")
        modelContext.insert(event)
        plant.careEvents.append(event)
        plant.lastWatered = Date()
        waterBounce.toggle()
    }

    private func fertilizePlant() {
        let event = CareEvent(type: .fertilizing, plant: plant, notes: "")
        modelContext.insert(event)
        plant.careEvents.append(event)
        plant.lastFertilized = Date()
        fertilizeBounce.toggle()
    }

    private func saveGrowthPhoto(data: Data) {
        let photo = GrowthPhoto(
            imageData: data,
            caption: photoCaption.trimmingCharacters(in: .whitespaces),
            plant: plant
        )
        modelContext.insert(photo)
        plant.growthPhotos.append(photo)
        photoCaption = ""
        showingAddPhoto = false
    }
}

struct DetailWaterDrops: View {
    let plant: Plant
    var label: String = "Water"
    var isFertilizer: Bool = false

    private var filledDrops: Int {
        if isFertilizer {
            guard let daysUntil = plant.daysUntilNextFertilizing else { return 0 }
            let interval = max(plant.fertilizingIntervalDays, 1)
            let ratio = Double(daysUntil) / Double(interval)
            if ratio > 0.66 { return 3 }
            if ratio > 0.33 { return 2 }
            if ratio > 0 { return 1 }
            return 0
        } else {
            guard let daysUntil = plant.daysUntilNextWatering else { return 0 }
            let interval = max(plant.wateringIntervalDays, 1)
            let ratio = Double(daysUntil) / Double(interval)
            if ratio > 0.66 { return 3 }
            if ratio > 0.33 { return 2 }
            if ratio > 0 { return 1 }
            return 0
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color("EarthBrown").opacity(0.6))

            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { index in
                    Image(systemName: index < filledDrops ? "drop.fill" : "drop")
                        .font(.title2)
                        .foregroundStyle(index < filledDrops ? (isFertilizer ? Color.orange : Color.blue) : Color("EarthBrown").opacity(0.2))
                }
            }

            Text(statusText)
                .font(.caption2)
                .foregroundStyle(Color("EarthBrown").opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var statusText: String {
        if isFertilizer {
            guard let daysUntil = plant.daysUntilNextFertilizing else { return "Not set" }
            if daysUntil > 0 { return "In \(daysUntil) days" }
            if daysUntil == 0 { return "Today" }
            return "Overdue"
        } else {
            guard let daysUntil = plant.daysUntilNextWatering else { return "Not set" }
            if daysUntil > 0 { return "In \(daysUntil) days" }
            if daysUntil == 0 { return "Today" }
            return "Overdue"
        }
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(
            name: "Monstera Deliciosa",
            nickname: "Monty",
            species: .tropical,
            location: .livingRoom
        ))
    }
    .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
