import SwiftUI

struct WorkoutSessionView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let workoutName: String
    let navigate: (AppView) -> Void

    @State private var activeSectionIndex: Int = 0

    private var workout: Workout? {
        WorkoutDatabase.allWorkouts.first { $0.name == workoutName }
    }

    private var sections: [(label: String, type: SectionType)] {
        guard let workout = workout else { return [] }
        var result: [(String, SectionType)] = [("Warm Up", .warmup)]
        for (i, block) in workout.blocks.enumerated() {
            result.append((block.name, .block(i)))
        }
        for (i, acc) in workout.accessories.enumerated() {
            result.append((acc.name, .accessory(i)))
        }
        return result
    }

    var body: some View {
        if let workout = workout {
            VStack(spacing: 0) {
                // Header
                sessionHeader

                // Section tabs
                sectionTabs

                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionTitle
                        sectionContent(workout: workout)
                    }
                    .padding()
                }

                // Navigation buttons
                bottomNavigation
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Header

    private var sessionHeader: some View {
        HStack {
            Button {
                navigate(.home)
            } label: {
                Image(systemName: "xmark")
                    .font(.body)
            }
            .buttonStyle(.bordered)

            Text(workoutName)
                .font(.headline)
                .lineLimit(1)

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                    Button(section.label) {
                        withAnimation { activeSectionIndex = index }
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(activeSectionIndex == index ? Color.blue.opacity(0.15) : Color(.systemGray6))
                    )
                    .foregroundColor(activeSectionIndex == index ? .blue : .secondary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Section Title

    private var sectionTitle: some View {
        Text(sections[safe: activeSectionIndex]?.label ?? "")
            .font(.title3)
            .fontWeight(.medium)
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(workout: Workout) -> some View {
        if let section = sections[safe: activeSectionIndex] {
            switch section.type {
            case .warmup:
                Text("1 round — no weights needed.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(workout.warmup) { exercise in
                    WarmupExerciseCard(exercise: exercise)
                }

            case .block(let index):
                let block = workout.blocks[index]
                Text("\(block.sets) sets \u{00B7} \(block.superset ? "Superset — 60s rest between rounds" : "Rest 90s between sets")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(block.exercises) { exercise in
                    LoggingExerciseCard(exercise: exercise, reps: block.reps)
                }

            case .accessory(let index):
                let acc = workout.accessories[index]
                Text("\(acc.sets) sets \u{00B7} Superset — 45s rest between rounds")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(acc.exercises) { exercise in
                    LoggingExerciseCard(exercise: exercise, reps: acc.reps)
                }
            }
        }
    }

    // MARK: - Bottom Navigation

    private var bottomNavigation: some View {
        HStack(spacing: 12) {
            if activeSectionIndex > 0 {
                Button {
                    withAnimation { activeSectionIndex -= 1 }
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            if activeSectionIndex < sections.count - 1 {
                Button {
                    withAnimation { activeSectionIndex += 1 }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    viewModel.completeWorkout(workoutName: workoutName)
                    navigate(.done(workoutName))
                } label: {
                    Label("Complete", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Section Type

enum SectionType {
    case warmup
    case block(Int)
    case accessory(Int)
}

// MARK: - Warmup Exercise Card

struct WarmupExerciseCard: View {
    let exercise: Exercise

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                if let reps = exercise.reps {
                    Text(reps)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            if let url = exercise.youtubeSearchURL {
                Link(destination: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 8))
                        Text("YouTube")
                            .font(.caption2)
                    }
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Logging Exercise Card

struct LoggingExerciseCard: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let exercise: Exercise
    let reps: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(exercise.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                if let url = exercise.youtubeSearchURL {
                    Link(destination: url) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                            Text("YouTube")
                                .font(.caption2)
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
                        )
                    }
                }
            }

            ForEach(0..<reps.count, id: \.self) { setIndex in
                HStack(spacing: 8) {
                    Text("S\(setIndex + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 24)

                    TextField("lb", text: binding(for: "\(exercise.name)__\(setIndex)__weight"))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)

                    TextField("\(reps[setIndex]) reps", text: binding(for: "\(exercise.name)__\(setIndex)__reps"))
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .font(.caption)
                }
            }

            Text("Target: \(reps.map { String($0) }.joined(separator: ", ")) reps")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
    }

    private func binding(for key: String) -> Binding<String> {
        Binding(
            get: { viewModel.currentLogInputs[key] ?? "" },
            set: { viewModel.currentLogInputs[key] = $0 }
        )
    }
}

// MARK: - Array Safe Access

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
