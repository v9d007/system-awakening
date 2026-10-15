//
//  DailyQuestViewModelTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

@MainActor
final class DailyQuestViewModelTests: XCTestCase {

    private let storageKey = "system_awakening_daily_quests"
    private var originalData: Data?

    override func setUp() {
        super.setUp()
        originalData = UserDefaults.standard.data(forKey: storageKey)
    }

    override func tearDown() {
        if let originalData {
            UserDefaults.standard.set(originalData, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        super.tearDown()
    }

    func testAddQuestInsertsAtFrontAndPersists() {
        let initialQuests: [DailyQuest] = [
            DailyQuest(title: "Seed Task", statPillar: .strength, targetQuantity: 10, unit: "reps")
        ]
        let viewModel = DailyQuestViewModel(quests: initialQuests)

        let initialCount = viewModel.quests.count

        viewModel.addQuest(
            title: "Custom Reading",
            description: "Read 25 pages of grimoire",
            statPillar: .intelligence,
            targetQuantity: 25,
            unit: "pages",
            expReward: 45,
            reminderTime: Date(),
            isReminderEnabled: true,
            isEssential: true
        )

        XCTAssertEqual(viewModel.quests.count, initialCount + 1)
        XCTAssertEqual(viewModel.quests.first?.title, "Custom Reading")
        XCTAssertEqual(viewModel.quests.first?.statPillar, .intelligence)
        XCTAssertEqual(viewModel.quests.first?.targetQuantity, 25)
        XCTAssertEqual(viewModel.quests.first?.unit, "pages")
        XCTAssertTrue(viewModel.quests.first?.isReminderEnabled ?? false)

        // Verify UserDefaults persistence
        guard let savedData = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([DailyQuest].self, from: savedData) else {
            XCTFail("Quests were not persisted in UserDefaults")
            return
        }

        XCTAssertEqual(decoded.first?.title, "Custom Reading")
    }

    func testDeleteQuestRemovesFromListAndPersists() {
        let questToDelete = DailyQuest(title: "Discardable Objective", statPillar: .vitality, targetQuantity: 5, unit: "L")
        let viewModel = DailyQuestViewModel(quests: [questToDelete])

        XCTAssertEqual(viewModel.quests.count, 1)

        viewModel.deleteQuest(id: questToDelete.id)

        XCTAssertEqual(viewModel.quests.count, 0)

        // Verify persistence reflects deletion
        guard let savedData = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([DailyQuest].self, from: savedData) else {
            XCTFail("Failed to read persisted data")
            return
        }

        XCTAssertEqual(decoded.count, 0)
    }

    func testToggleQuestCompletionUpdatesStatus() {
        let quest = DailyQuest(title: "Push-ups", statPillar: .strength, targetQuantity: 100, currentQuantity: 0, unit: "reps", isCompleted: false)
        let viewModel = DailyQuestViewModel(quests: [quest])

        XCTAssertFalse(viewModel.quests.first?.isCompleted ?? true)

        viewModel.toggleQuestCompletion(id: quest.id)

        XCTAssertTrue(viewModel.quests.first?.isCompleted ?? false)
        XCTAssertEqual(viewModel.quests.first?.currentQuantity, 100)

        viewModel.toggleQuestCompletion(id: quest.id)

        XCTAssertFalse(viewModel.quests.first?.isCompleted ?? true)
    }

    func testDailyQuestDecodableBackwardsCompatibility() throws {
        // Legacy JSON without reminderTime or isReminderEnabled
        let legacyJson = """
        {
            "id": "\(UUID().uuidString)",
            "title": "Legacy Quest",
            "description": "Created prior to v2.5",
            "statPillar": "STR",
            "targetQuantity": 50,
            "currentQuantity": 25,
            "unit": "reps",
            "expReward": 30,
            "goldReward": 10,
            "statPointsReward": 1,
            "isCompleted": false,
            "isEssential": true,
            "deadline": 1728864000
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(DailyQuest.self, from: legacyJson)

        XCTAssertEqual(decoded.title, "Legacy Quest")
        XCTAssertEqual(decoded.statPillar, .strength)
        XCTAssertNil(decoded.reminderTime)
        XCTAssertFalse(decoded.isReminderEnabled)
    }
}
