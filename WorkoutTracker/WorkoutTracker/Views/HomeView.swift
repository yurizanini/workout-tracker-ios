import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                header

                // Weekly overview
                weeklyOverview

                // Today's workout card
                todayCard

                // All workouts list
                allWorkoutsList
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("My Workouts")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Body recomposition program")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Edit Schedule") {
                navigate(.schedule)
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
    }

    // MARK: - Weekly Overview

    private var weeklyOverview: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                let done = viewModel.isDayDone(index)
                let isToday = index == viewModel.todayDayIndex
                let workoutDay = viewModel.schedule[index]
                let isRest = workoutDay == .rest

                VStack(spacing: 4) {
                    Text(WorkoutViewModel.days[index])
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(done ? .green : isToday ? .blue : .secondary)

                    Text(done ? "\u{2713}" : isRest ? "—" : abbreviation(for: workoutDay))
                        .font(.system(size: 9))
                        .foregroundColor(done ? .green : isToday ? .blue : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(done ? Color.green.opacity(0.1) : isToday ? Color.blue.opacity(0.1) : Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(done ? Color.green.opacity(0.3) : isToday ? Color.blue.opacity(0.3) : Color(.separator).opacity(0.3), lineWidth: 0.5)
                )
                .onTapGesture {
                    if !isRest {
                        navigate(.workout(workoutDay.rawValue))
                    }
                }
            }
        }
    }

    // MARK: - Today's Card

    private var todayCard: some View {
        Group {
            if viewModel.todayWorkoutDay != .rest {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Today's workout")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(viewModel.todayWorkoutDay.rawValue)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Button {
                        navigate(.workout(viewModel.todayWorkoutDay.rawValue))
                    } label: {
                        Text("Start workout \u{2192}")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.08))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.2), lineWidth: 0.5)
                )
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rest day")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Recovery is part of the program. See you tomorrow!")
                        .font(.subheadline)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
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
    }

    // MARK: - All Workouts

    private var allWorkoutsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All workouts")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)

            ForEach(WorkoutDatabase.allWorkouts) { workout in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(workout.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(workout.blocks.count) blocks \u{00B7} \(workout.accessories.count) accessory supersets")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button("Start") {
                        navigate(.workout(workout.name))
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
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

            Button {
                navigate(.progress)
            } label: {
                Text("View progress \u{2192}")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
    }

    // MARK: - Helpers

    private func abbreviation(for day: WorkoutDay) -> String {
        switch day {
        case .upperBody1: return "UB1"
        case .upperBody2: return "UB2"
        case .lowerBody1: return "LB1"
        case .lowerBody2: return "LB2"
        case .rest: return "—"
        }
    }
}
