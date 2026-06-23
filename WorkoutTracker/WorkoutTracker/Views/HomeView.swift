import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let navigate: (AppView) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppTheme.spacingXL) {
                header
                weeklyOverview
                todayCard
                allWorkoutsList
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.top, AppTheme.spacingSM)
            .padding(.bottom, 40)
        }
        .refreshable {
            await viewModel.syncWithCloud()
        }
        .background(AppTheme.screenBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Workouts")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                HStack(spacing: 6) {
                    Text("Body recomposition program")
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    if viewModel.isSyncing {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else if viewModel.lastSyncDate != nil {
                        Image(systemName: "icloud.fill")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.success.opacity(0.7))
                    }
                }
            }
            Spacer()
            Button {
                navigate(.schedule)
            } label: {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppTheme.focus)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(AppTheme.focus.opacity(0.1))
                    )
            }
        }
    }

    // MARK: - Weekly Overview

    private var weeklyOverview: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("THIS WEEK")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textTertiary)
                .tracking(0.8)

            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { index in
                    dayCell(index: index)
                }
            }
        }
        .cardStyle()
    }

    private func dayCell(index: Int) -> some View {
        let done = viewModel.isDayDone(index)
        let isToday = index == viewModel.todayDayIndex
        let workoutDay = viewModel.schedule[index]
        let isRest = workoutDay == .rest
        let color = done ? AppTheme.success : isToday ? AppTheme.focus : AppTheme.textTertiary

        return VStack(spacing: 6) {
            Text(WorkoutViewModel.days[index])
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(color)

            ZStack {
                Circle()
                    .fill(done ? AppTheme.success.opacity(0.15) : isToday ? AppTheme.focus.opacity(0.12) : Color.clear)
                    .frame(width: 32, height: 32)

                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.success)
                } else if isRest {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                } else {
                    Text(abbreviation(for: workoutDay))
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(isToday ? AppTheme.focus : AppTheme.textTertiary)
                }
            }

            if isToday {
                Circle()
                    .fill(AppTheme.focus)
                    .frame(width: 4, height: 4)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isRest {
                navigate(.workout(workoutDay.rawValue))
            }
        }
    }

    // MARK: - Today's Card

    private var todayCard: some View {
        Group {
            if viewModel.todayWorkoutDay != .rest {
                todayWorkoutCard
            } else {
                restDayCard
            }
        }
    }

    private var todayWorkoutCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY'S WORKOUT")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textOnAccentSecondary)
                        .tracking(0.8)

                    Text(viewModel.todayWorkoutDay.rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.textOnAccent)
                }
                Spacer()
                Image(systemName: WorkoutIcon.icon(for: viewModel.todayWorkoutDay))
                    .font(.system(size: 36, weight: .light))
                    .foregroundColor(AppTheme.textOnAccent.opacity(0.6))
            }

            Button {
                navigate(.workout(viewModel.todayWorkoutDay.rawValue))
            } label: {
                HStack {
                    Text("Start Workout")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(AppTheme.focus)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                        .fill(.white)
                )
            }
        }
        .padding(AppTheme.spacingXL)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.radiusXL)
                .fill(AppTheme.primaryGradient)
                .shadow(color: AppTheme.focus.opacity(0.3), radius: 16, x: 0, y: 8)
        )
    }

    private var restDayCard: some View {
        HStack(spacing: AppTheme.spacingLG) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.recovery)

            VStack(alignment: .leading, spacing: 4) {
                Text("Rest Day")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("Recovery is part of the program. See you tomorrow!")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .cardStyle()
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - All Workouts

    private var allWorkoutsList: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            Text("ALL WORKOUTS")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textTertiary)
                .tracking(0.8)

            ForEach(WorkoutDatabase.allWorkouts) { workout in
                workoutRow(workout: workout)
            }

            Button {
                navigate(.progress)
            } label: {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 14))
                    Text("View Progress")
                        .font(.subheadline.weight(.medium))
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.top, AppTheme.spacingSM)
        }
    }

    private func workoutRow(workout: Workout) -> some View {
        let day = WorkoutDay(rawValue: workout.name) ?? .rest
        let color = WorkoutIcon.color(for: day)

        return Button {
            navigate(.workout(workout.name))
        } label: {
            HStack(spacing: AppTheme.spacingMD) {
                Image(systemName: WorkoutIcon.icon(for: day))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                            .fill(color.opacity(0.1))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(workout.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("\(workout.blocks.count) blocks \u{00B7} \(workout.accessories.count) supersets")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
        .cardStyle()
    }

    // MARK: - Helpers

    private func abbreviation(for day: WorkoutDay) -> String {
        switch day {
        case .upperBody1: return "UB1"
        case .upperBody2: return "UB2"
        case .lowerBody1: return "LB1"
        case .lowerBody2: return "LB2"
        case .rest: return ""
        }
    }
}
