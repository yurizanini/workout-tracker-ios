import SwiftUI

struct ProgressView2: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.spacingXL) {
                header
                progressContent
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.top, AppTheme.spacingSM)
            .padding(.bottom, 40)
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: AppTheme.spacingMD) {
            Button {
                navigate(.home)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppTheme.elevatedBackground)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Progress")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Your workout history")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var progressContent: some View {
        let weeks = viewModel.sortedWeekKeys

        if weeks.isEmpty {
            emptyState
        } else {
            ForEach(weeks, id: \.self) { weekKey in
                weekSection(weekKey: weekKey)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(AppTheme.textTertiary)
            Text("No workouts logged yet")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
            Text("Complete a session to see your history here.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func weekSection(weekKey: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.focus)
                Text("Week of \(weekKey)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                let count = viewModel.logs[weekKey]?.count ?? 0
                Text("\(count) workout\(count == 1 ? "" : "s")")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.focus)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppTheme.focus.opacity(0.1))
                    )
            }

            ForEach(Array((viewModel.logs[weekKey] ?? []).enumerated()), id: \.offset) { _, entry in
                logEntryCard(entry: entry)
            }
        }
    }

    private func logEntryCard(entry: WorkoutLogEntry) -> some View {
        let day = WorkoutDay(rawValue: entry.workoutName) ?? .rest
        let color = WorkoutIcon.color(for: day)

        return VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: WorkoutIcon.icon(for: day))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                            .fill(color.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.workoutName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text(entry.date)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.success)
            }

            // Weight summary
            let exerciseWeights = extractWeightsFromLogs(entry.exerciseLogs)
            if !exerciseWeights.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(exerciseWeights, id: \.name) { item in
                        HStack(spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Text(item.weights)
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private struct ExerciseWeight: Hashable {
        let name: String
        let weights: String
    }

    private func extractWeightsFromLogs(_ exerciseLogs: [ExerciseLog]) -> [ExerciseWeight] {
        var result: [ExerciseWeight] = []
        for log in exerciseLogs {
            let weights = log.sets.filter { !$0.weight.isEmpty }.map { "\($0.weight)lb" }
            if !weights.isEmpty {
                result.append(ExerciseWeight(name: log.exerciseName, weights: weights.joined(separator: " \u{00B7} ")))
            }
        }
        return result
    }
}
