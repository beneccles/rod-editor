import SwiftUI

/// A large, accessible button component optimized for users with motor tremors
struct AccessibleButton: View {
    let label: String
    let systemImage: String
    let action: () -> Void
    var size: ButtonSize = .primary
    var isDestructive: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 28))
                Text(label)
                    .font(.system(size: 16, weight: .medium))
            }
            .frame(minWidth: size.minWidth, minHeight: size.minHeight)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
            )
            .foregroundColor(foregroundColor)
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .disabled(isDisabled)
        .accessibilityLabel(label)
        .accessibilityHint(isDisabled ? "Button is disabled" : "")
    }

    private var backgroundColor: Color {
        if isDestructive {
            return Color.red.opacity(0.1)
        }
        return Color(.systemGray6)
    }

    private var foregroundColor: Color {
        if isDestructive {
            return .red
        }
        return .primary
    }
}

/// Predefined button sizes for accessibility
enum ButtonSize {
    case primary    // 100x80pt minimum
    case secondary  // 88x80pt minimum
    case close      // 60x60pt minimum

    var minWidth: CGFloat {
        switch self {
        case .primary: return 100
        case .secondary: return 88
        case .close: return 60
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .primary, .secondary: return 80
        case .close: return 60
        }
    }
}
