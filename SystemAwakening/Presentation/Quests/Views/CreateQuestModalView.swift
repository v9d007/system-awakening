//
//  CreateQuestModalView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Modal sheet empowering Hunters to forge custom offline daily directives and configure local telemetry reminders.
@MainActor
public struct CreateQuestModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = DailyQuestViewModel.shared

    // Form inputs
    @State private var title: String = ""
    @State private var descriptionText: String = ""
    @State private var selectedStat: StatType = .strength
    @State private var targetQuantity: Double = 50
    @State private var selectedUnit: String = "reps"
    @State private var customUnit: String = ""
    @State private var isCustomUnitActive: Bool = false

    // Offline reminder state
    @State private var isReminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(
        bySettingHour: 9,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date()

    // Penalty zone essential flag
    @State private var isEssential: Bool = true

    // Validation alert
    @State private var showValidationError: Bool = false
    @State private var validationErrorMessage: String = ""

    private let presetUnits: [String] = ["reps", "min", "steps", "km", "L", "pages", "hrs"]

    public init() {}

    private var effectiveUnit: String {
        isCustomUnitActive ? (customUnit.isEmpty ? "units" : customUnit) : selectedUnit
    }

    private var calculatedExp: Int {
        let baseExp: Int
        switch selectedStat {
        case .intelligence: baseExp = 40
        case .strength: baseExp = 30
        case .agility: baseExp = 35
        case .vitality: baseExp = 25
        case .perception: baseExp = 35
        }
        return isEssential ? Int(Double(baseExp) * 1.2) : baseExp
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.systemBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        systemDirectiveHeader
                        directiveTitleSection
                        statPillarSelector
                        targetGoalSection
                        reminderSection
                        penaltyProtocolSection
                        rewardPreviewCard
                        issueDirectiveCTA
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("NEW DIRECTIVE")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("ABORT") {
                        dismiss()
                    }
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)
                }
            }
            .alert("INVALID DIRECTIVE", isPresented: $showValidationError) {
                Button("ACKNOWLEDGE", role: .cancel) {}
            } message: {
                Text(validationErrorMessage)
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - 1. System Directive Header

    private var systemDirectiveHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemPrimary)
                    .frame(width: 7, height: 7)
                    .shadow(color: Color.systemPrimaryGlow, radius: 4)

                Text("SYSTEM PROTOCOL // OFFLINE DIRECTIVE GENERATOR")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)

                Spacer()

                Text("LOCAL ONLY")
                    .font(.system(size: 8.5, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPrimary.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                    )
            }

            Text("Forge a personalized daily objective to awaken your latent attributes.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.systemTextSecondary)
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    // MARK: - 2. Directive Title & Description

    private var directiveTitleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DIRECTIVE DESIGNATION")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(Color.systemTextPrimary)

            TextField("e.g. 100 Push-ups, Deep Work Session...", text: $title)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(12)
                .background(Color.systemCard)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(title.isEmpty ? Color.systemBorder : Color.systemPrimary, lineWidth: 1.2)
                )

            TextField("Optional tactical description or instructions...", text: $descriptionText)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.white)
                .padding(10)
                .background(Color.systemCard.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.systemBorder.opacity(0.5), lineWidth: 1)
                )
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    // MARK: - 3. Stat Pillar Selector

    private var statPillarSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ATTRIBUTE PILLAR")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemTextPrimary)

                Spacer()

                Text("BUFFS: +1 \(selectedStat.abbr)")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }

            VStack(spacing: 8) {
                ForEach(StatType.rowOrderedStats) { stat in
                    let isSelected = selectedStat == stat

                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedStat = stat
                        }
                        SystemHaptics.shared.selectionTick()
                    }) {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.systemPrimary.opacity(0.25) : Color.systemBackground.opacity(0.8))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                                    )

                                Image(systemName: stat.iconSystemName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(isSelected ? Color.systemPrimary : Color.systemTextSecondary)
                            }
                            .frame(width: 36, height: 36)

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(stat.abbr)
                                        .font(.system(size: 12, weight: .black, design: .monospaced))
                                        .foregroundColor(isSelected ? Color.systemPrimary : .white)

                                    Text(stat.displayName)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(isSelected ? .white : Color.systemTextSecondary)
                                }

                                Text(stat.habitCategory)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Color.systemTextSecondary.opacity(0.8))
                                    .lineLimit(1)
                            }

                            Spacer()

                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Color.systemPrimary)
                                    .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 4)
                            }
                        }
                        .padding(10)
                        .background(isSelected ? Color.systemPrimary.opacity(0.08) : Color.systemCard.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(isSelected ? Color.systemPrimary : Color.systemBorder.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    // MARK: - 4. Target Goal & Unit Section

    private var targetGoalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TARGET QUOTA")
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(Color.systemTextPrimary)

            HStack(spacing: 12) {
                // Stepper Buttons
                Button(action: {
                    if targetQuantity > 5 {
                        targetQuantity -= 5
                        SystemHaptics.shared.selectionTick()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color.systemPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                // Central Quantity Readout
                VStack(spacing: 2) {
                    Text("\(Int(targetQuantity))")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text(effectiveUnit)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.systemBackground.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                )

                Button(action: {
                    targetQuantity += 5
                    SystemHaptics.shared.selectionTick()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color.systemPrimary)
                        .frame(width: 40, height: 40)
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }

            // Quick Unit Selection Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(presetUnits, id: \.self) { unit in
                        let isSelected = !isCustomUnitActive && selectedUnit == unit

                        Button(action: {
                            isCustomUnitActive = false
                            selectedUnit = unit
                            SystemHaptics.shared.selectionTick()
                        }) {
                            Text(unit)
                                .font(.system(size: 10, weight: isSelected ? .black : .bold, design: .monospaced))
                                .foregroundColor(isSelected ? .black : Color.systemTextSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(isSelected ? Color.systemPrimary : Color.systemCard)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(isSelected ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    // Custom Unit Pill
                    Button(action: {
                        isCustomUnitActive = true
                        SystemHaptics.shared.selectionTick()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 9))
                            Text("custom")
                                .font(.system(size: 10, weight: isCustomUnitActive ? .black : .bold, design: .monospaced))
                        }
                        .foregroundColor(isCustomUnitActive ? .black : Color.systemTextSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isCustomUnitActive ? Color.systemPrimary : Color.systemCard)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isCustomUnitActive ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if isCustomUnitActive {
                TextField("Type custom unit (e.g. pages, sets, oz)...", text: $customUnit)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.systemCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8).stroke(Color.systemPrimary.opacity(0.6), lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    // MARK: - 5. System Reminder Section (Offline UNUserNotificationCenter)

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: $isReminderEnabled.animation()) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isReminderEnabled ? Color.systemPrimary.opacity(0.2) : Color.systemCard)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isReminderEnabled ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                            )

                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(isReminderEnabled ? Color.systemPrimary : Color.systemTextSecondary)
                    }
                    .frame(width: 34, height: 34)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("SYSTEM TELEMETRY REMINDER")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)

                        Text("Scheduled local notification (100% offline).")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.systemTextSecondary)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.systemPrimary))

            if isReminderEnabled {
                HStack {
                    Text("TRIGGER TIME:")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)

                    Spacer()

                    DatePicker(
                        "",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .colorScheme(.dark)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.systemCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                )

                Text("[ALERT DISPATCH]: An emergency awakening directive notification will sound daily at the configured hour.")
                    .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    // MARK: - 6. Penalty Protocol Section

    private var penaltyProtocolSection: some View {
        Toggle(isOn: $isEssential) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isEssential ? Color.systemPenaltyCrimson.opacity(0.2) : Color.systemCard)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isEssential ? Color.systemPenaltyCrimson : Color.systemBorder, lineWidth: 1)
                        )

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(isEssential ? Color.systemPenaltyCrimson : Color.systemTextSecondary)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text("ESSENTIAL DIRECTIVE")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(isEssential ? Color.systemPenaltyCrimson : .white)

                    Text("Failing this directive by midnight activates the Penalty Zone.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                }
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: Color.systemPenaltyCrimson))
        .padding(14)
        .holographicCard(cornerRadius: 14, glowColor: isEssential ? Color.systemPenaltyCrimson : Color.systemBorder, isGlowing: false)
    }

    // MARK: - 7. Reward Preview Card

    private var rewardPreviewCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("POTENTIAL CLEARANCE REWARDS")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)

                Text("Awarded automatically upon directive completion.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color.systemTextSecondary.opacity(0.8))
            }

            Spacer()

            HStack(spacing: 6) {
                Text("+\(calculatedExp) EXP")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.systemPrimary.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemPrimary.opacity(0.5), lineWidth: 1)
                    )

                Text("+1 \(selectedStat.abbr)")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.systemSecondary.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemSecondary.opacity(0.5), lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .background(Color.systemCard.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(Color.systemBorder, lineWidth: 1)
        )
    }

    // MARK: - 8. Primary CTA

    private var issueDirectiveCTA: some View {
        Button(action: handleIssueDirective) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 14, weight: .black))

                Text("ISSUE DIRECTIVE")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .tracking(1.2)
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func handleIssueDirective() {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedTitle.isEmpty else {
            validationErrorMessage = "Directive designation cannot be empty. Please specify an objective title."
            showValidationError = true
            return
        }

        guard targetQuantity > 0 else {
            validationErrorMessage = "Target quota must be greater than zero."
            showValidationError = true
            return
        }

        viewModel.addQuest(
            title: cleanedTitle,
            description: descriptionText,
            statPillar: selectedStat,
            targetQuantity: targetQuantity,
            unit: effectiveUnit,
            expReward: calculatedExp,
            reminderTime: isReminderEnabled ? reminderTime : nil,
            isReminderEnabled: isReminderEnabled,
            isEssential: isEssential
        )

        dismiss()
    }
}

#Preview {
    CreateQuestModalView()
}
