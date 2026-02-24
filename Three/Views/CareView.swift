import SwiftUI
import SwiftData

struct CareTask: Identifiable {
    let id: UUID
    let plant: Plant
    let type: CareType
    var isCompleted: Bool
}

struct CareView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.dateAdded, order: .forward) private var allPlants: [Plant]
    @State private var completedTaskIDs: Set<UUID> = []

    private var tasks: [CareTask] {
        var result: [CareTask] = []
        for plant in allPlants {
            if plant.needsWaterToday {
                let taskID = UUID(uuidString: "00000000-0000-0000-0000-\(plant.id.uuidString.suffix(12))") ?? UUID()
                result.append(CareTask(id: taskID, plant: plant, type: .watering, isCompleted: completedTaskIDs.contains(plant.id)))
            }
            if plant.needsFertilizerToday {
                let taskID = UUID(uuidString: "11111111-1111-1111-1111-\(plant.id.uuidString.suffix(12))") ?? UUID()
                result.append(CareTask(id: taskID, plant: plant, type: .fertilizing, isCompleted: completedTaskIDs.contains(plant.id)))
            }
        }
        return result
    }

    private var pendingTasks: [CareTask] {
        tasks.filter { !$0.isCompleted }
    }

    private var completedTasks: [CareTask] {
        tasks.filter { $0.isCompleted }
    }

    private var completedCount: Int {
        completedTasks.count
    }

    private var totalCount: Int {
        tasks.count
    }

    var body: some View {
        VStack(spacing: 0) {
            if totalCount > 0 {
                progressHeader
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }

            if allPlants.isEmpty {
                emptyGardenState
            } else if tasks.isEmpty {
                allDoneState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(pendingTasks) { task in
                            CareTaskRow(task: task) {
                                completeTask(task)
                            }
                            .staggeredAppear(index: pendingTasks.firstIndex(where: { $0.id == task.id }) ?? 0)
                        }

                        if !completedTasks.isEmpty {
                            HStack {
                                Text("Completed")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(Color("EarthBrown").opacity(0.5))
                                Spacer()
                            }
                            .padding(.top, 16)
                            .padding(.horizontal, 4)

                            ForEach(completedTasks) { task in
                                CompletedTaskRow(task: task)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(completedCount) of \(totalCount) tasks done")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("EarthBrown"))
                Spacer()
                if completedCount == totalCount && totalCount > 0 {
                    Text("All Done!")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("LeafGreen"))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("EarthBrown").opacity(0.1))

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color("LeafGreen"))
                        .frame(width: totalCount > 0 ? geo.size.width * CGFloat(completedCount) / CGFloat(totalCount) : 0)
                        .animation(AppAnimation.smooth, value: completedCount)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var emptyGardenState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "leaf")
                .font(.system(size: 64))
                .foregroundStyle(Color("LeafGreen").opacity(0.4))
            Text("No Plants Yet")
                .font(.title2.bold())
                .foregroundStyle(Color("EarthBrown"))
            Text("Add plants to your garden first")
                .font(.subheadline)
                .foregroundStyle(Color("EarthBrown").opacity(0.6))
            Spacer()
        }
    }

    private var allDoneState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("LeafGreen"))
            Text("All Caught Up!")
                .font(.title2.bold())
                .foregroundStyle(Color("EarthBrown"))
            Text("Your plants are happy and healthy")
                .font(.subheadline)
                .foregroundStyle(Color("EarthBrown").opacity(0.6))
            Spacer()
        }
    }

    private func completeTask(_ task: CareTask) {
        withAnimation(AppAnimation.smooth) {
            completedTaskIDs.insert(task.plant.id)
        }

        let event = CareEvent(type: task.type, plant: task.plant)
        modelContext.insert(event)
        task.plant.careEvents.append(event)

        switch task.type {
        case .watering:
            task.plant.lastWatered = Date()
        case .fertilizing:
            task.plant.lastFertilized = Date()
        default:
            break
        }
    }
}

struct CareTaskRow: View {
    let task: CareTask
    let onComplete: () -> Void

    private var speciesEmoji: String {
        switch task.plant.species {
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
        HStack(spacing: 12) {
            Text(speciesEmoji)
                .font(.title2)
                .frame(width: 48, height: 48)
                .background(Color("SoftBeige"))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 3) {
                Text(task.plant.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("EarthBrown"))

                HStack(spacing: 4) {
                    Image(systemName: task.type.iconName)
                        .font(.caption2)
                    Text(task.type.displayName)
                        .font(.caption)
                }
                .foregroundStyle(task.type == .watering ? .blue : .orange)
            }

            Spacer()

            Button {
                onComplete()
            } label: {
                Image(systemName: "checkmark.circle")
                    .font(.title2)
                    .foregroundStyle(Color("LeafGreen"))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color("EarthBrown").opacity(0.06), radius: 6, x: 0, y: 3)
        .swipeActions(edge: .trailing) {
            Button {
                onComplete()
            } label: {
                Label("Done", systemImage: "checkmark")
            }
            .tint(Color("LeafGreen"))
        }
    }
}

struct CompletedTaskRow: View {
    let task: CareTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(Color("LeafGreen").opacity(0.5))

            Text(task.plant.displayName)
                .font(.subheadline)
                .foregroundStyle(Color("EarthBrown").opacity(0.4))
                .strikethrough(true, color: Color("EarthBrown").opacity(0.3))

            Spacer()

            Text(task.type.displayName)
                .font(.caption)
                .foregroundStyle(Color("EarthBrown").opacity(0.3))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("SoftBeige").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NavigationStack {
        CareView()
    }
    .modelContainer(for: [Plant.self, CareEvent.self, GrowthPhoto.self], inMemory: true)
}
