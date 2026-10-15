//
//  ProfileManager.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// Centralized state manager for the Hunter's profile and progression state.
///
/// **Interview Rationale:**
/// - Single Source of Truth: Ensures profile updates in the Profile tab immediately propagate
///   to the Home dashboard without stale state or complex event buses.
/// - Swift 6 Strict Concurrency: Fully `@MainActor`-isolated and `@Observable`, guaranteeing safe mutations.
/// - Persistence: Automatically persists profile state to `UserDefaults` in JSON format.
@Observable
@MainActor
public final class ProfileManager {
    public static let shared = ProfileManager()

    private static let storageKey = "system_awakening_hunter_profile"

    public var profile: HunterProfile {
        didSet {
            saveToStorage()
        }
    }

    public var lastLevelGained: Int = 0
    public var showLevelUpAlert: Bool = false

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let savedProfile = try? JSONDecoder().decode(HunterProfile.self, from: data) {
            self.profile = savedProfile
        } else {
            self.profile = HunterProfile(
                name: "Sung Jin-Woo",
                title: "Shadow Monarch",
                job: "Necromancer",
                bio: "Arise. Level up every day without hesitation.",
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

    // MARK: - Mutations

    /// Updates hunter identity attributes (name, title, job, bio).
    public func updateDetails(name: String, title: String, job: String, bio: String) {
        self.profile = profile.withUpdatedDetails(name: name, title: title, job: job, bio: bio)
        SystemHaptics.shared.selectionTick()
    }

    /// Allocates an available stat point to a chosen attribute.
    public func allocateStat(type: StatType) {
        guard profile.unallocatedStatPoints > 0 else { return }
        self.profile = profile.withAllocatedStat(type: type, points: 1)
        SystemHaptics.shared.statAllocated()
    }

    /// Atomically commits draft stat allocations and unallocated points.
    public func commitStats(stats: [StatType: Int], unallocated: Int) {
        var copy = profile
        copy.stats = stats
        copy.unallocatedStatPoints = unallocated
        self.profile = copy
        SystemHaptics.shared.levelUpCelebration()
    }

    /// Awards EXP, updating level and rank if a threshold is crossed.
    public func awardExp(_ amount: Int) {
        guard amount > 0 else { return }
        let result = profile.withGainedExp(amount: amount)
        self.profile = result.profile
        if result.didLevelUp {
            self.lastLevelGained = result.levelsGained
            self.showLevelUpAlert = true
            SystemHaptics.shared.levelUpCelebration()
        }
    }

    /// Updates gold balance.
    public func addGold(_ amount: Int) {
        self.profile = profile.withEarnedGold(amount)
    }

    /// Spends gold if sufficient funds exist. Returns true on success.
    public func spendGold(_ amount: Int) -> Bool {
        if let updated = profile.withSpentGold(amount) {
            self.profile = updated
            return true
        }
        return false
    }

    /// Updates the penalty active state.
    public func setPenalty(active: Bool) {
        self.profile = profile.withPenalty(active: active)
    }

    /// Increments the current streak days count.
    public func incrementStreak() {
        self.profile = profile.withStreak(days: profile.currentStreakDays + 1)
        SystemHaptics.shared.levelUpCelebration()
    }

    /// Resets the hunter streak to zero.
    public func resetStreak() {
        self.profile = profile.withStreak(days: 0)
    }

    /// Updates streak to explicit day count.
    public func updateStreak(days: Int) {
        self.profile = profile.withStreak(days: days)
    }

    /// Persistent tracking of the last active calendar date.
    public var lastActiveDate: Date {
        get {
            UserDefaults.standard.object(forKey: "system_awakening_last_active_date") as? Date ?? Date()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "system_awakening_last_active_date")
        }
    }

    // MARK: - Persistence Helper

    private func saveToStorage() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
