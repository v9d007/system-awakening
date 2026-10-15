//
//  PenaltyZoneView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Container screen coordinating between Screen 5 (Emergency Alert) and Screen 6 (Tactical Survival HUD).
///
/// **Interview Rationale:**
/// - State machine view switching: Rather than using multiple separate screens, `PenaltyZoneView` manages the
///   dimensional state transition between the warning briefing (`.alert`) and the live survival combat overlay
///   (`.tacticalGameplay`), providing fluid continuity and preserving timer state.
@MainActor
public struct PenaltyZoneView: View {
    @State private var viewModel: PenaltyZoneViewModel
    @Environment(\.dismiss) private var dismiss
    public let showsDismissButton: Bool

    public init(viewModel: PenaltyZoneViewModel, showsDismissButton: Bool = true) {
        self._viewModel = State(initialValue: viewModel)
        self.showsDismissButton = showsDismissButton
    }

    public init(showsDismissButton: Bool = true) {
        self._viewModel = State(initialValue: PenaltyZoneViewModel())
        self.showsDismissButton = showsDismissButton
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.systemBackground
                .ignoresSafeArea()

            Group {
                switch viewModel.mode {
                case .alert:
                    PenaltyAlertView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                case .tacticalGameplay:
                    TacticalGameplayView(viewModel: viewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.05)),
                            removal: .opacity.combined(with: .scale(scale: 0.95))
                        ))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.8), value: viewModel.mode)

            // Quick Close / Dismiss Button (Omitted when hosted in Tab Bar)
            if showsDismissButton {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color.systemTextSecondary)
                        .padding(10)
                        .background(Color.systemCard.opacity(0.85))
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color.systemBorder, lineWidth: 1)
                        )
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
        }
        .overlay(escapeSuccessOverlay)
    }

    // MARK: - Escape / Clear Celebration Overlay

    @ViewBuilder
    private var escapeSuccessOverlay: some View {
        if viewModel.showEscapeSuccessOverlay {
            ZStack {
                Color.black.opacity(0.85)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 42))
                        .foregroundColor(Color.systemPrimary)
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.9), radius: 10)

                    Text("PENALTY EVADED!")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text(viewModel.escapeMessage.isEmpty ? "Survival Protocol Fulfilled! Warp gate opened." : viewModel.escapeMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        withAnimation {
                            viewModel.showEscapeSuccessOverlay = false
                            viewModel.mode = .alert
                            dismiss()
                        }
                    }) {
                        Text("RETURN TO HUNTER HUD")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.systemPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .frame(maxWidth: 320)
                .holographicCard(cornerRadius: 20, glowColor: Color.systemPrimaryGlow, isGlowing: true)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    PenaltyZoneView()
}
