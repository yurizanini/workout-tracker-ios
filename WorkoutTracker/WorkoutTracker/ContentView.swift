import SwiftUI

enum AppView {
    case home
    case workout(String)
    case schedule
    case progress
    case done(String)
}

struct ContentView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var currentView: AppView = .home
    @State private var navigationPath: [AppView] = []

    var body: some View {
        NavigationStack {
            Group {
                switch currentView {
                case .home:
                    HomeView(navigate: navigate)
                case .workout(let name):
                    WorkoutSessionView(workoutName: name, navigate: navigate)
                case .schedule:
                    ScheduleView(navigate: navigate)
                case .progress:
                    ProgressView2(navigate: navigate)
                case .done(let name):
                    CompletionView(workoutName: name, navigate: navigate)
                }
            }
        }
    }

    private func navigate(to view: AppView) {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentView = view
        }
    }
}
