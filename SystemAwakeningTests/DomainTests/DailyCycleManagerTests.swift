//
//  DailyCycleManagerTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

@MainActor
final class DailyCycleManagerTests: XCTestCase {

    private let profileStorageKey = "system_awakening_hunter_profile"
    private let questStorageKey = "system_awakening_daily_quests"
    private let dateStorageKey = "system_awakening_last_active_date"

    private var originalProfileData: Data?
    private var originalQuestData: Data?
    private var originalDate: Date?

    override func setUp() {
        super.setUp()
        originalProfileData = UserDefaults.standard.data(forKey: profileStorageKey)
        originalQuestData = UserDefaults.standard.data(forKey: questStorageKey)
        originalDate = UserDefaults.standard.object(forKey: dateStorageKey) as? Date
    }

    override func tearDown() {
        if let originalProfileData {
            UserDefaults.standard.set(originalProfileData, forKey: profileStorageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: profileStorageKey)
        }

        if let originalQuestData {
            UserDefaults.standard.set(originalQuestData, forKey: questStorageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: questStorageKey)
        }

        if let originalDate {
            UserDefaults.standard.set(originalDate, forKey: dateStorageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: dateStorageKey)
        }

        super.tearDown()
    }

    func testNoRolloverOnSameCalendarDay() {
        let manager = DailyCycleManager.shared
        ProfileManager.shared.lastActiveDate = Date()

        let didRollover = manager.checkAndExecuteMidnightRollover(currentDate: Date())

        XCTAssertFalse(didRollover)
    }

    func testMidnightRolloverIncrementsStreakWhenAllEssentialCleared() {
        let manager = DailyCycleManager.shared
        let profile = ProfileManager.shared
        let questVM = DailyQuestViewModel.shared

        // Set last active to yesterday
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date().addingTimeInterval(-86400)
        profile.lastActiveDate = yesterday
        profile.updateStreak(days: 5)
        profile.setPenalty(active: false)

        // Set all essential quests as cleared
        questVM.quests = [
            DailyQuest(title: "Essential 1", statPillar: .strength, targetQuantity: 10, currentQuantity: 10, unit: "reps", isCompleted: true, isEssential: true),
            DailyQuest(title: "Optional 2", statPillar: .intelligence, targetQuantity: 20, currentQuantity: 0, unit: "min", isCompleted: false, isEssential: false)
        ]

        let didRollover = manager.checkAndExecuteMidnightRollover(currentDate: Date())

        XCTAssertTrue(didRollover)
        XCTAssertEqual(profile.profile.currentStreakDays, 6)
        XCTAssertFalse(profile.profile.isPenaltyActive)

        // Verify quests were renewed for the new day
        XCTAssertFalse(questVM.quests[0].isCompleted)
        XCTAssertEqual(questVM.quests[0].currentQuantity, 0.0)
    }

    func testMidnightRolloverActivatesPenaltyWhenEssentialIncomplete() {
        let manager = DailyCycleManager.shared
        let profile = ProfileManager.shared
        let questVM = DailyQuestViewModel.shared

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date().addingTimeInterval(-86400)
        profile.lastActiveDate = yesterday
        profile.setPenalty(active: false)

        // Set an uncompleted essential quest
        questVM.quests = [
            DailyQuest(title: "Failed Essential", statPillar: .strength, targetQuantity: 100, currentQuantity: 20, unit: "reps", isCompleted: false, isEssential: true)
        ]

        let didRollover = manager.checkAndExecuteMidnightRollover(currentDate: Date())

        XCTAssertTrue(didRollover)
        XCTAssertTrue(profile.profile.isPenaltyActive)
    }

    func testRenewDirectivesPreservesCustomUserQuests() {
        let questVM = DailyQuestViewModel.shared

        let customTitle = "Deep Coding Mastery"
        questVM.quests = [
            DailyQuest(title: customTitle, statPillar: .intelligence, targetQuantity: 180, currentQuantity: 180, unit: "min", isCompleted: true, isEssential: true)
        ]

        questVM.renewDirectivesForNewDay(currentDate: Date())

        XCTAssertEqual(questVM.quests.count, 1)
        XCTAssertEqual(questVM.quests.first?.title, customTitle)
        XCTAssertEqual(questVM.quests.first?.currentQuantity, 0.0)
        XCTAssertFalse(questVM.quests.first?.isCompleted ?? true)
    }

    func testFormattedTimeUntilMidnight() {
        let manager = DailyCycleManager.shared
        let formatted = manager.formattedTimeUntilMidnight()

        XCTAssertTrue(formatted.contains("h"))
        XCTAssertTrue(formatted.contains("m"))
        XCTAssertTrue(formatted.contains("s"))
    }
}
