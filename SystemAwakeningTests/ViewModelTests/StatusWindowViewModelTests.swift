//
//  StatusWindowViewModelTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

@MainActor
final class MockHapticService: HapticServiceProtocol {
    var statAllocatedCallCount = 0
    var questCompletedCallCount = 0
    var levelUpCelebrationCallCount = 0
    var penaltyAlertCallCount = 0
    var selectionTickCallCount = 0

    func statAllocated() {
        statAllocatedCallCount += 1
    }

    func questCompleted() {
        questCompletedCallCount += 1
    }

    func levelUpCelebration() {
        levelUpCelebrationCallCount += 1
    }

    func penaltyAlert() {
        penaltyAlertCallCount += 1
    }

    func selectionTick() {
        selectionTickCallCount += 1
    }
}

@MainActor
final class StatusWindowViewModelTests: XCTestCase {

    func testInitialState() {
        let mockHaptics = MockHapticService()
        let vm = StatusWindowViewModel(hapticService: mockHaptics)

        XCTAssertEqual(vm.hunterName, "Sung Jin-Woo")
        XCTAssertEqual(vm.level, 24)
        XCTAssertEqual(vm.rank, HunterRank.d)
        XCTAssertEqual(vm.gold, 1450)
        XCTAssertEqual(vm.unallocatedPoints, 3)
        XCTAssertTrue(vm.canAllocateStats)
    }

    func testAllocateStatSuccess() {
        let mockHaptics = MockHapticService()
        let vm = StatusWindowViewModel(hapticService: mockHaptics)

        let initialStrength = vm.stats[StatType.strength] ?? 10
        let initialPoints = vm.unallocatedPoints

        vm.allocateStat(type: .strength)

        XCTAssertEqual(vm.stats[StatType.strength], initialStrength + 1)
        XCTAssertEqual(vm.unallocatedPoints, initialPoints - 1)
        XCTAssertEqual(mockHaptics.statAllocatedCallCount, 1)
    }

    func testAllocateStatDepletedPoints() {
        let mockHaptics = MockHapticService()
        var profile = StatusWindowViewModel.defaultProfile
        profile.unallocatedStatPoints = 0
        let vm = StatusWindowViewModel(profile: profile, hapticService: mockHaptics)

        XCTAssertFalse(vm.canAllocateStats)
        let initialAgility = vm.stats[StatType.agility] ?? 10

        vm.allocateStat(type: .agility)

        // Must remain unchanged
        XCTAssertEqual(vm.stats[StatType.agility], initialAgility)
        XCTAssertEqual(vm.unallocatedPoints, 0)
        XCTAssertEqual(mockHaptics.statAllocatedCallCount, 0)
    }

    func testAwardExpTriggersLevelUpAndCelebration() {
        let mockHaptics = MockHapticService()
        let profile = HunterProfile(name: "Sung Jin-Woo", level: 1, currentExp: 0, unallocatedStatPoints: 0)
        let vm = StatusWindowViewModel(profile: profile, hapticService: mockHaptics)

        // Level 1 needs 100 EXP. Award 150 EXP.
        vm.awardExp(150)

        XCTAssertEqual(vm.level, 2)
        XCTAssertEqual(vm.unallocatedPoints, 3)
        XCTAssertTrue(vm.showLevelUpAlert)
        XCTAssertEqual(vm.lastLevelGained, 1)
        XCTAssertEqual(mockHaptics.levelUpCelebrationCallCount, 1)
    }
}
