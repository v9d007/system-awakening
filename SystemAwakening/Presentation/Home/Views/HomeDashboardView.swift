//
//  HomeDashboardView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// The central Home Dashboard screen faithfully implementing the 1:1 Stitch UI specification:
/// 1. Mini HUD Status Beacon (Hunter Rank, Level, Telemetry)
/// 2. Matrix Pentagram Card:
///    - Header with atom icon, title, 'INDICATORS' inspection button, and 'SYNC: OPTIMAL' badge
///    - Timeframe Selector: WEEKLY, MONTHLY, YEARLY graph progress selection
///    - 5-Point Radar Chart Canvas with glowing nodes
///    - Telemetry Growth Summary & Combat Class / PWR footer
/// 3. System Alert Banner (Unallocated stat points indicator & PTS badge)
/// 4. 5 Stat Allocation Rows (STR, AGI, INT, VIT, PER - tapping opens indicator details & associated tasks)
/// 5. Dual Action Buttons (AUTO-ALLOCATE and glowing CONFIRM)
/// 6. Daily Directives Clearance Hub with **Expanded 4 Current or Past Tasks** (with live completion & progress controls)
/// 7. Penalty Zone Protocol Card (Dimensional survival emergency entry)
@MainActor
public struct HomeDashboardView: View {
    @State private var profileManager = ProfileManager.shared
    @State private var questViewModel = DailyQuestViewModel.shared
    @State private var showPenaltyZone = false
    @State private var showCreateQuestSheet: Bool = false

    // Timeframe & Indicator Inspection state
    @State private var selectedTimeframe: StatProgressTimeframe = .weekly
    @State private var showIndicatorDetailsSheet: Bool = false
    @State private var selectedStatForInspection: StatType? = nil

    // Draft stat allocation state
    @State private var draftStats: [StatType: Int] = [:]
    @State private var draftUnallocated: Int = 0
    @State private var hasPendingAllocations: Bool = false
    @State private var showConfirmToast: Bool = false

    public var onNavigateToTasks: (() -> Void)?
    public var onNavigateToPenalty: (() -> Void)?

    public init(onNavigateToTasks: (() -> Void)? = nil, onNavigateToPenalty: (() -> Void)? = nil) {
        self.onNavigateToTasks = onNavigateToTasks
        self.onNavigateToPenalty = onNavigateToPenalty
    }

    private var currentStats: [StatType: Int] {
        draftStats.isEmpty ? profileManager.profile.stats : draftStats
    }

    private var currentUnallocated: Int {
        draftStats.isEmpty ? profileManager.profile.unallocatedStatPoints : draftUnallocated
    }

    private var totalPower: Int {
        currentStats.values.reduce(0, +)
    }

    private var isSolarTheme: Bool {
        ThemeManager.shared.currentTheme == .solarSovereign
    }

    private var combatClassTitle: String {
        isSolarTheme ? "SOLAR ARCH-MAGE" : "MAGE / ASSASSIN HYBRID"
    }

    private var matrixHeaderTitle: String {
        isSolarTheme ? "SOLAR PENTAGRAM" : "MATRIX PENTAGRAM"
    }

    private var alertColor: Color {
        isSolarTheme ? Color(hex: "F59E0B") : Color.systemPrimary
    }

