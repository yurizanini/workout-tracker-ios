import SwiftUI

struct CompletionView: View {
    let workoutName: String
    let navigate: (AppView) -> Void

    @State private var animateCheck = false
    @State private var animateText = false

    var body: some View {
        VStack(spacing: AppTheme.spacingXXL) {
            Spacer()

            // Celebration icon
            ZStack {
                Circle()
                    .fill(AppTheme.success.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animateCheck ? 1.0 : 0.5)

                Circle()
                    .fill(AppTheme.success.opacity(0.2))
                    .frame(width: 88, height: 88)
                    .scaleEffect(animateCheck ? 1.0 : 0.5)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(AppTheme.success)
                    .scaleEffect(animateCheck ? 1.0 : 0.3)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateCheck)

            // Text
            VStack(spacing: 8) {
                Text("Workout Complete!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.textPrimary)

                Text("Great work finishing \(workoutName).")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
            .opacity(animateText ? 1 : 0)
            .offset(y: animateText ? 0 : 10)
            .animation(.easeOut(duration: 0.4).delay(0.3), value: animateText)

            Spacer()

            // Buttons
            VStack(spacing: AppTheme.spacingMD) {
                Button {
                    navigate(.home)
                } label: {
                    Text("Back to Home")
                }
                .buttonStyle(GradientButtonStyle())

                Button {
                    navigate(.progress)
                } label: {
                    Text("View Progress")
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            .opacity(animateText ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.5), value: animateText)
        }
        .padding(AppTheme.spacingXL)
        .background(AppTheme.screenBackground.ignoresSafeArea())
        .onAppear {
            animateCheck = true
            animateText = true
        }
    }
}
