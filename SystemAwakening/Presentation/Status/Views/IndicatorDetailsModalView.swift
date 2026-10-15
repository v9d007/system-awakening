//
//  IndicatorDetailsModalView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Detailed modal sheet displaying all 5 Hunter Attribute Indicators, their progression metrics across
/// Weekly, Monthly, and Yearly timeframes, and the full list of associated Daily Directive protocols.
@MainActor
public struct IndicatorDetailsModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var profileManager = ProfileManager.shared
    @State private var questViewModel = DailyQuestViewModel.shared

    @State private var selectedFilter: StatType? = nil
    @State private var selectedTimeframe: StatProgressTimeframe = .weekly

    public init(initialStat: StatType? = nil, timeframe: StatProgressTimeframe = .weekly) {
        self._selectedFilter = State(initialValue: initialStat)
        self._selectedTimeframe = State(initialValue: timeframe)
    }

    private var displayedStats: [StatType] {
        if let filter = selectedFilter {
            return [filter]
        } else {
            return StatType.rowOrderedStats
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.systemBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        headerSummaryCard
                        timeframeSelector
                        filterCategoryPills
                        indicatorsList
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("INDICATOR TELEMETRY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.systemTextSecondary)
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Header Summary Card

    private var headerSummaryCard: some View {
        let stats = profileManager.profile.stats
        let totalPwr = stats.values.reduce(0, +)
        let growth = selectedTimeframe.totalGrowth(stats: stats)

        return VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.systemPrimary)
                        .frame(width: 7, height: 7)
                        .shadow(color: Color.systemPrimaryGlow, radius: 4)

                    Text("[HUNTER ATTRIBUTE TELEMETRY]")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }

                Spacer()

                Text(selectedTimeframe.telemetrySummary(stats: stats))
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.systemPrimary.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                    )
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL POWER")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                    Text("\(totalPwr)")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Divider()
                    .frame(height: 32)
                    .background(Color.systemBorder)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(selectedTimeframe.shortTitle) GROWTH")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                    Text("+\(growth) PWR")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("DIRECTIVES LINKED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                    Text("\(questViewModel.quests.count)")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemGateAmber)
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 16)
    }

    // MARK: - Timeframe Selector Pill

    private var timeframeSelector: some View {
        HStack(spacing: 8) {
            ForEach(StatProgressTimeframe.allCases) { timeframe in
                let isSelected = selectedTimeframe == timeframe

                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedTimeframe = timeframe
                    }
                    SystemHaptics.shared.selectionTick()
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10, weight: isSelected ? .bold : .regular))
                        Text(timeframe.rawValue)
                            .font(.system(size: 10, weight: isSelected ? .black : .bold, design: .monospaced))
                    }
                    .foregroundColor(isSelected ? .black : Color.systemTextSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(isSelected ? Color.systemPrimary : Color.systemCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                    )
                    .shadow(color: isSelected ? Color.systemPrimaryGlow.opacity(0.5) : .clear, radius: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Filter Category Pills

    private var filterCategoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // ALL Pill
                filterButton(title: "ALL (5)", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                // Individual Stat Pills
                ForEach(StatType.rowOrderedStats) { stat in
                    let isSelected = selectedFilter == stat
                    filterButton(title: "\(stat.abbr) \(stat.displayName)", isSelected: isSelected) {
                        selectedFilter = stat
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                action()
            }
            SystemHaptics.shared.selectionTick()
        }) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .black : .semibold, design: .monospaced))
                .foregroundColor(isSelected ? Color.systemPrimary : Color.systemTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.systemPrimary.opacity(0.18) : Color.systemCard)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Indicators List

    private var indicatorsList: some View {
        VStack(spacing: 14) {
            ForEach(displayedStats) { stat in
                indicatorDetailCard(for: stat)
            }
        }
    }

    private func indicatorDetailCard(for stat: StatType) -> some View {
        let stats = profileManager.profile.stats
        let value = stats[stat] ?? 10
        let growth = selectedTimeframe.growthPoints(for: stat, currentValue: value)
        let associatedQuests = questViewModel.quests(for: stat)

        return VStack(alignment: .leading, spacing: 12) {
            // Stat Header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.systemBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.systemPrimary.opacity(0.6), lineWidth: 1)
                        )

                    Image(systemName: stat.iconSystemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.systemPrimary)
                }
                .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(stat.abbr)
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text(stat.displayName)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Text(stat.habitCategory)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(value)")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("+\(growth) in \(selectedTimeframe.shortTitle)")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }
            }

            // Gameplay Description
            Text(stat.description)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(Color.systemTextSecondary)
                .lineSpacing(2)
                .padding(10)
                .background(Color.systemBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            // Associated Tasks Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.systemPrimary)

                        Text("ASSOCIATED DIRECTIVES (\(associatedQuests.count))")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)
                    }

                    Spacer()

                    let clearedCount = associatedQuests.filter { $0.isCompleted }.count
                    Text("\(clearedCount)/\(associatedQuests.count) CLEARED")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                }

                if associatedQuests.isEmpty {
                    Text("No daily directives currently mapped to this indicator.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary.opacity(0.8))
                        .italic()
                        .padding(.vertical, 6)
                } else {
                    VStack(spacing: 6) {
                        ForEach(associatedQuests) { quest in
                            directiveAssociationRow(for: quest)
                        }
                    }
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 16)
    }

    private func directiveAssociationRow(for quest: DailyQuest) -> some View {
        Button(action: {
            questViewModel.toggleQuestCompletion(id: quest.id)
        }) {
            HStack(spacing: 10) {
                // Interactive Checkbox
                ZStack {
                    Circle()
                        .fill(quest.isCompleted ? Color.systemPrimary : Color.clear)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle().stroke(quest.isCompleted ? Color.systemPrimary : Color.systemBorder, lineWidth: 1.5)
                        )

                    if quest.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(.black)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(quest.title)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(quest.isCompleted ? Color.systemTextSecondary : .white)
                        .strikethrough(quest.isCompleted, color: Color.systemTextSecondary)

                    HStack(spacing: 6) {
                        Text(quest.formattedProgress)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)

                        Text("•")
                            .foregroundColor(Color.systemBorder)

                        Text("+\(quest.expReward) EXP")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text("+\(quest.goldReward) G")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemGateAmber)
                    }
                }

                Spacer()

                if quest.isCompleted {
                    Text("CLEARED")
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.systemPrimary.opacity(0.12))
                        .clipShape(Capsule())
                } else {
                    Button(action: {
                        questViewModel.incrementQuest(id: quest.id)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.systemPrimary)
                            .frame(width: 24, height: 24)
                            .background(Color.systemPrimary.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.systemBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(quest.isCompleted ? Color.systemPrimary.opacity(0.3) : Color.systemBorder.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    IndicatorDetailsModalView()
}
