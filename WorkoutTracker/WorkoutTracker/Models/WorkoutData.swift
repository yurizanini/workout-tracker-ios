import Foundation

// MARK: - Exercise Model

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    var reps: String?

    init(name: String, reps: String? = nil) {
        self.id = UUID()
        self.name = name
        self.reps = reps
    }

    var youtubeSearchURL: URL? {
        let query = "\(name) exercise tutorial"
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://www.youtube.com/results?search_query=\(encoded)")
    }
}

// MARK: - Block Model

struct WorkoutBlock: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let sets: Int
    let reps: [Int]
    let superset: Bool
    let exercises: [Exercise]

    init(name: String, sets: Int, reps: [Int], superset: Bool = false, exercises: [Exercise]) {
        self.id = UUID()
        self.name = name
        self.sets = sets
        self.reps = reps
        self.superset = superset
        self.exercises = exercises
    }
}

// MARK: - Workout Model

struct Workout: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let warmup: [Exercise]
    let blocks: [WorkoutBlock]
    let accessories: [WorkoutBlock]

    init(name: String, warmup: [Exercise], blocks: [WorkoutBlock], accessories: [WorkoutBlock]) {
        self.id = UUID()
        self.name = name
        self.warmup = warmup
        self.blocks = blocks
        self.accessories = accessories
    }
}

// MARK: - Log Entry

struct SetLog: Codable, Hashable {
    var weight: String
    var reps: String
}

struct ExerciseLog: Codable, Hashable {
    let exerciseName: String
    var sets: [SetLog]
}

struct WorkoutLogEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let workoutName: String
    let date: String
    var exerciseLogs: [ExerciseLog]

    init(workoutName: String, date: String, exerciseLogs: [ExerciseLog] = []) {
        self.id = UUID()
        self.workoutName = workoutName
        self.date = date
        self.exerciseLogs = exerciseLogs
    }
}

// MARK: - Schedule

enum WorkoutDay: String, Codable, CaseIterable {
    case upperBody1 = "Upper Body 1"
    case upperBody2 = "Upper Body 2"
    case lowerBody1 = "Lower Body 1"
    case lowerBody2 = "Lower Body 2"
    case rest = "Rest"
}

// MARK: - Static Workout Data

struct WorkoutDatabase {
    static let allWorkouts: [Workout] = [
        upperBody1, upperBody2, lowerBody1, lowerBody2
    ]

    static let upperBody1 = Workout(
        name: "Upper Body 1",
        warmup: [
            Exercise(name: "Cat Cow", reps: "8 reps"),
            Exercise(name: "Knee Circles", reps: "8 reps"),
            Exercise(name: "Push Up to Downdog", reps: "10 reps"),
            Exercise(name: "Downward Dog to Runners Lunge Stretch", reps: "8 reps"),
        ],
        blocks: [
            WorkoutBlock(name: "Block 1", sets: 4, reps: [8, 8, 6, 6], exercises: [
                Exercise(name: "Dumbbell Push Press"),
                Exercise(name: "Band Tall Kneeling Lat Pulldown"),
            ]),
            WorkoutBlock(name: "Block 2", sets: 3, reps: [12, 12, 12], superset: true, exercises: [
                Exercise(name: "DB Single Arm Bench Press"),
                Exercise(name: "Alternating DB Bent Over Row"),
            ]),
        ],
        accessories: [
            WorkoutBlock(name: "Superset A", sets: 3, reps: [12, 12, 12], exercises: [
                Exercise(name: "DB Standing Overhead Tricep Extension"),
                Exercise(name: "Alternating DB Bicep Curl"),
            ]),
            WorkoutBlock(name: "Superset B", sets: 3, reps: [10, 10, 10], exercises: [
                Exercise(name: "Push Up to Side Plank"),
                Exercise(name: "Dumbbell Front Raise"),
            ]),
        ]
    )

