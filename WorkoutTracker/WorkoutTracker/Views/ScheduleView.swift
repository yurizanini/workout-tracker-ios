import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

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

                Text("Edit Schedule")
                    .font(.headline)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            Text("Assign a workout to each day of the week.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Schedule rows
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<7, id: \.self) { index in
                        scheduleRow(index: index)
                    }
                }
                .padding(.horizontal)

                Button {
                    viewModel.resetSchedule()
                } label: {
                    Text("Reset to default")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.secondary)
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    private func scheduleRow(index: Int) -> some View {
        HStack(spacing: 12) {
            Text(WorkoutViewModel.days[index])
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 36, alignment: .leading)

            Picker("", selection: Binding(
                get: { viewModel.schedule[index] },
                set: { viewModel.updateSchedule(dayIndex: index, workout: $0) }
            )) {
                ForEach(WorkoutDay.allCases, id: \.self) { day in
                    Text(day.rawValue).tag(day)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity, alignment: .leading)

            if index == viewModel.todayDayIndex {
                Text("today")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
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
