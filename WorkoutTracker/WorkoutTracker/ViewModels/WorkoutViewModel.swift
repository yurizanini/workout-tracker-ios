import Foundation
import SwiftUI

@MainActor
class WorkoutViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var schedule: [WorkoutDay] {
        didSet { saveSchedule() }
    }
    @Published var logs: [String: [WorkoutLogEntry]] {
        didSet { saveLogs() }
    }
    @Published var currentLogInputs: [String: String] = [:]

    // MARK: - Constants

    static let defaultSchedule: [WorkoutDay] = [
        .upperBody1, .lowerBody1, .upperBody2, .lowerBody2, .upperBody1, .rest, .rest
    ]

    static let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - Computed Properties

    var todayDayIndex: Int {
        let d = Calendar.current.component(.weekday, from: Date())
        // Convert from Sunday=1 to Monday=0
        return d == 1 ? 6 : d - 2
    }

    var todayWorkoutDay: WorkoutDay {
        schedule[todayDayIndex]
    }

    var todayWorkout: Workout? {
        WorkoutDatabase.workout(for: todayWorkoutDay)
    }

    var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var weekKey: String {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: monday)
    }

    // MARK: - Init

    init() {
        self.schedule = Self.loadSchedule()
        self.logs = Self.loadLogs()
    }

    // MARK: - Methods

    func isDayDone(_ dayIndex: Int) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = weekday == 1 ? 6 : weekday - 2
        let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        let targetDate = calendar.date(byAdding: .day, value: dayIndex, to: monday)!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let targetKey = formatter.string(from: targetDate)

        return (logs[weekKey] ?? []).contains { $0.date == targetKey }
    }

    func completeWorkout(workoutName: String) {
        var exerciseLogs: [ExerciseLog] = []

        let exerciseNames = Set(currentLogInputs.keys.compactMap { key -> String? in
            let parts = key.split(separator: "__")
            return parts.count >= 3 ? String(parts[0]) : nil
        })

        for exerciseName in exerciseNames {
            var sets: [SetLog] = []
            for setIndex in 0..<10 {
                let weightKey = "\(exerciseName)__\(setIndex)__weight"
                let repsKey = "\(exerciseName)__\(setIndex)__reps"
                let weight = currentLogInputs[weightKey] ?? ""
                let reps = currentLogInputs[repsKey] ?? ""
                if !weight.isEmpty || !reps.isEmpty {
                    sets.append(SetLog(weight: weight, reps: reps))
                }
            }
            if !sets.isEmpty {
                exerciseLogs.append(ExerciseLog(exerciseName: exerciseName, sets: sets))
            }
        }

        let entry = WorkoutLogEntry(workoutName: workoutName, date: todayKey, exerciseLogs: exerciseLogs)

        var weekLogs = logs[weekKey] ?? []
        weekLogs.removeAll { $0.date == todayKey }
        weekLogs.append(entry)
        logs[weekKey] = weekLogs

        currentLogInputs = [:]
    }

    func updateSchedule(dayIndex: Int, workout: WorkoutDay) {
        schedule[dayIndex] = workout
    }

    func resetSchedule() {
        schedule = Self.defaultSchedule
    }

    // MARK: - Persistence

    private static let scheduleKey = "wt_schedule_v2"
    private static let logsKey = "wt_logs_v2"

    private static func loadSchedule() -> [WorkoutDay] {
        guard let data = UserDefaults.standard.data(forKey: scheduleKey),
              let decoded = try? JSONDecoder().decode([WorkoutDay].self, from: data) else {
            return defaultSchedule
        }
        return decoded
    }

    private static func loadLogs() -> [String: [WorkoutLogEntry]] {
        guard let data = UserDefaults.standard.data(forKey: logsKey),
              let decoded = try? JSONDecoder().decode([String: [WorkoutLogEntry]].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveSchedule() {
        if let data = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(data, forKey: Self.scheduleKey)
        }
    }

    private func saveLogs() {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: Self.logsKey)
        }
    }
}
