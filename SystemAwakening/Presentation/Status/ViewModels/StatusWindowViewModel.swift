//
//  StatusWindowViewModel.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// ViewModel managing the Hunter Status Window HUD.
///
/// **Interview Rationale:**
/// - Modern `@Observable` (iOS 17+): Eliminates `@Published` and `ObservableObject` Combine boilerplate.
///   SwiftUI views observing this ViewModel only re-render when the specific properties they access mutate
///   (e.g., updating `gold` will not invalidate the `RadarChartView` observing only `stats`).
/// - Swift 6 Actor Isolation with Default Parameters: Default parameter values in Swift function declarations
///   are evaluated at the call site. Referencing `@MainActor` properties in default arguments can trigger
///   isolation crossing errors. We mark static seed data (`defaultProfile`) as `nonisolated` and provide
///   clean convenience initializers.
/// - Dependency Injection: Accepts a `HapticServiceProtocol` dependency, allowing mock haptic verification in unit tests.
@Observable
@MainActor
public final class StatusWindowViewModel {
    public var profile: HunterProfile
    public var isLoading: Bool
    public var showLevelUpAlert: Bool
    public var lastLevelGained: Int

    private let hapticService: HapticServiceProtocol

    public init(
        profile: HunterProfile,
        hapticService: HapticServiceProtocol
    ) {
        self.profile = profile
        self.isLoading = false
        self.showLevelUpAlert = false
        self.lastLevelGained = 0
        self.hapticService = hapticService
    }

    public convenience init(hapticService: HapticServiceProtocol) {
        self.init(
            profile: Self.defaultProfile,
            hapticService: hapticService
        )
    }

    public convenience init(profile: HunterProfile? = nil) {
        self.init(
            profile: profile ?? Self.defaultProfile,
            hapticService: SystemHaptics.shared
        )
    }

    // MARK: - Computed State Helpers

    public var hunterName: String {
        profile.name
    }

    public var level: Int {
        profile.level
    }

    public var rank: HunterRank {
        profile.rank
    }

    public var gold: Int {
        profile.gold
    }

    public var stats: [StatType: Int] {
        profile.stats
    }

    public var unallocatedPoints: Int {
        profile.unallocatedStatPoints
    }

    public var canAllocateStats: Bool {
        profile.unallocatedStatPoints > 0
    }

    public var expProgress: Double {
        profile.expProgressPercentage
    }

    public var expText: String {
        "\(profile.currentExp) / \(profile.expRequiredForNextLevel) EXP"
    }

    public var expPercentageText: String {
        let percent = Int(expProgress * 100)
        return "\(percent)%"
    }

    // MARK: - User Intents / Actions

    /// Allocates an available stat point to the specified attribute.
    public func allocateStat(type: StatType) {
        guard canAllocateStats else { return }

        profile = profile.withAllocatedStat(type: type, points: 1)
        hapticService.statAllocated()
    }

    /// Awards EXP (e.g. from completed quests or focus blocks), triggering celebrations on level up.
    public func awardExp(_ amount: Int) {
        guard amount > 0 else { return }

        let result = profile.withGainedExp(amount: amount)
        self.profile = result.profile

        if result.didLevelUp {
            self.lastLevelGained = result.levelsGained
            self.showLevelUpAlert = true
            hapticService.levelUpCelebration()
        }
    }

    // MARK: - Default Seed Data (nonisolated for safe concurrent access)

    public nonisolated static var defaultProfile: HunterProfile {
        HunterProfile(
            name: "Sung Jin-Woo",
            rank: .d,
            level: 24,
            currentExp: 7450,
            gold: 1450,
            stats: [
                .strength: 45,
                .intelligence: 62,
                .agility: 38,
                .vitality: 50,
                .perception: 35
            ],
            unallocatedStatPoints: 3,
            currentStreakDays: 14
        )
    }
}
