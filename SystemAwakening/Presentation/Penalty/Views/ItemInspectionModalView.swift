//
//  ItemInspectionModalView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Item Inspection Modal matching the Screen 6 modal specification.
@MainActor
public struct ItemInspectionModalView: View {
    @Bindable var viewModel: PenaltyZoneViewModel
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: PenaltyZoneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.systemPrimary)
                            .frame(width: 7, height: 7)
                        Text("[SYSTEM INVENTORY // ITEM TELEMETRY]")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)
                    }

                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.systemTextSecondary)
                            .padding(6)
                            .background(Color.systemCard)
                            .clipShape(Circle())
                    }
                }

                // Item Header Card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.systemPenaltyCrimson.opacity(0.2))
                        Image(systemName: "cross.vial.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.systemPenaltyCrimson)
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text("GRADE: SPECIAL RECOVERY")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(Color.systemPrimary)
                            Spacer()
                            Text("QTY: \(viewModel.purifiedPotionsRemaining) / 5")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.systemPenaltyCrimson)
                        }

                        Text("Purified Essence Potion")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemTextPrimary)

                        Text("[DIMENSION EMBARGO: RE-STOCK DISABLED]")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(.systemPenaltyCrimson)
                    }
                }
                .padding(12)
                .background(Color.systemCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    telemetryPill(title: "IMMEDIATE EFFECT", value: "-20 Fatigue", subtitle: "Prevents death coma lock", valueColor: .systemPenaltyCrimson)
                    telemetryPill(title: "VITAL INTEGRITY", value: "+2,000 HP", subtitle: "Restoration applied", valueColor: Color.systemPrimary)
                    telemetryPill(title: "COOLDOWN RATE", value: "120 Seconds", subtitle: "Global recovery lock", valueColor: Color.systemSecondary)
                    telemetryPill(title: "HEAT PENALTY", value: "80% Efficacy", subtitle: "Degraded by climate", valueColor: .systemPenaltyCrimson)
                }

                // Lore
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "terminal.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color.systemPrimary)
                        Text("ITEM ARCHIVE LORE")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                    }

                    Text("Synthesized from essence gathered in high-tier dimensional tears. Purges toxic exhaustion and temporarily stabilizes vital signs under harsh dimensional gravity.")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(Color.systemTextSecondary)
                        .lineSpacing(2)
                }
                .padding(12)
                .background(Color.systemCard.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                // Actions
                VStack(spacing: 8) {
                    Button(action: {
                        viewModel.consumePurifiedPotion()
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "cross.vial.fill")
                            Text("CONSUME POTION (-20 FATIGUE)")
                                .font(.system(size: 12, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.systemPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 6)
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.purifiedPotionsRemaining == 0)

                    Button("CANCEL / RETURN TO HUD") {
                        dismiss()
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)
                    .padding(.vertical, 6)
                }
            }
            .padding(18)
        }
        .presentationDetents([.fraction(0.65)])
        .preferredColorScheme(.dark)
    }

    private func telemetryPill(title: String, value: String, subtitle: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundColor(Color.systemTextSecondary)
            Text(value)
                .font(.system(size: 12, weight: .black, design: .monospaced))
                .foregroundColor(valueColor)
            Text(subtitle)
                .font(.system(size: 8))
                .foregroundColor(Color.systemTextSecondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.systemCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ItemInspectionModalView(viewModel: PenaltyZoneViewModel())
}
