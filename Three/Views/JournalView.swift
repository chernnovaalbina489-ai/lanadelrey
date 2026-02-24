import SwiftUI
import SwiftData
import PhotosUI

struct JournalEntry: Identifiable {
    let id: UUID
    let date: Date
    let plantName: String
    let type: JournalEntryType
    let notes: String
    let imageData: Data?
}

enum JournalEntryType {
    case care(CareType)
    case photo

    var iconName: String {
        switch self {
        case .care(let type): type.iconName
        case .photo: "camera.fill"
        }
    }

    var displayName: String {
        switch self {
        case .care(let type): type.displayName
        case .photo: "Growth Photo"
        }
    }

    var color: Color {
        switch self {
        case .care(let type):
            switch type {
            case .watering: .blue
            case .fertilizing: Color("LeafGreen")
            case .repotting: Color("EarthBrown")
            case .pruning: .purple
            case .pestTreatment: .red
            case .rotating: .orange
            }
        case .photo: .teal
        }
    }
}

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CareEvent.date, order: .reverse) private var allEvents: [CareEvent]
    @Query(sort: \GrowthPhoto.date, order: .reverse) private var allPhotos: [GrowthPhoto]
    @Query private var allPlants: [Plant]
    @State private var showingAddEntry = false
    @State private var selectedPlantForPhoto: Plant?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoCaption = ""

    private var journalEntries: [JournalEntry] {
        var entries: [JournalEntry] = []

        for event in allEvents {
            entries.append(JournalEntry(
                id: event.id,
                date: event.date,
                plantName: event.plant?.displayName ?? "Unknown",
                type: .care(event.type),
                notes: event.notes,
                imageData: nil
            ))
        }

        for photo in allPhotos {
            entries.append(JournalEntry(
                id: photo.id,
                date: photo.date,
                plantName: photo.plant?.displayName ?? "Unknown",
                type: .photo,
                notes: photo.caption,
                imageData: photo.imageData
            ))
        }

        return entries.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(spacing: 0) {
            if journalEntries.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(journalEntries.enumerated()), id: \.element.id) { index, entry in
                            JournalFeedCard(entry: entry)
                                .staggeredAppear(index: index)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingAddEntry = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(Color("LeafGreen"))
                    .clipShape(Circle())
                    .shadow(color: Color("LeafGreen").opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PressableButtonStyle())
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $showingAddEntry) {
            addPhotoSheet
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book")
                .font(.system(size: 64))
                .foregroundStyle(Color("LeafGreen").opacity(0.4))
            Text("No journal entries yet")
                .font(.title2.bold())
                .foregroundStyle(Color("EarthBrown"))
            Text("Care for your plants to see entries here")
                .font(.subheadline)
                .foregroundStyle(Color("EarthBrown").opacity(0.6))
            Spacer()
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

                if allPlants.isEmpty {
                    Text("Add plants to your garden first")
                        .font(.subheadline)
                        .foregroundStyle(Color("EarthBrown").opacity(0.6))
                } else {
                    Picker("Plant", selection: $selectedPlantForPhoto) {
                        Text("Select a plant").tag(nil as Plant?)
                        ForEach(allPlants) { plant in
                            Text(plant.displayName).tag(plant as Plant?)
                        }
                    }
                    .pickerStyle(.menu)

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("SoftBeige"))
                            .foregroundStyle(Color("EarthBrown"))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .padding(.horizontal)
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let plant = selectedPlantForPhoto {
                                saveGrowthPhoto(data: data, plant: plant)
                            }
                        }
                    }

                    TextField("Caption (optional)", text: $photoCaption)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 30)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { showingAddEntry = false }
                        .foregroundStyle(Color("EarthBrown"))
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func saveGrowthPhoto(data: Data, plant: Plant) {
        let photo = GrowthPhoto(
            imageData: data,
            caption: photoCaption.trimmingCharacters(in: .whitespaces),
            plant: plant
        )
        modelContext.insert(photo)
        plant.growthPhotos.append(photo)
        photoCaption = ""
        showingAddEntry = false
    }
}

struct JournalFeedCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(entry.type.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: entry.type.iconName)
                        .font(.body)
                        .foregroundStyle(entry.type.color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.plantName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("EarthBrown"))
                    Text(entry.type.displayName)
                        .font(.caption)
                        .foregroundStyle(Color("EarthBrown").opacity(0.5))
                }

                Spacer()

                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(Color("EarthBrown").opacity(0.4))
            }
            .padding(14)

            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()
            } else {
                ZStack {
                    Rectangle()
                        .fill(entry.type.color.opacity(0.08))
                        .frame(height: 100)

                    Image(systemName: entry.type.iconName)
                        .font(.system(size: 36))
                        .foregroundStyle(entry.type.color.opacity(0.25))
                }
            }

            if !entry.notes.isEmpty {
                Text(entry.notes)
                    .font(.subheadline)
                    .foregroundStyle(Color("EarthBrown").opacity(0.7))
                    .padding(14)
            }
        }
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color("EarthBrown").opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        JournalView()
    }
    .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
