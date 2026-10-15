//
//  ProfileManagerTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

@MainActor
final class ProfileManagerTests: XCTestCase {

    private let storageKey = "system_awakening_hunter_profile"
    private var originalStoredData: Data?

    override func setUp() {
        super.setUp()
        originalStoredData = UserDefaults.standard.data(forKey: storageKey)
    }

    override func tearDown() {
        if let originalStoredData {
            UserDefaults.standard.set(originalStoredData, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        super.tearDown()
    }

    func testInitialProfileState() {
        let manager = ProfileManager.shared
        let profile = manager.profile

        XCTAssertFalse(profile.name.isEmpty)
        XCTAssertFalse(profile.title.isEmpty)
        XCTAssertFalse(profile.job.isEmpty)
        XCTAssertFalse(profile.bio.isEmpty)
        XCTAssertGreaterThan(profile.level, 0)
        XCTAssertGreaterThanOrEqual(profile.currentExp, 0)
    }

    func testUpdateDetailsMutatesAndPersists() {
        let manager = ProfileManager.shared

        let testName = "Sung Jin-Woo Test"
        let testTitle = "Shadow Monarch Supreme"
        let testJob = "Shadow Lord"
        let testBio = "I am the Monarch of Shadows."

        manager.updateDetails(
            name: testName,
            title: testTitle,
            job: testJob,
            bio: testBio
        )

        XCTAssertEqual(manager.profile.name, testName)
        XCTAssertEqual(manager.profile.title, testTitle)
        XCTAssertEqual(manager.profile.job, testJob)
        XCTAssertEqual(manager.profile.bio, testBio)

        // Verify persisted data in UserDefaults
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(HunterProfile.self, from: data) else {
            XCTFail("Failed to retrieve and decode persisted profile from UserDefaults")
            return
        }

        XCTAssertEqual(decoded.name, testName)
        XCTAssertEqual(decoded.title, testTitle)
        XCTAssertEqual(decoded.job, testJob)
        XCTAssertEqual(decoded.bio, testBio)
    }

    func testAllocateStatReducesUnallocatedPoints() {
        let manager = ProfileManager.shared
        // Ensure there is at least 1 point
        if manager.profile.unallocatedStatPoints == 0 {
            manager.awardExp(10000)
        }

        let initialPoints = manager.profile.unallocatedStatPoints
        let initialStrength = manager.profile.stats[.strength] ?? 10

        manager.allocateStat(type: .strength)

        XCTAssertEqual(manager.profile.unallocatedStatPoints, initialPoints - 1)
        XCTAssertEqual(manager.profile.stats[.strength], initialStrength + 1)
    }

    func testAwardExpTriggersLevelUp() {
        let manager = ProfileManager.shared
        let initialLevel = manager.profile.level

        // Award large EXP to guarantee level-up
        manager.awardExp(50000)

        XCTAssertGreaterThan(manager.profile.level, initialLevel)
    }

    func testHUDTabEnumContainsCanonicalFourTabs() {
        let tabs = HUDTab.allCases
        XCTAssertEqual(tabs.count, 4)
        XCTAssertEqual(tabs, [.home, .tasks, .penalty, .profile])
        XCTAssertEqual(HUDTab.home.rawValue, "HOME")
        XCTAssertEqual(HUDTab.tasks.rawValue, "TASKS")
        XCTAssertEqual(HUDTab.penalty.rawValue, "PENALTY")
        XCTAssertEqual(HUDTab.profile.rawValue, "PROFILE")
    }
}