    public var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerView
                    matrixPentagramCard
                    systemAlertBanner
                    statAllocationSection
                    bottomActionButtons
                    taskProgressCard
                    penaltyZoneEntryCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110) // Safe area breathing room above floating tab dock
            }
            .scrollIndicators(.hidden)

            // Confirmation Toast
            if showConfirmToast {
                VStack {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(Color.systemPrimary)

                        Text("ATTRIBUTES COMMITTED // SYNC OPTIMAL")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.systemCard.opacity(0.96))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemPrimary, lineWidth: 1.2)
                    )
                    .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 8)
                    .padding(.top, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))

                    Spacer()
                }
            }

            // Floating Action Button (FAB) for issuing new directives (bottom-right)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingAddDirectiveButton
                        .padding(.trailing, 20)
                        .padding(.bottom, 94)
                }
            }
        }
        .onAppear {
            syncDraftIfNeeded()
        }
        .onChange(of: profileManager.profile) { _, _ in
            if !hasPendingAllocations {
                syncDraftIfNeeded()
            }
        }
        .sheet(isPresented: $showIndicatorDetailsSheet) {
            IndicatorDetailsModalView(
                initialStat: selectedStatForInspection,
                timeframe: selectedTimeframe
            )
        }
        .sheet(isPresented: $showCreateQuestSheet) {
            CreateQuestModalView()
        }
        .fullScreenCover(isPresented: $showPenaltyZone) {
            PenaltyZoneView()
        }
    }

    // MARK: - Floating Add Directive Button

    private var floatingAddDirectiveButton: some View {
        Button(action: {
            showCreateQuestSheet = true
            SystemHaptics.shared.selectionTick()
        }) {
            ZStack {
                Circle()
                    .fill(Color.systemCard)
                    .frame(width: 52, height: 52)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)

                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.black)
            }
            .overlay(
                Circle()
                    .stroke(Color.systemPrimary, lineWidth: 1.5)
            )
            .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 10, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - 1. Mini HUD Status Header

    private var headerView: some View {
        let profile = profileManager.profile

        return HStack(alignment: .center) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemPrimary)
                    .frame(width: 7, height: 7)
                    .shadow(color: Color.systemPrimaryGlow, radius: 4)

                Text("SYSTEM HUD // ACTIVE TELEMETRY")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)
            }

            Spacer()

            HStack(spacing: 6) {
                RankBadgeView(rank: profile.rank, showTitle: false, size: .small)

                Text("LVL \(profile.level)")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.systemCard)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemBorder, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - 2. Matrix Pentagram Card (Stitch 1:1 + Timeframe + Indicator Inspector)

    private var matrixPentagramCard: some View {
        VStack(spacing: 12) {
            // Card Header: Title + Inspect Indicator Action + Sync Optimal Badge
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "atom")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.systemPrimary)

                    Text(matrixHeaderTitle)
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(1.2)
                }

                Spacer()

                HStack(spacing: 8) {
                    // Indicator Details & Associated Tasks Button (fixed size prevents line breaks)
                    Button(action: {
                        selectedStatForInspection = nil
                        showIndicatorDetailsSheet = true
                        SystemHaptics.shared.selectionTick()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 9, weight: .bold))
                            Text("INDICATORS")
                                .font(.system(size: 8.5, weight: .black, design: .monospaced))
                        }
                        .foregroundColor(Color.systemPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.systemPrimary.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .fixedSize()

                    // Capsule Badge: SYNC: OPTIMAL
                    Text("SYNC: OPTIMAL")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.systemPrimary.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                        )
                        .fixedSize()
                }
            }
            .padding(.horizontal, 4)

            // Weekly, Monthly, Yearly Timeframe Selector (Subtle HUD styling)
            HStack(spacing: 6) {
                ForEach(StatProgressTimeframe.allCases) { timeframe in
                    let isSelected = selectedTimeframe == timeframe

                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedTimeframe = timeframe
                        }
                        SystemHaptics.shared.selectionTick()
                    }) {
                        Text(timeframe.shortTitle)
                            .font(.system(size: 9, weight: isSelected ? .black : .bold, design: .monospaced))
                            .foregroundColor(isSelected ? Color.systemPrimary : Color.systemTextSecondary.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .background(isSelected ? Color.systemPrimary.opacity(0.18) : Color.systemBackground.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? Color.systemPrimary : Color.systemBorder.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 2)

            // Radar Chart Canvas (Large, commanding 300pt height matching Stitch proportions)
            RadarChartView(
                stats: selectedTimeframe.adjustedStats(currentStats: currentStats),
                maxStatValue: 100,
                unallocatedPoints: currentUnallocated
            )
            .frame(height: 300)
            .padding(.vertical, 2)

            // Divider Line
            Rectangle()
                .fill(Color.systemBorder.opacity(0.6))
                .frame(height: 1)
                .padding(.horizontal, 2)

            // Card Footer: Combat Class & Power Rating with Growth Delta
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    Text("Combat Class:")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)

                    Text(combatClassTitle)
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("PWR :")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)

                    Text("\(totalPower)")
                        .font(.system(size: 12, weight: .heavy, design: .monospaced))
                        .foregroundColor(.white)

                    let delta = selectedTimeframe.totalGrowth(stats: currentStats)
                    if delta > 0 {
                        Text("(+\(delta))")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color.systemCard.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.systemPrimary.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 6, y: 3)
    }

    // MARK: - 3. System Alert Banner (Stitch 1:1)

    private var systemAlertBanner: some View {
        HStack(spacing: 12) {
            // Left Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.systemBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(alertColor.opacity(0.5), lineWidth: 1)
                    )

                Image(systemName: "cube.transparent.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(alertColor)
            }
            .frame(width: 40, height: 40)

            // Center Details
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(alertColor)
                        .frame(width: 5, height: 5)

                    Text("SYSTEM ALERT")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(alertColor)
                }

                Text(currentUnallocated > 0 ? "\(currentUnallocated) Unallocated Stat Points" : "All Stat Points Allocated")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }

            Spacer()

            // Right Glowing Pill Badge
            if currentUnallocated > 0 {
                Text("+\(currentUnallocated) PTS")
                    .font(.system(size: 11, weight: .heavy, design: .monospaced))
                    .foregroundColor(isSolarTheme ? .black : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.systemPrimary)
                    .clipShape(Capsule())
                    .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 6)
            } else {
                Text("OPTIMAL")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.systemPrimary.opacity(0.14))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(12)
        .background(Color.systemCard.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(alertColor.opacity(0.35), lineWidth: 1)
        )
    }

    // MARK: - 4. 5 Stat Allocation Rows (Stitch 1:1: STR, AGI, INT, VIT, PER)

    private var statAllocationSection: some View {
        VStack(spacing: 10) {
            ForEach(StatType.rowOrderedStats) { stat in
                statRow(for: stat)
            }
        }
    }

    private func statRow(for stat: StatType) -> some View {
        let value = currentStats[stat] ?? 10
        let progressRatio = min(max(Double(value) / 100.0, 0.0), 1.0)
        let canAllocate = currentUnallocated > 0

        return HStack(spacing: 12) {
            // Icon Box (Tapping opens indicator details & associated tasks)
            Button(action: {
                selectedStatForInspection = stat
                showIndicatorDetailsSheet = true
                SystemHaptics.shared.selectionTick()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.systemBackground.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.systemBorder.opacity(0.6), lineWidth: 1)
                        )

                    Image(systemName: stat.iconSystemName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.systemPrimary)
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            // Title & Mini Progress Bar (Tapping opens indicator details)
            Button(action: {
                selectedStatForInspection = stat
                showIndicatorDetailsSheet = true
                SystemHaptics.shared.selectionTick()
            }) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(stat.abbr)
                            .font(.system(size: 12, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text(stat.displayName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)

                        Image(systemName: "info.circle")
                            .font(.system(size: 9))
                            .foregroundColor(Color.systemTextSecondary.opacity(0.6))
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.systemBorder.opacity(0.4))

                            Capsule()
                                .fill(Color.systemPrimary)
                                .frame(width: max(geo.size.width * progressRatio, 4))
                        }
                    }
                    .frame(height: 3)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Stat Value
            Text("\(value)")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            // Quick '+' Allocation Button
            Button(action: {
                handleIncrement(stat: stat)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(canAllocate ? Color.systemPrimary.opacity(0.18) : Color.systemCard.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(canAllocate ? Color.systemPrimary : Color.systemBorder.opacity(0.4), lineWidth: 1)
                        )

                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(canAllocate ? Color.systemPrimary : Color.systemTextSecondary.opacity(0.3))
                }
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!canAllocate)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.systemCard.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.systemBorder.opacity(0.7), lineWidth: 1)
        )
    }

    // MARK: - 5. Bottom Dual Action Buttons (Stitch 1:1)

    private var bottomActionButtons: some View {
        HStack(spacing: 12) {
            // AUTO-ALLOCATE Button
            Button(action: handleAutoAllocate) {
                HStack(spacing: 6) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 12, weight: .bold))
                    Text("AUTO-ALLOCATE")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                }
                .foregroundColor(currentUnallocated > 0 ? Color.systemPrimary : Color.systemTextSecondary.opacity(0.5))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.systemCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(currentUnallocated > 0 ? Color.systemPrimary.opacity(0.7) : Color.systemBorder, lineWidth: 1.2)
                )
            }
            .buttonStyle(.plain)
            .disabled(currentUnallocated == 0)

            // CONFIRM Button
            Button(action: handleConfirm) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("CONFIRM")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                }
                .foregroundColor(isSolarTheme ? .black : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(hasPendingAllocations ? Color.systemPrimary : Color.systemPrimary.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: hasPendingAllocations ? Color.systemPrimaryGlow.opacity(0.65) : .clear, radius: 8)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - 6. Daily Directives Clearance Hub with Expanded 4 Tasks

    private var taskProgressCard: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(Color.systemPrimary)

                    Text("DAILY DIRECTIVES CLEARANCE")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Spacer()

                // Quick Add Directive Shortcut
                Button(action: {
                    showCreateQuestSheet = true
                    SystemHaptics.shared.selectionTick()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "plus")
                            .font(.system(size: 8, weight: .black))
                        Text("ADD")
                            .font(.system(size: 8.5, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.systemPrimary.opacity(0.12))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1))
                }
                .buttonStyle(.plain)

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 9))
                    Text(questViewModel.timeRemainingFormatted)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                }
                .foregroundColor(Color.systemTextSecondary)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(questViewModel.completedCount) of \(questViewModel.totalCount) Directives Fulfilled")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)

                    Text(questViewModel.allCompleted ? "Penalty Evasion Guaranteed • All Objectives Cleared" : "Penalty Evasion Active • Reset at 00:00")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                }

                Spacer()

                Text(questViewModel.completionPercentageText)
                    .font(.system(size: 20, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.systemCard)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * questViewModel.completionFraction, 8))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: questViewModel.completionFraction)
                }
            }
            .frame(height: 8)

            // Expanded Current / Past 4 Tasks
            VStack(spacing: 8) {
                ForEach(questViewModel.quests.prefix(4)) { quest in
                    taskInlineRow(for: quest)
                }
            }
            .padding(.top, 4)

            // Direct Jump to Tasks Tab
            Button(action: {
                onNavigateToTasks?()
            }) {
                HStack(spacing: 6) {
                    Text("VIEW FULL DIRECTIVES LOG & REWARDS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(Color.systemPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color.systemCard.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8).stroke(Color.systemBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .padding(.top, 2)
        }
        .padding(16)
        .holographicCard(cornerRadius: 16)
    }

    private func taskInlineRow(for quest: DailyQuest) -> some View {
        Button(action: {
            questViewModel.toggleQuestCompletion(id: quest.id)
        }) {
            HStack(spacing: 12) {
                // Interactive Checkbox
                ZStack {
                    Circle()
                        .fill(quest.isCompleted ? Color.systemPrimary : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle().stroke(quest.isCompleted ? Color.systemPrimary : Color.systemBorder, lineWidth: 1.5)
                        )

                    if quest.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .black))
                            .foregroundColor(.black)
                    }
                }

                // Task Details
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(quest.title)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(quest.isCompleted ? Color.systemTextSecondary : .white)
                            .strikethrough(quest.isCompleted, color: Color.systemTextSecondary)

                        // Associated Stat Badge
                        Text(quest.statPillar.abbr)
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Color.systemPrimary.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    HStack(spacing: 8) {
                        Text(quest.formattedProgress)
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)

                        Text("•")
                            .foregroundColor(Color.systemBorder)

                        Text("+\(quest.expReward) EXP")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        if quest.isReminderEnabled, let reminderTime = quest.reminderTime {
                            Text("•")
                                .foregroundColor(Color.systemBorder)

                            HStack(spacing: 3) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 8))
                                Text(reminderTime, style: .time)
                                    .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            }
                            .foregroundColor(Color.systemPrimary)
                        }
                    }
                }

                Spacer()

                // Quick increment or completed badge
                if quest.isCompleted {
                    Text("CLEARED")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.systemPrimary.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                        )
                } else {
                    Button(action: {
                        questViewModel.incrementQuest(id: quest.id)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.systemPrimary)
                            .frame(width: 28, height: 28)
                            .background(Color.systemPrimary.opacity(0.12))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(Color.systemBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(quest.isCompleted ? Color.systemPrimary.opacity(0.3) : Color.systemBorder.opacity(0.6), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - 7. Penalty Zone Protocol Entry Card

    private var penaltyZoneEntryCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.systemPenaltyCrimson.opacity(0.18))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Circle().stroke(Color.systemPenaltyCrimson.opacity(0.8), lineWidth: 1.5)
                        )

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.systemPenaltyCrimson)
                        .shadow(color: .systemPenaltyCrimson.opacity(0.8), radius: 6)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("[DIMENSIONAL PROTOCOL]")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.systemPenaltyCrimson)

                        Spacer()

                        Text("DISASTER RANK")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .foregroundColor(.systemPenaltyCrimson)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.systemPenaltyCrimson.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Text("PENALTY ZONE SURVIVAL")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)

                    Text("Extreme endurance survival protocol & hostile proximity evasion.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                        .lineLimit(2)
                }
            }

            Button(action: {
                if let onNavigateToPenalty = onNavigateToPenalty {
                    onNavigateToPenalty()
                } else {
                    showPenaltyZone = true
                }
                SystemHaptics.shared.selectionTick()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("ENTER PENALTY PROTOCOL")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.systemPenaltyCrimson.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .systemPenaltyCrimson.opacity(0.5), radius: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .holographicCard(cornerRadius: 16, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    // MARK: - Actions & Mutations

    private func syncDraftIfNeeded() {
        draftStats = profileManager.profile.stats
        draftUnallocated = profileManager.profile.unallocatedStatPoints
        hasPendingAllocations = false
    }

    private func handleIncrement(stat: StatType) {
        guard currentUnallocated > 0 else { return }
        if draftStats.isEmpty {
            syncDraftIfNeeded()
        }

        draftStats[stat, default: 10] += 1
        draftUnallocated -= 1
        hasPendingAllocations = true
        SystemHaptics.shared.statAllocated()
    }

    private func handleAutoAllocate() {
        guard currentUnallocated > 0 else { return }
        if draftStats.isEmpty {
            syncDraftIfNeeded()
        }

        // Distribute unallocated points according to combat class priority: INT -> STR -> AGI -> VIT -> PER
        let priorityOrder: [StatType] = [.intelligence, .strength, .agility, .vitality, .perception]
        var pIdx = 0
        while draftUnallocated > 0 {
            let stat = priorityOrder[pIdx % priorityOrder.count]
            draftStats[stat, default: 10] += 1
            draftUnallocated -= 1
            pIdx += 1
        }
        hasPendingAllocations = true
        SystemHaptics.shared.selectionTick()
    }

    private func handleConfirm() {
        if hasPendingAllocations {
            profileManager.commitStats(stats: draftStats, unallocated: draftUnallocated)
            hasPendingAllocations = false
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                showConfirmToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    showConfirmToast = false
                }
            }
        } else {
            SystemHaptics.shared.selectionTick()
        }
    }
}

#Preview {
    HomeDashboardView()
}
