//
//  QuestCardView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// An interactive holographic card displaying a single Daily Quest objective.
@MainActor
public struct QuestCardView: View {
    public let quest: DailyQuest
    public let onIncrement: () -> Void
    public let onDelete: (() -> Void)?

    public init(
        quest: DailyQuest,
        onIncrement: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.quest = quest
        self.onIncrement = onIncrement
        self.onDelete = onDelete
    }

    private var formattedReminderTime: String? {
        guard quest.isReminderEnabled, let time = quest.reminderTime else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    public var body: some View {
        HStack(spacing: 14) {
            // Radial Progress / Checkmark Indicator
            ZStack {
                CircularProgressView(
                    progress: quest.progressFraction,
                    lineWidth: 4,
                    primaryColor: quest.isCompleted ? Color.systemPrimary : Color.systemPrimary.opacity(0.8),
                    secondaryColor: quest.isCompleted ? Color.systemPrimary : Color.systemSecondary
                )
                .frame(width: 44, height: 44)

                if quest.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .black))
                        .foregroundColor(Color.systemPrimary)
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.9), radius: 6)
                } else {
                    Text("\(Int(quest.progressFraction * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }
            }

            // Quest Details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quest.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.systemTextPrimary)

                    Spacer()

                    Text(quest.formattedProgress)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(quest.isCompleted ? Color.systemPrimary : Color.systemTextSecondary)
                }

                // Reward & Telemetry Badges Row
                HStack(spacing: 6) {
                    // EXP Reward Pill
                    HStack(spacing: 3) {
                        Text("+\(quest.expReward)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                        Text("EXP")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPrimary.opacity(0.12))
                    .clipShape(Capsule())

                    // Stat Pillar Reward Pill
                    HStack(spacing: 3) {
                        Text("+1")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                        Text(quest.statPillar.rawValue)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(Color.systemSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemSecondary.opacity(0.15))
                    .clipShape(Capsule())

                    // Offline Reminder Badge
                    if let reminder = formattedReminderTime {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 8))
                            Text(reminder)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(Color.systemPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.systemPrimary.opacity(0.10))
                        .clipShape(Capsule())
                    }

                    if quest.isEssential {
                        Text("ESSENTIAL")
                            .font(.system(size: 8.5, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPenaltyCrimson)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.systemPenaltyCrimson.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            // Quick Complete / Action Button
            Button(action: onIncrement) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(quest.isCompleted ? Color.systemPrimary.opacity(0.2) : Color.systemCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(quest.isCompleted ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                        )

                    Image(systemName: quest.isCompleted ? "checkmark.circle.fill" : "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(quest.isCompleted ? Color.systemPrimary : .white)
                }
                .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .disabled(quest.isCompleted)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .holographicCard(cornerRadius: 14, isGlowing: quest.isCompleted)
        .contextMenu {
            if let onDelete = onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Directive", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.systemBackground.ignoresSafeArea()
        VStack(spacing: 12) {
            QuestCardView(
                quest: DailyQuest(title: "100 Push-ups", statPillar: .strength, targetQuantity: 100, currentQuantity: 100, unit: "reps", expReward: 30, isCompleted: true),
                onIncrement: {}
            )
            QuestCardView(
                quest: DailyQuest(title: "Deep Work Focus", statPillar: .intelligence, targetQuantity: 120, currentQuantity: 90, unit: "min", expReward: 50, isCompleted: false, reminderTime: Date(), isReminderEnabled: true),
                onIncrement: {}
            )
        }
        .padding()
    }
}
