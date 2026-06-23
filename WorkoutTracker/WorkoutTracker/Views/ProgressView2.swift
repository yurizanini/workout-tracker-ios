import SwiftUI

struct ProgressView2: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

    private var sortedWeeks: [String] {
        viewModel.logs.keys.sorted().reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 10) {
                Button {
                    navigate(.home)
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.bordered)

                Text("Progress")
                    .font(.headline)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            // Content
            ScrollView {
                if sortedWeeks.isEmpty {
                    VStack(spacing: 12) {
                        Text("No workouts logged yet.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Complete a session to see your history here.")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(sortedWeeks, id: \.self) { weekKey in
                            weekSection(weekKey: weekKey)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func weekSection(weekKey: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Week of \(weekKey)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            ForEach(viewModel.logs[weekKey] ?? [], id: \.id) { entry in
                logEntryCard(entry: entry)
            }
        }
    }

    private func logEntryCard(entry: WorkoutLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.workoutName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(entry.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !entry.exerciseLogs.isEmpty {
                Divider()
                ForEach(entry.exerciseLogs, id: \.exerciseName) { exerciseLog in
                    let weights = exerciseLog.sets
                        .filter { !$0.weight.isEmpty }
                        .map { "\($0.weight)lb" }

                    if !weights.isEmpty {
                        HStack(spacing: 4) {
                            Text("\(exerciseLog.exerciseName):")
                                .font(.caption)
                                .fontWeight(.medium)
                            Text(weights.joined(separator: " \u{00B7} "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
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
