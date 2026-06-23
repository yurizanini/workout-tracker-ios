import SwiftUI

struct CompletionView: View {
    let workoutName: String
    let navigate: (AppView) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "party.popper.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Workout complete!")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Great work finishing \(workoutName).")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button {
                    navigate(.home)
                } label: {
                    Text("Home")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    navigate(.progress)
                } label: {
                    Text("View Progress")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 12)

            Spacer()
        }
        .padding(32)
    }
}
