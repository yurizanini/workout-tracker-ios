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
        for (i, _) in workout.accessories.enumerated() {
            result.append((workout.accessories[i].name, .accessory(i)))
        }
        return result
    }

    private var progress: Double {
        guard !sections.isEmpty else { return 0 }
        return Double(activeSectionIndex + 1) / Double(sections.count)
    }

    var body: some View {
        if let workout = workout {
            VStack(spacing: 0) {
                sessionHeader
                progressBar
                sectionTabs

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        sectionHeader
                        sectionContent(workout: workout)
                    }
                    .padding(AppTheme.spacingLG)
                    .padding(.bottom, 20)
                }

                bottomNavigation
            }
            .background(AppTheme.screenBackground.ignoresSafeArea())
        }
    }

    // MARK: - Header

    private var sessionHeader: some View {
        HStack {
            Button {
                navigate(.home)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(AppTheme.elevatedBackground)
                    )
            }

            Spacer()

            VStack(spacing: 2) {
                Text(workoutName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)
                Text("\(activeSectionIndex + 1) of \(sections.count)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)
            }

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, AppTheme.spacingLG)
        .padding(.vertical, AppTheme.spacingMD)
        .background(AppTheme.cardBackground)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(AppTheme.elevatedBackground)
                Rectangle()
                    .fill(AppTheme.primaryGradient)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Section Tabs

    private var sectionTabs: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                activeSectionIndex = index
                            }
                        } label: {
                            HStack(spacing: 4) {
                                if index < activeSectionIndex {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 8, weight: .bold))
                                }
                                Text(section.label)
                                    .font(.system(size: 12, weight: activeSectionIndex == index ? .semibold : .medium))
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(activeSectionIndex == index ? AppTheme.focus.opacity(0.12) :
                                            index < activeSectionIndex ? AppTheme.success.opacity(0.08) :
                                            AppTheme.elevatedBackground)
                            )
                            .foregroundColor(activeSectionIndex == index ? AppTheme.focus :
                                                index < activeSectionIndex ? AppTheme.success :
                                                AppTheme.textTertiary)
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
                .padding(.vertical, AppTheme.spacingMD)
            }
            .background(AppTheme.cardBackground)
            .onChange(of: activeSectionIndex) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(sections[safe: activeSectionIndex]?.label ?? "")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textPrimary)
        }
    }

    // MARK: - Section Content

    @ViewBuilder
    private func sectionContent(workout: Workout) -> some View {
        if let section = sections[safe: activeSectionIndex] {
            switch section.type {
            case .warmup:
                sectionBadge(icon: "flame.fill", text: "1 round — no weights needed", color: AppTheme.energy)
                ForEach(workout.warmup) { exercise in
                    WarmupExerciseCard(exercise: exercise)
                }

            case .block(let index):
                let block = workout.blocks[index]
                sectionBadge(
                    icon: block.superset ? "arrow.triangle.2.circlepath" : "timer",
                    text: "\(block.sets) sets \u{00B7} \(block.superset ? "Superset — 60s rest" : "Rest 90s between sets")",
                    color: AppTheme.focus
                )
                ForEach(block.exercises) { exercise in
                    LoggingExerciseCard(exercise: exercise, reps: block.reps)
                }

            case .accessory(let index):
                let acc = workout.accessories[index]
                sectionBadge(
                    icon: "arrow.triangle.2.circlepath",
                    text: "\(acc.sets) sets \u{00B7} Superset — 45s rest",
                    color: AppTheme.recovery
                )
                ForEach(acc.exercises) { exercise in
                    LoggingExerciseCard(exercise: exercise, reps: acc.reps)
                }
            }
        }
    }

    private func sectionBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - Bottom Navigation

    private var bottomNavigation: some View {
        HStack(spacing: 12) {
            if activeSectionIndex > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { activeSectionIndex -= 1 }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Back")
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }

            if activeSectionIndex < sections.count - 1 {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { activeSectionIndex += 1 }
                } label: {
                    HStack(spacing: 4) {
                        Text("Next")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
                .buttonStyle(GradientButtonStyle())
            } else {
                Button {
                    viewModel.completeWorkout(workoutName: workoutName)
                    navigate(.done(workoutName))
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("Complete Workout")
                    }
                }
                .buttonStyle(GradientButtonStyle(gradient: AppTheme.successGradient))
            }
        }
        .padding(AppTheme.spacingLG)
        .background(
            AppTheme.cardBackground
                .shadow(color: AppTheme.shadowMedium, radius: 8, x: 0, y: -4)
        )
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
        HStack(spacing: AppTheme.spacingMD) {
            Circle()
                .fill(AppTheme.energy.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "figure.flexibility")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.energy)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                if let reps = exercise.reps {
                    Text(reps)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }

            Spacer()

            if let url = exercise.youtubeSearchURL {
                Link(destination: url) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.red.opacity(0.7))
                }
            }
        }
        .cardStyle()
    }
}

// MARK: - Logging Exercise Card

struct LoggingExerciseCard: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let exercise: Exercise
    let reps: [Int]

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Target: \(reps.map { String($0) }.joined(separator: ", ")) reps")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.textTertiary)
                }
                Spacer()
                if let url = exercise.youtubeSearchURL {
                    Link(destination: url) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
            }

            // Set inputs
            VStack(spacing: 8) {
                // Column headers
                HStack(spacing: 8) {
                    Text("SET")
                        .frame(width: 32)
                    Text("WEIGHT")
                        .frame(maxWidth: .infinity)
                    Text("REPS")
                        .frame(maxWidth: .infinity)
                }
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.textTertiary)

                ForEach(0..<reps.count, id: \.self) { setIndex in
                    HStack(spacing: 8) {
                        Text("\(setIndex + 1)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.focus)
                            .frame(width: 32, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                                    .fill(AppTheme.focus.opacity(0.08))
                            )

                        HStack(spacing: 4) {
                            TextField("0", text: binding(for: "\(exercise.name)__\(setIndex)__weight"))
                                .keyboardType(.decimalPad)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            Text("lb")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                                .fill(AppTheme.elevatedBackground)
                        )

                        HStack(spacing: 4) {
                            TextField("\(reps[setIndex])", text: binding(for: "\(exercise.name)__\(setIndex)__reps"))
                                .keyboardType(.numberPad)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.textPrimary)
                                .multilineTextAlignment(.center)
                            Text("reps")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .padding(.horizontal, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppTheme.radiusSM)
                                .fill(AppTheme.elevatedBackground)
                        )
                    }
                }
            }
        }
        .cardStyle()
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
