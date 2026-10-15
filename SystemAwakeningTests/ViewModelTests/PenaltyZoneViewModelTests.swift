//
//  PenaltyZoneViewModelTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

@MainActor
final class PenaltyMockHapticService: HapticServiceProtocol {
    var statAllocatedCallCount = 0
    var questCompletedCallCount = 0
    var levelUpCelebrationCallCount = 0
    var penaltyAlertCallCount = 0
    var selectionTickCallCount = 0

    func statAllocated() { statAllocatedCallCount += 1 }
    func questCompleted() { questCompletedCallCount += 1 }
    func levelUpCelebration() { levelUpCelebrationCallCount += 1 }
    func penaltyAlert() { penaltyAlertCallCount += 1 }
    func selectionTick() { selectionTickCallCount += 1 }
}

@MainActor
final class PenaltyZoneViewModelTests: XCTestCase {

    func testInitialStateAndCountdownFormatting() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        XCTAssertEqual(vm.mode, PenaltyZoneMode.alert)
        XCTAssertEqual(vm.survivalSecondsRemaining, 14382)
        XCTAssertEqual(vm.timeRemainingFormatted, "03:59:42")
        XCTAssertEqual(vm.streakShieldsRemaining, 1)
        XCTAssertEqual(vm.purifiedPotionsRemaining, 1)
        XCTAssertEqual(vm.fatigue, 84.0)
        XCTAssertEqual(vm.hp, 7420)
        XCTAssertEqual(vm.maxHP, 9800)
        XCTAssertEqual(vm.mp, 1150)
        XCTAssertEqual(vm.maxMP, 4200)
    }

    func testBeginSurvivalProtocolTransitionsMode() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        XCTAssertEqual(vm.mode, PenaltyZoneMode.alert)
        vm.beginSurvivalProtocol()

        XCTAssertEqual(vm.mode, PenaltyZoneMode.tacticalGameplay)
        XCTAssertEqual(mockHaptics.penaltyAlertCallCount, 1)
        XCTAssertFalse(vm.systemLogs.isEmpty)
        XCTAssertEqual(vm.systemLogs.first?.tag, "SURVIVAL PROTOCOL")
    }

    func testUseStreakShieldClearsPenalty() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        XCTAssertEqual(vm.streakShieldsRemaining, 1)
        XCTAssertFalse(vm.showEscapeSuccessOverlay)

        vm.useStreakShield()

        XCTAssertEqual(vm.streakShieldsRemaining, 0)
        XCTAssertTrue(vm.showEscapeSuccessOverlay)
        XCTAssertEqual(mockHaptics.levelUpCelebrationCallCount, 1)
    }

    func testPerformDashEvasionIncreasesFatigueAndSetsCooldown() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        let initialFatigue = vm.fatigue
        XCTAssertFalse(vm.isEvasionOnCooldown)

        vm.performDashEvasion()

        XCTAssertEqual(vm.fatigue, initialFatigue + 8.0)
        XCTAssertTrue(vm.isEvasionOnCooldown)
        XCTAssertEqual(mockHaptics.statAllocatedCallCount, 1)
    }

    func testWorkoutExertionProgressAndCompletion() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        XCTAssertEqual(vm.workoutSecondsCompleted, 0)

        // Progress by 5 minutes (300s)
        vm.incrementWorkoutProgress(minutes: 5)
        XCTAssertEqual(vm.workoutSecondsCompleted, 300)
        XCTAssertEqual(vm.workoutProgressText, "5 / 30 MIN")
        XCTAssertFalse(vm.showEscapeSuccessOverlay)

        // Progress to full 30 minutes
        vm.incrementWorkoutProgress(minutes: 25)
        XCTAssertEqual(vm.workoutSecondsCompleted, 1800)
        XCTAssertEqual(vm.workoutProgressText, "30 / 30 MIN")
        XCTAssertTrue(vm.showEscapeSuccessOverlay)
        XCTAssertEqual(mockHaptics.levelUpCelebrationCallCount, 1)
    }

    func testToggleAlarmMute() {
        let mockHaptics = PenaltyMockHapticService()
        let vm = PenaltyZoneViewModel(hapticService: mockHaptics)

        XCTAssertFalse(vm.isAlarmMuted)
        vm.toggleAlarmMute()
        XCTAssertTrue(vm.isAlarmMuted)
        XCTAssertEqual(mockHaptics.selectionTickCallCount, 1)
    }
}
