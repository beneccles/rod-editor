import SwiftUI

/// Modal view displaying AI-generated text variations
struct VariationModalView: View {
    let variations: [TextVariation]
    let isLoading: Bool
    let errorMessage: String?
    let onSelectVariation: (TextVariation) -> Void
    let onTryAgain: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                            .frame(width: 60, height: 60)
                    }
                    .accessibilityLabel("Close")
                }

                if isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Checking your text...")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button(action: onTryAgain) {
                            Text("Try Again")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .frame(maxWidth: 300)
                        .accessibilityLabel("Try again")
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    // Variations display
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(variations) { variation in
                                VariationCard(
                                    text: variation.correctedText,
                                    onSelect: { onSelectVariation(variation) }
                                )
                            }

                            Button(action: onTryAgain) {
                                Text("Try Again")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(12)
                            }
                            .frame(maxWidth: 600)
                            .accessibilityLabel("Try again to get new variations")
                        }
                        .padding()
                    }
                }
            }
            .padding()
            .frame(maxWidth: 700)
        }
        .interactiveDismissDisabled(true) // Prevent swipe-to-dismiss
    }
}

/// Individual variation card component
struct VariationCard: View {
    let text: String
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(text)
                .font(.system(size: 18))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)

            Button(action: onSelect) {
                Text("Use This")
                    .font(.headline)
                    .frame(minWidth: 88, minHeight: 60)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Use this variation")
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
