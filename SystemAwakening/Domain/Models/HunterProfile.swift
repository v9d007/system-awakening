//
//  HunterProfile.swift
//  System: Awakening
//
//  Created for "System: Awakening" (Arise) — Gamified Solo Leveling Productivity App
//

import Foundation

/// Core Domain model representing the Hunter's status sheet.
///
/// **Interview Rationale:**
/// - Non-linear Exponential Curve: Level requirements scale smoothly using `100 * Level^1.5`, avoiding flat linear progressions.
/// - Deterministic Pure State Transitions: All level-up math, stat allocations, and economy mutations (Gold) are pure functions
///   returning new immutable copies, enabling seamless unit testing without state side-effects.
public struct HunterProfile: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var rank: HunterRank
    public var level: Int
    public var currentExp: Int
    public var gold: Int // Gold currency earned from quests & raids, spendable in System Shop
    public var stats: [StatType: Int]
    public var unallocatedStatPoints: Int
    public var currentStreakDays: Int
    public var isPenaltyActive: Bool
    public var fatiguePercentage: Double

    public init(
        id: UUID = UUID(),
        name: String,
        rank: HunterRank = .e,
        level: Int = 1,
        currentExp: Int = 0,
        gold: Int = 0,
        stats: [StatType: Int] = [
            .strength: 10,
            .intelligence: 10,
            .agility: 10,
            .vitality: 10,
            .perception: 10
        ],
        unallocatedStatPoints: Int = 0,
        currentStreakDays: Int = 0,
        isPenaltyActive: Bool = false,
        fatiguePercentage: Double = 0.0
    ) {
        self.id = id
        self.name = name
        self.rank = rank
        self.level = level
        self.currentExp = currentExp
        self.gold = gold
        self.stats = stats
        self.unallocatedStatPoints = unallocatedStatPoints
        self.currentStreakDays = currentStreakDays
        self.isPenaltyActive = isPenaltyActive
        self.fatiguePercentage = fatiguePercentage
    }

    /// EXP threshold required to reach the subsequent level: ⌊100 * Level^1.5⌋.
    public var expRequiredForNextLevel: Int {
        Self.expRequired(for: level)
    }

    /// Static formula for level threshold calculation.
    public static func expRequired(for level: Int) -> Int {
        guard level > 0 else { return 100 }
        return max(100, Int(floor(100.0 * pow(Double(level), 1.5))))
    }

    /// Normalized EXP progression fraction [0.0 ... 1.0].
    public var expProgressPercentage: Double {
        let required = expRequiredForNextLevel
        guard required > 0 else { return 0.0 }
        return min(max(Double(currentExp) / Double(required), 0.0), 1.0)
    }

    /// Evaluates EXP addition, handles multi-level rollovers, grants stat points, and promotes Hunter Rank if eligible.
    public func withGainedExp(amount: Int) -> (profile: HunterProfile, didLevelUp: Bool, levelsGained: Int) {
        guard amount > 0 else { return (self, false, 0) }

        var copy = self
        var remainingExp = copy.currentExp + amount
        var initialLevel = copy.level
        var newLevel = copy.level

        // Carryover loop: Process multi-level rollovers
        while true {
            let required = Self.expRequired(for: newLevel)
            if remainingExp >= required {
                remainingExp -= required
                newLevel += 1
            } else {
                break
            }
        }

        let levelsGained = newLevel - initialLevel
        let didLevelUp = levelsGained > 0

        copy.level = newLevel
        copy.currentExp = remainingExp
        if didLevelUp {
            copy.unallocatedStatPoints += (levelsGained * 3) // 3 stat points per level
            copy.rank = HunterRank.rank(for: newLevel)
        }

        return (copy, didLevelUp, levelsGained)
    }

    /// Adds earned gold to the Hunter's balance.
    public func withEarnedGold(_ amount: Int) -> HunterProfile {
        guard amount > 0 else { return self }
        var copy = self
        copy.gold += amount
        return copy
    }

    /// Attempts to spend gold. Returns `nil` if insufficient funds.
    public func withSpentGold(_ amount: Int) -> HunterProfile? {
        guard amount > 0, gold >= amount else { return nil }
        var copy = self
        copy.gold -= amount
        return copy
    }

    /// Allocates unallocated stat points to a specified attribute.
    public func withAllocatedStat(type: StatType, points: Int = 1) -> HunterProfile {
        guard points > 0, unallocatedStatPoints >= points else { return self }
        var copy = self
        copy.unallocatedStatPoints -= points
        let currentVal = copy.stats[type] ?? 10
        copy.stats[type] = currentVal + points
        return copy
    }

    /// Updates penalty zone active state.
    public func withPenalty(active: Bool) -> HunterProfile {
        var copy = self
        copy.isPenaltyActive = active
        return copy
    }
}
