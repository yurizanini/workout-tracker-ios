import SwiftUI

// MARK: - App Theme

enum AppTheme {
    // Primary brand colors
    static let accent = Color(red: 0.36, green: 0.55, blue: 1.0)
    static let accentGradientStart = Color(red: 0.36, green: 0.55, blue: 1.0)
    static let accentGradientEnd = Color(red: 0.25, green: 0.42, blue: 0.95)

    // Fitness-themed palette
    static let energy = Color(red: 1.0, green: 0.6, blue: 0.2)       // Orange energy
    static let power = Color(red: 0.85, green: 0.25, blue: 0.35)     // Red power
    static let success = Color(red: 0.2, green: 0.78, blue: 0.55)    // Green success
    static let focus = Color(red: 0.36, green: 0.55, blue: 1.0)      // Blue focus
    static let recovery = Color(red: 0.55, green: 0.45, blue: 0.85)  // Purple recovery

    // Neutral tones
    static let cardBackground = Color(.systemBackground)
    static let elevatedBackground = Color(.secondarySystemBackground)
    static let screenBackground = Color(red: 0.96, green: 0.96, blue: 0.98)

    // Text
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)

    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [accentGradientStart, accentGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let energyGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.65, blue: 0.3), Color(red: 1.0, green: 0.45, blue: 0.2)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [Color(red: 0.25, green: 0.85, blue: 0.6), Color(red: 0.15, green: 0.7, blue: 0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 12
    static let spacingLG: CGFloat = 16
    static let spacingXL: CGFloat = 24
    static let spacingXXL: CGFloat = 32

    // Corner Radius
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 20

    // Shadows
    static let shadowLight = Color.black.opacity(0.04)
    static let shadowMedium = Color.black.opacity(0.08)
    static let shadowHeavy = Color.black.opacity(0.12)
}

// MARK: - Card Style Modifier

struct CardStyle: ViewModifier {
    var padding: CGFloat = AppTheme.spacingLG

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .fill(AppTheme.cardBackground)
                    .shadow(color: AppTheme.shadowLight, radius: 2, x: 0, y: 1)
                    .shadow(color: AppTheme.shadowMedium, radius: 8, x: 0, y: 4)
            )
    }
}

struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.spacingLG)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusLG)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.shadowLight, radius: 4, x: 0, y: 2)
            )
    }
}

extension View {
    func cardStyle(padding: CGFloat = AppTheme.spacingLG) -> some View {
        modifier(CardStyle(padding: padding))
    }

    func glassCard() -> some View {
        modifier(GlassCard())
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    var gradient: LinearGradient = AppTheme.primaryGradient

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .fill(gradient)
                    .shadow(color: AppTheme.focus.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundColor(AppTheme.focus)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .fill(AppTheme.focus.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.radiusMD)
                    .stroke(AppTheme.focus.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Workout Icon Helper

struct WorkoutIcon {
    static func icon(for workoutDay: WorkoutDay) -> String {
        switch workoutDay {
        case .upperBody1, .upperBody2: return "figure.arms.open"
        case .lowerBody1, .lowerBody2: return "figure.run"
        case .rest: return "moon.fill"
        }
    }

    static func color(for workoutDay: WorkoutDay) -> Color {
        switch workoutDay {
        case .upperBody1: return AppTheme.focus
        case .upperBody2: return AppTheme.recovery
        case .lowerBody1: return AppTheme.energy
        case .lowerBody2: return AppTheme.power
        case .rest: return AppTheme.textTertiary
        }
    }
}
