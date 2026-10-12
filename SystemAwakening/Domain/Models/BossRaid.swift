//
//  BossRaid.swift
//  System: Awakening
//
//  Created for "System: Awakening" (Arise) — Gamified Solo Leveling Productivity App
//

import Foundation

/// Sub-milestone within a major project Boss Battle.
public struct BossMilestone: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var damageAmount: Double
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, damageAmount: Double, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.damageAmount = damageAmount
        self.isCompleted = isCompleted
    }
}

/// Domain model representing major long-term goals or projects gamified as epic Boss Battles.
///
/// **Interview Rationale:**
/// - Bridging Micro-Habits and Macro-Goals: While daily quests handle day-to-day atomic habits,
///   `BossRaid` aggregates focus hours and major deliverables into high-impact RPG climax events.
public struct BossRaid: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var projectTitle: String
    public var bossName: String
    public var totalHP: Double
    public var currentHP: Double
    public var rewardExp: Int
    public var rewardGold: Int
    public var statPillar: StatType
    public var milestones: [BossMilestone]
    public var targetDate: Date

    public init(
        id: UUID = UUID(),
        projectTitle: String,
        bossName: String,
        totalHP: Double = 1000.0,
        currentHP: Double = 1000.0,
        rewardExp: Int = 1500,
        rewardGold: Int = 800,
        statPillar: StatType = .intelligence,
        milestones: [BossMilestone] = [],
        targetDate: Date = Date().addingTimeInterval(86400 * 30) // 30 days
    ) {
        self.id = id
        self.projectTitle = projectTitle
        self.bossName = bossName
        self.totalHP = totalHP
        self.currentHP = currentHP
        self.rewardExp = rewardExp
        self.rewardGold = rewardGold
        self.statPillar = statPillar
        self.milestones = milestones
        self.targetDate = targetDate
    }

    /// Health fraction remaining [0.0 ... 1.0].
    public var healthFraction: Double {
        guard totalHP > 0 else { return 0.0 }
        return min(max(currentHP / totalHP, 0.0), 1.0)
    }

    /// Whether the Boss has been vanquished.
    public var isDefeated: Bool {
        currentHP <= 0
    }

    /// Deals damage to the Boss (e.g. from completing deep work hours or focus sessions).
    public func withDamage(_ amount: Double) -> BossRaid {
        var copy = self
        copy.currentHP = max(copy.currentHP - amount, 0.0)
        return copy
    }

    /// Completes a milestone and deals its associated damage to the Boss.
    public func withCompletedMilestone(id: UUID) -> BossRaid {
        var copy = self
        guard let index = copy.milestones.firstIndex(where: { $0.id == id }) else { return self }
        guard !copy.milestones[index].isCompleted else { return self }

        copy.milestones[index].isCompleted = true
        let damage = copy.milestones[index].damageAmount
        copy.currentHP = max(copy.currentHP - damage, 0.0)
        return copy
    }
}
