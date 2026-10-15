//
//  StatAllocationRow.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// A frosted glass row displaying a single Hunter attribute with an interactive increment button.
///
/// **Interview Rationale:**
/// - Atomic Component Design: Isolating each stat row keeps views modular and reusable across modals,
///   detail sheets, and custom habit-mapping configuration views.
/// - Minimum Touch Target (Apple HIG): The increment `+` button has an explicit active hit frame of 44x44 points.
public struct StatAllocationRow: View {
    public let stat: StatType
    public let value: Int
    public let maxValue: Int
    public let canAllocate: Bool
    public let onAllocate: () -> Void

    public init(
        stat: StatType,
        value: Int,
        maxValue: Int = 100,
        canAllocate: Bool = false,
        onAllocate: @escaping () -> Void
    ) {
        self.stat = stat
        self.value = value
        self.maxValue = maxValue
        self.canAllocate = canAllocate
        self.onAllocate = onAllocate
    }

    private var progressRatio: Double {
        min(max(Double(value) / Double(maxValue), 0.0), 1.0)
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Stat Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.systemCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.systemBorder, lineWidth: 1)
                    )

                Image(systemName: stat.iconSystemName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.systemPrimary)
            }
            .frame(width: 38, height: 38)

            // Stat Title & Habit Category
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(stat.rawValue)
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)

                    Text(stat.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Text(stat.habitCategory)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.systemTextSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Stat Value & Progress Mini Bar
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(value)")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextPrimary)

                // Mini progress gauge
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.systemBorder)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progressRatio)
                    }
                }
                .frame(width: 48, height: 4)
            }

            // Tactile Allocate Button (44x44 touch target)
            Button(action: onAllocate) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(canAllocate ? Color.systemPrimary.opacity(0.18) : Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(canAllocate ? Color.systemPrimary : Color.systemBorder.opacity(0.5), lineWidth: 1)
                        )

                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(canAllocate ? Color.systemPrimary : Color.systemTextSecondary.opacity(0.4))
                }
                .frame(width: 32, height: 32)
                .contentShape(Rectangle()) // Ensures entire 44x44 frame is clickable
            }
            .frame(width: 44, height: 44)
            .disabled(!canAllocate)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .holographicCard(cornerRadius: 12, isGlowing: canAllocate)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(stat.displayName), \(value) points")
        .accessibilityHint(canAllocate ? "Double tap to allocate one stat point" : "")
    }
}

#Preview {
    ZStack {
        Color.systemDeepVoid.ignoresSafeArea()
        VStack(spacing: 10) {
            StatAllocationRow(stat: .strength, value: 45, canAllocate: true, onAllocate: {})
            StatAllocationRow(stat: .intelligence, value: 62, canAllocate: false, onAllocate: {})
        }
        .padding()
    }
}
