//
//  HunterProgressionTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

final class HunterProgressionTests: XCTestCase {

    func testInitialHunterState() {
        let profile = HunterProfile(name: "Sung Jin-Woo")
        XCTAssertEqual(profile.level, 1)
        XCTAssertEqual(profile.rank, .e)
        XCTAssertEqual(profile.currentExp, 0)
        XCTAssertEqual(profile.gold, 0)
        XCTAssertEqual(profile.unallocatedStatPoints, 0)
        XCTAssertEqual(profile.stats[.strength], 10)
    }

    func testExpRequiredNonLinearScaling() {
        // Level 1: 100 * 1^1.5 = 100
        XCTAssertEqual(HunterProfile.expRequired(for: 1), 100)
        // Level 2: ⌊100 * 2^1.5⌋ = ⌊282.84⌋ = 282
        XCTAssertEqual(HunterProfile.expRequired(for: 2), 282)
        // Level 10: ⌊100 * 10^1.5⌋ = ⌊3162.27⌋ = 3162
        XCTAssertEqual(HunterProfile.expRequired(for: 10), 3162)
    }

    func testSingleLevelUpWithRollover() {
        let initial = HunterProfile(name: "Sung Jin-Woo", level: 1, currentExp: 0)
        // Level 1 requires 100 EXP. Add 140 EXP.
        let result = initial.withGainedExp(amount: 140)

        XCTAssertTrue(result.didLevelUp)
        XCTAssertEqual(result.levelsGained, 1)
        XCTAssertEqual(result.profile.level, 2)
        XCTAssertEqual(result.profile.currentExp, 40) // 140 - 100 = 40 rollover
        XCTAssertEqual(result.profile.unallocatedStatPoints, 3) // 3 stat points earned
    }

    func testMultiLevelUpRollover() {
        let initial = HunterProfile(name: "Sung Jin-Woo", level: 1, currentExp: 0)
        // Level 1 needs 100, Level 2 needs 282. Total = 382.
        // Add 400 EXP. Should reach Level 3 with 18 leftover EXP.
        let result = initial.withGainedExp(amount: 400)

        XCTAssertTrue(result.didLevelUp)
        XCTAssertEqual(result.levelsGained, 2)
        XCTAssertEqual(result.profile.level, 3)
        XCTAssertEqual(result.profile.currentExp, 18)
        XCTAssertEqual(result.profile.unallocatedStatPoints, 6) // 2 * 3 = 6
    }

    func testRankPromotionOnLevelThreshold() {
        let initial = HunterProfile(name: "Sung Jin-Woo", level: 9, currentExp: 0)
        // Level 9 requires ⌊100 * 9^1.5⌋ = 2700 EXP
        let req = HunterProfile.expRequired(for: 9)
        let result = initial.withGainedExp(amount: req)

        XCTAssertEqual(result.profile.level, 10)
        XCTAssertEqual(result.profile.rank, .d) // Promoted to D-Rank at level 10
        XCTAssertEqual(result.profile.rank.canonicalTitle, "Awakened Novice")
    }

    func testGoldEarningAndSpending() {
        var profile = HunterProfile(name: "Sung Jin-Woo", gold: 100)
        profile = profile.withEarnedGold(250)
        XCTAssertEqual(profile.gold, 350)

        // Spend valid amount
        let purchased = profile.withSpentGold(200)
        XCTAssertNotNil(purchased)
        XCTAssertEqual(purchased?.gold, 150)

        // Attempt to spend more than available
        let failedPurchase = purchased?.withSpentGold(500)
        XCTAssertNil(failedPurchase)
    }

    func testStatPointAllocation() {
        var profile = HunterProfile(name: "Sung Jin-Woo")
        profile.unallocatedStatPoints = 3

        let updated = profile.withAllocatedStat(type: .strength, points: 2)
        XCTAssertEqual(updated.unallocatedStatPoints, 1)
        XCTAssertEqual(updated.stats[.strength], 12)

        // Attempting to allocate more than available points should be a no-op
        let invalid = updated.withAllocatedStat(type: .strength, points: 5)
        XCTAssertEqual(invalid.unallocatedStatPoints, 1)
        XCTAssertEqual(invalid.stats[.strength], 12)
    }

    func testDailyQuestCompletionAndProgressFraction() {
        let quest = DailyQuest(
            title: "100 Push-ups",
            statPillar: .strength,
            targetQuantity: 100,
            unit: "reps",
            expReward: 30,
            goldReward: 20
        )

        XCTAssertEqual(quest.progressFraction, 0.0)
        XCTAssertEqual(quest.goldReward, 20)
        XCTAssertFalse(quest.isCompleted)

        let half = quest.withProgress(increment: 50)
        XCTAssertEqual(half.progressFraction, 0.5)
        XCTAssertFalse(half.isCompleted)

        let completed = half.withProgress(increment: 60) // Overflow capped at target
        XCTAssertEqual(completed.progressFraction, 1.0)
        XCTAssertTrue(completed.isCompleted)
        XCTAssertEqual(completed.currentQuantity, 100)
    }

    func testBossRaidDamageAndDefeat() {
        let milestone1 = BossMilestone(title: "Complete Core Modules", damageAmount: 400)
        let milestone2 = BossMilestone(title: "Pass Mock Exams", damageAmount: 600)

        var boss = BossRaid(
            projectTitle: "AWS Cert",
            bossName: "Kargalgan Shaman",
            totalHP: 1000,
            currentHP: 1000,
            milestones: [milestone1, milestone2]
        )

        XCTAssertEqual(boss.healthFraction, 1.0)
        XCTAssertFalse(boss.isDefeated)

        // Complete Milestone 1
        boss = boss.withCompletedMilestone(id: milestone1.id)
        XCTAssertEqual(boss.currentHP, 600)
        XCTAssertEqual(boss.healthFraction, 0.6)
        XCTAssertFalse(boss.isDefeated)

        // Complete Milestone 2
        boss = boss.withCompletedMilestone(id: milestone2.id)
        XCTAssertEqual(boss.currentHP, 0)
        XCTAssertEqual(boss.healthFraction, 0.0)
        XCTAssertTrue(boss.isDefeated)
    }
}
