import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.spacingXL) {
                header
                scheduleList
                resetButton
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
                Text("Edit Schedule")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Assign a workout to each day")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
    }

    // MARK: - Schedule List

    private var scheduleList: some View {
        VStack(spacing: AppTheme.spacingSM) {
            ForEach(0..<7, id: \.self) { index in
                dayRow(index: index)
            }
        }
    }

    private func dayRow(index: Int) -> some View {
        let isToday = index == viewModel.todayDayIndex
        let workoutDay = viewModel.schedule[index]
        let color = WorkoutIcon.color(for: workoutDay)

        return HStack(spacing: AppTheme.spacingMD) {
            // Day label
            VStack(spacing: 2) {
                Text(WorkoutViewModel.days[index])
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(isToday ? AppTheme.focus : AppTheme.textPrimary)
            }
            .frame(width: 36)

            // Icon
            Image(systemName: WorkoutIcon.icon(for: workoutDay))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                        .fill(color.opacity(0.1))
                )

            // Picker
            Menu {
                ForEach(WorkoutDay.allCases, id: \.self) { day in
                    Button {
                        viewModel.updateSchedule(dayIndex: index, workoutDay: day)
                    } label: {
                        Label(day.rawValue, systemImage: WorkoutIcon.icon(for: day))
                    }
                }
            } label: {
                HStack {
                    Text(workoutDay.rawValue)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            if isToday {
                Text("TODAY")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.focus)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        Capsule()
                            .fill(AppTheme.focus.opacity(0.1))
                    )
            }
        }
        .cardStyle()
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button {
            viewModel.resetSchedule()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 12, weight: .medium))
                Text("Reset to Default")
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}
