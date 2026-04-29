import SwiftUI
import UIKit

// MARK: - Display mode (light / dark / system)

enum AppColorScheme: String, CaseIterable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    // nil lets the device decide (system default)
    var preference: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Accent color

enum AppAccentColor: String, CaseIterable, Identifiable {
    case `default` = "default"
    case pink      = "pink"
    case blue      = "blue"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: return "Default"
        case .pink:    return "Pink"
        case .blue:    return "Blue"
        }
    }

    var color: Color {
        switch self {
        case .default: return Color.accentColor
        case .pink:    return Color(red: 0.98, green: 0.38, blue: 0.66)
        case .blue:    return Color(red: 0.20, green: 0.50, blue: 0.98)
        }
    }

    var titleUIColor: UIColor {
        switch self {
        case .default: return .label
        case .pink:    return UIColor(red: 0.98, green: 0.38, blue: 0.66, alpha: 1)
        case .blue:    return UIColor(red: 0.20, green: 0.50, blue: 0.98, alpha: 1)
        }
    }
}

// MARK: - Color swatch button

struct ColorSwatch: View {
    let accent: AppAccentColor
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(accent.color)
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? accent.color : Color.secondary.opacity(0.25),
                                    lineWidth: isSelected ? 3 : 1
                                )
                                .padding(-4)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }

                Text(accent.displayName)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