    static let upperBody2 = Workout(
        name: "Upper Body 2",
        warmup: [
            Exercise(name: "Band Dislocates", reps: "10 reps"),
            Exercise(name: "Quadruped Thoracic Rotations", reps: "8 reps"),
            Exercise(name: "Scapular Push Up", reps: "10 reps"),
            Exercise(name: "Wall Angel", reps: "10 reps"),
        ],
        blocks: [
            WorkoutBlock(name: "Block 1", sets: 4, reps: [8, 8, 6, 6], exercises: [
                Exercise(name: "DB Incline Close Grip Bench Press"),
                Exercise(name: "DB Incline Row"),
            ]),
            WorkoutBlock(name: "Block 2", sets: 3, reps: [12, 12, 12], superset: true, exercises: [
                Exercise(name: "Seated Arnold DB Press"),
                Exercise(name: "DB Bent Over Reverse Fly"),
            ]),
        ],
        accessories: [
            WorkoutBlock(name: "Superset A", sets: 3, reps: [12, 12, 12], exercises: [
                Exercise(name: "DB Seated Bicep Curl"),
                Exercise(name: "Bench Dips"),
            ]),
            WorkoutBlock(name: "Superset B", sets: 3, reps: [10, 10, 10], exercises: [
                Exercise(name: "Tuck Crunch"),
                Exercise(name: "DB Incline Front Raise"),
                Exercise(name: "Russian Twist"),
            ]),
        ]
    )

    static let lowerBody1 = Workout(
        name: "Lower Body 1",
        warmup: [
            Exercise(name: "Perfect Stretch", reps: "6 reps"),
            Exercise(name: "Frog Squat Stretch", reps: "8 reps"),
            Exercise(name: "BW Single Leg Glute Bridge", reps: "10 reps"),
            Exercise(name: "Lateral Lunge Stretch", reps: "30 sec"),
        ],
        blocks: [
            WorkoutBlock(name: "Block 1", sets: 4, reps: [8, 8, 6, 6], exercises: [
                Exercise(name: "DB Stiff Leg Deadlift"),
            ]),
            WorkoutBlock(name: "Block 2", sets: 3, reps: [12, 12, 12], superset: true, exercises: [
                Exercise(name: "DB Squat Snatch"),
                Exercise(name: "Band Good Morning"),
            ]),
        ],
        accessories: [
            WorkoutBlock(name: "Superset A", sets: 3, reps: [12, 12, 12], exercises: [
                Exercise(name: "BW Heels Elevated Single Leg Hip Thrust"),
                Exercise(name: "Star Side Plank"),
            ]),
            WorkoutBlock(name: "Superset B", sets: 3, reps: [10, 10, 10], exercises: [
                Exercise(name: "BW Standing Calf Raise"),
                Exercise(name: "Reverse Crunch"),
            ]),
        ]
    )

    static let lowerBody2 = Workout(
        name: "Lower Body 2",
        warmup: [
            Exercise(name: "Perfect Stretch", reps: "6 reps"),
            Exercise(name: "Pyramid Pose Stretch", reps: "30 sec"),
            Exercise(name: "BW Walking Lunge", reps: "8 reps"),
            Exercise(name: "Lateral Lunge Stretch", reps: "30 sec"),
        ],
        blocks: [
            WorkoutBlock(name: "Block 1", sets: 4, reps: [8, 8, 6, 6], exercises: [
                Exercise(name: "DB Squat Jump"),
            ]),
            WorkoutBlock(name: "Block 2", sets: 3, reps: [12, 12, 12], superset: true, exercises: [
                Exercise(name: "DB Bulgarian Split Squat"),
                Exercise(name: "DB Sumo Deadlift"),
            ]),
        ],
        accessories: [
            WorkoutBlock(name: "Superset A", sets: 3, reps: [8, 8, 8], exercises: [
                Exercise(name: "BW Single Leg Skater Squat"),
                Exercise(name: "Bicycle Crunch"),
            ]),
            WorkoutBlock(name: "Superset B", sets: 3, reps: [15, 15, 15], exercises: [
                Exercise(name: "Kettlebell Waiter Carry"),
                Exercise(name: "Feet Elevated Spider"),
            ]),
        ]
    )

    static func workout(for day: WorkoutDay) -> Workout? {
        switch day {
        case .upperBody1: return upperBody1
        case .upperBody2: return upperBody2
        case .lowerBody1: return lowerBody1
        case .lowerBody2: return lowerBody2
        case .rest: return nil
        }
    }
}
