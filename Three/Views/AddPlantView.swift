import SwiftUI
import SwiftData
import PhotosUI

struct AddPlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0
    @State private var name = ""
    @State private var nickname = ""
    @State private var species: PlantSpecies = .tropical
    @State private var location: PlantLocation = .livingRoom
    @State private var healthStatus: HealthStatus = .healthy
    @State private var wateringIntervalDays = 7
    @State private var fertilizingIntervalDays = 30
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    private let totalSteps = 3

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Cream")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    stepIndicator
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    TabView(selection: $currentStep) {
                        stepOneName
                            .tag(0)
                        stepTwoDetails
                            .tag(1)
                        stepThreeCare
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(AppAnimation.smooth, value: currentStep)

                    navigationButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("New Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("EarthBrown"))
                }
            }
        }
    }

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color("LeafGreen") : Color("EarthBrown").opacity(0.15))
                    .frame(height: 4)
                    .animation(AppAnimation.smooth, value: currentStep)
            }
        }
        .padding(.horizontal, 24)
    }

    private var stepOneName: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("What is your plant?")
                    .font(.title2.bold())
                    .foregroundStyle(Color("EarthBrown"))

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if let imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(Color("LeafGreen"))
                            Text("Add Photo")
                                .font(.subheadline)
                                .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        }
                        .frame(width: 160, height: 160)
                        .background(Color("SoftBeige"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    Task {
                        if let data = try? await newValue?.loadTransferable(type: Data.self) {
                            imageData = data
                        }
                    }
                }

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        TextField("e.g., Monstera Deliciosa", text: $name)
                            .padding(14)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nickname")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        TextField("e.g., Monty (optional)", text: $nickname)
                            .padding(14)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 16)
        }
    }

    private var stepTwoDetails: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Tell us more")
                    .font(.title2.bold())
                    .foregroundStyle(Color("EarthBrown"))

                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Species")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                            ForEach(PlantSpecies.allCases) { s in
                                Button {
                                    species = s
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: s.iconName)
                                            .font(.title3)
                                        Text(s.displayName)
                                            .font(.caption2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(species == s ? Color("LeafGreen").opacity(0.15) : Color.white.opacity(0.6))
                                    .foregroundStyle(species == s ? Color("LeafGreen") : Color("EarthBrown"))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(species == s ? Color("LeafGreen") : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 10) {
                            ForEach(PlantLocation.allCases) { loc in
                                Button {
                                    location = loc
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: loc.iconName)
                                            .font(.title3)
                                        Text(loc.displayName)
                                            .font(.caption2)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(location == loc ? Color("EarthBrown").opacity(0.12) : Color.white.opacity(0.6))
                                    .foregroundStyle(location == loc ? Color("EarthBrown") : Color("EarthBrown").opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(location == loc ? Color("EarthBrown") : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Health Status")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))

                        Picker("Health", selection: $healthStatus) {
                            ForEach(HealthStatus.allCases) { status in
                                Text(status.displayName).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 16)
        }
    }

    private var stepThreeCare: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Care Schedule")
                    .font(.title2.bold())
                    .foregroundStyle(Color("EarthBrown"))

                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.blue)
                            Text("Watering Frequency")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("EarthBrown"))
                            Spacer()
                        }

                        HStack {
                            Text("Every")
                                .foregroundStyle(Color("EarthBrown").opacity(0.6))
                            Spacer()
                            Text("\(wateringIntervalDays) days")
                                .font(.headline)
                                .foregroundStyle(Color("LeafGreen"))
                        }

                        Slider(value: Binding(
                            get: { Double(wateringIntervalDays) },
                            set: { wateringIntervalDays = Int($0) }
                        ), in: 1...60, step: 1)
                        .tint(Color("LeafGreen"))
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "leaf.arrow.circlepath")
                                .foregroundStyle(.orange)
                            Text("Fertilizing Frequency")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color("EarthBrown"))
                            Spacer()
                        }

                        HStack {
                            Text("Every")
                                .foregroundStyle(Color("EarthBrown").opacity(0.6))
                            Spacer()
                            Text("\(fertilizingIntervalDays) days")
                                .font(.headline)
                                .foregroundStyle(Color("LeafGreen"))
                        }

                        Slider(value: Binding(
                            get: { Double(fertilizingIntervalDays) },
                            set: { fertilizingIntervalDays = Int($0) }
                        ), in: 7...120, step: 1)
                        .tint(Color("LeafGreen"))
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color("EarthBrown").opacity(0.6))
                        TextEditor(text: $notes)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .scrollContentBackground(.hidden)
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.top, 16)
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation(AppAnimation.smooth) {
                        currentStep -= 1
                    }
                } label: {
                    Text("Back")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("SoftBeige"))
                        .foregroundStyle(Color("EarthBrown"))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .buttonStyle(PressableButtonStyle())
            }

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation(AppAnimation.smooth) {
                        currentStep += 1
                    }
                } else {
                    savePlant()
                }
            } label: {
                Text(currentStep == totalSteps - 1 ? "Plant It!" : "Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(canProceed ? Color("LeafGreen") : Color("EarthBrown").opacity(0.2))
                    .foregroundStyle(canProceed ? .white : Color("EarthBrown").opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .buttonStyle(PressableButtonStyle())
            .disabled(!canProceed)
        }
    }

    private var canProceed: Bool {
        switch currentStep {
        case 0: return !name.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private func savePlant() {
        let plant = Plant(
            name: name.trimmingCharacters(in: .whitespaces),
            nickname: nickname.trimmingCharacters(in: .whitespaces),
            species: species,
            location: location,
            imageData: imageData,
            wateringIntervalDays: wateringIntervalDays,
            fertilizingIntervalDays: fertilizingIntervalDays,
            healthStatus: healthStatus,
            notes: notes.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(plant)
        dismiss()
    }
}

#Preview {
    AddPlantView()
        .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
