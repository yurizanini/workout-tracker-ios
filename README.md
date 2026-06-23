# Workout Tracker iOS

A native iOS workout tracker app built with SwiftUI for a body recomposition program.

## Features

- **Weekly Schedule** — See your workout plan for the week at a glance with completion tracking
- **Workout Sessions** — Step through warmup, main blocks, and accessories with guided navigation
- **Weight & Rep Logging** — Track your weights and reps per set for every exercise
- **Progress History** — Review your completed workouts and logged weights by week
- **Schedule Editing** — Customize which workout goes on which day
- **YouTube Links** — Quick access to exercise tutorial videos

## Workouts

The app includes 4 workout routines:

| Workout | Focus |
|---------|-------|
| Upper Body 1 | Push Press, Lat Pulldown, Bench Press, Rows |
| Upper Body 2 | Incline Press, Incline Row, Arnold Press, Reverse Fly |
| Lower Body 1 | Stiff Leg Deadlift, Squat Snatch, Good Morning |
| Lower Body 2 | Squat Jump, Bulgarian Split Squat, Sumo Deadlift |

Each workout includes:
- Warm-up exercises (1 round, no weights)
- 2 main blocks (compound movements)
- 2 accessory supersets (isolation work)

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

1. Clone this repository
2. Open `WorkoutTracker/WorkoutTracker.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (Cmd+R)

## Architecture

- **SwiftUI** — Declarative UI framework
- **MVVM** — Model-View-ViewModel pattern
- **UserDefaults** — Local data persistence for schedule and workout logs
- **No external dependencies** — Pure Apple frameworks

## Project Structure

```
WorkoutTracker/
├── WorkoutTracker.xcodeproj/
└── WorkoutTracker/
    ├── WorkoutTrackerApp.swift      # App entry point
    ├── ContentView.swift            # Root navigation
    ├── Models/
    │   └── WorkoutData.swift        # Data models & static workout database
    ├── ViewModels/
    │   └── WorkoutViewModel.swift   # Business logic & persistence
    └── Views/
        ├── HomeView.swift           # Main dashboard
        ├── WorkoutSessionView.swift # Active workout session
        ├── ScheduleView.swift       # Schedule editor
        ├── ProgressView2.swift      # Workout history
        └── CompletionView.swift     # Post-workout celebration
```
