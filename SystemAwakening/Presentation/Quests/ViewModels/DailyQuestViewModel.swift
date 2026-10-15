//
//  DailyQuestViewModel.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// ViewModel managing the Daily Quest Log, local persistence, offline reminders, and progression loop.
@Observable
@MainActor
public final class DailyQuestViewModel {
    public var quests: [DailyQuest] {
        didSet {
            saveQuestsToStorage()
        }
    }
    public var timeRemainingFormatted: String
    public var showClaimAlert: Bool
    public var claimedExp: Int
    public var claimedGold: Int

    private let hapticService: HapticServiceProtocol
    private let notificationService: SystemNotificationServiceProtocol

    private static let storageKey = "system_awakening_daily_quests"

    public static let shared = DailyQuestViewModel()

    public init(
        quests: [DailyQuest]?,
        hapticService: HapticServiceProtocol,
        notificationService: SystemNotificationServiceProtocol
    ) {
        self.hapticService = hapticService
        self.notificationService = notificationService
        self.showClaimAlert = false
        self.claimedExp = 0
        self.claimedGold = 0

        // Calculate dynamic initial time remaining until midnight
        let now = Date()
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        let remaining = max(Int(endOfDay.timeIntervalSince(now)), 0)
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        self.timeRemainingFormatted = String(format: "%02dh %02dm %02ds", h, m, s)

        if let explicitQuests = quests {
            self.quests = explicitQuests
        } else if let savedData = UserDefaults.standard.data(forKey: Self.storageKey),
                  let decoded = try? JSONDecoder().decode([DailyQuest].self, from: savedData),
                  !decoded.isEmpty {
            self.quests = decoded
        } else {
            self.quests = Self.defaultQuests
            // Persist the default seed on first run
            if let encoded = try? JSONEncoder().encode(Self.defaultQuests) {
                UserDefaults.standard.set(encoded, forKey: Self.storageKey)
            }
        }
    }

    public convenience init(quests: [DailyQuest]? = nil) {
        self.init(
            quests: quests,
            hapticService: SystemHaptics.shared,
            notificationService: SystemNotificationService.shared
        )
    }

    // MARK: - Local Persistence

    public func saveQuestsToStorage() {
        if let encoded = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(encoded, forKey: Self.storageKey)
        }
    }

    // MARK: - User Directive CRUD Operations

    /// Creates and persists a new user-defined directive, scheduling offline reminders if enabled.
    public func addQuest(
        title: String,
        description: String = "",
        statPillar: StatType,
        targetQuantity: Double,
        unit: String,
        expReward: Int = 30,
        reminderTime: Date? = nil,
        isReminderEnabled: Bool = false,
        isEssential: Bool = true
    ) {
        let newQuest = DailyQuest(
            id: UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            statPillar: statPillar,
            targetQuantity: max(targetQuantity, 1.0),
            currentQuantity: 0.0,
            unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
            expReward: expReward,
            goldReward: 0,
            statPointsReward: 1,
            isCompleted: false,
            isEssential: isEssential,
            reminderTime: reminderTime,
            isReminderEnabled: isReminderEnabled
        )

        // Insert at the front so the hunter sees their new directive immediately
        quests.insert(newQuest, at: 0)

        if isReminderEnabled {
            Task {
                await notificationService.scheduleQuestReminder(for: newQuest)
            }
        }

        hapticService.statAllocated()
    }

    /// Deletes a directive and cancels any scheduled notification.
    public func deleteQuest(id: UUID) {
        notificationService.cancelQuestReminder(for: id)
        quests.removeAll { $0.id == id }
        hapticService.selectionTick()
    }

    /// Updates an existing directive and refreshes notifications.
    public func updateQuest(_ updated: DailyQuest) {
        guard let index = quests.firstIndex(where: { $0.id == updated.id }) else { return }
        quests[index] = updated

        if updated.isReminderEnabled {
            Task {
                await notificationService.scheduleQuestReminder(for: updated)
            }
        } else {
            notificationService.cancelQuestReminder(for: updated.id)
        }
    }

    // MARK: - Computed Properties

    public var completedCount: Int {
        quests.filter { $0.isCompleted }.count
    }

    public var totalCount: Int {
        quests.count
    }

    public var completionFraction: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }

    public var completionPercentageText: String {
        "\(Int(completionFraction * 100))%"
    }

    public var allCompleted: Bool {
        totalCount > 0 && completedCount == totalCount
    }

    public var pendingExp: Int {
        quests.filter { $0.isCompleted }.reduce(0) { $0 + $1.expReward }
    }

    public var pendingGold: Int {
        quests.filter { $0.isCompleted }.reduce(0) { $0 + $1.goldReward }
    }

    // MARK: - User Progression Actions

    public func incrementQuest(id: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        var quest = quests[index]

        let incrementAmount: Double
        switch quest.statPillar {
        case .strength:
            incrementAmount = max(quest.targetQuantity * 0.25, 1)
        case .intelligence:
            incrementAmount = max(quest.targetQuantity * 0.25, 1)
        case .agility:
            incrementAmount = max(quest.targetQuantity * 0.2, 1)
        default:
            incrementAmount = 1
        }

        quest = quest.withProgress(increment: incrementAmount)
        quests[index] = quest

        if quest.isCompleted {
            hapticService.questCompleted()
        } else {
            hapticService.statAllocated()
        }
    }

    public func claimRewards() {
        guard allCompleted else { return }

        let expToAward = pendingExp
        self.claimedExp = expToAward
        self.claimedGold = pendingGold
        self.showClaimAlert = true

        // Award EXP to Hunter Profile
        ProfileManager.shared.awardExp(expToAward)
        hapticService.levelUpCelebration()
    }

    public func toggleQuestCompletion(id: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == id }) else { return }
        let current = quests[index]
        let newStatus = !current.isCompleted
        quests[index] = current.withCompletion(newStatus)
        if newStatus {
            hapticService.questCompleted()
        } else {
            hapticService.selectionTick()
        }
    }

    public func quests(for stat: StatType) -> [DailyQuest] {
        quests.filter { $0.statPillar == stat }
    }

    // MARK: - Daily Rollover & Dynamic Countdown

    /// Renews directives for the new calendar day, resetting progress while preserving all user-created custom tasks.
    public func renewDirectivesForNewDay(currentDate: Date = Date()) {
        let calendar = Calendar.current
        let newDeadline = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: currentDate)
            ?? currentDate.addingTimeInterval(86399)

        for index in quests.indices {
            quests[index].currentQuantity = 0.0
            quests[index].isCompleted = false
            quests[index].deadline = newDeadline
        }

        saveQuestsToStorage()
        updateLiveCountdown()
    }

    private var countdownTimer: Timer?

    /// Starts a 1-second interval timer that counts down to midnight in real time.
    public func startLiveCountdownTimer() {
        stopLiveCountdownTimer()
        updateLiveCountdown()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateLiveCountdown()
            }
        }
    }

    /// Stops the 1-second live countdown timer.
    public func stopLiveCountdownTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }

    /// Updates timeRemainingFormatted directly from the device's clock.
    public func updateLiveCountdown() {
        let now = Date()
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        let remaining = max(Int(endOfDay.timeIntervalSince(now)), 0)

        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        self.timeRemainingFormatted = String(format: "%02dh %02dm %02ds", h, m, s)
    }

    // MARK: - Default Seed Data

    public nonisolated static let defaultQuests: [DailyQuest] = [
        DailyQuest(
            title: "Push-ups",
            description: "Physical conditioning protocol for strength awakening.",
            statPillar: .strength,
            targetQuantity: 100,
            currentQuantity: 100,
            unit: "reps",
            expReward: 30,
            goldReward: 0,
            isCompleted: true
        ),
        DailyQuest(
            title: "Deep Work Focus",
            description: "Uninterrupted mental immersion for mana pool expansion.",
            statPillar: .intelligence,
            targetQuantity: 120,
            currentQuantity: 90,
            unit: "min",
            expReward: 50,
            goldReward: 0,
            isCompleted: false
        ),
        DailyQuest(
            title: "Sit-ups",
            description: "Core conditioning protocol.",
            statPillar: .strength,
            targetQuantity: 100,
            currentQuantity: 100,
            unit: "reps",
            expReward: 30,
            goldReward: 0,
            isCompleted: true
        ),
        DailyQuest(
            title: "Running / Steps",
            description: "Cardiovascular velocity and mobility training.",
            statPillar: .agility,
            targetQuantity: 10000,
            currentQuantity: 6400,
            unit: "steps",
            expReward: 40,
            goldReward: 0,
            isCompleted: false
        ),
        DailyQuest(
            title: "Sleep & Hydration Protocol",
            description: "Cellular rejuvenation and recovery protocol.",
            statPillar: .vitality,
            targetQuantity: 2.0,
            currentQuantity: 2.0,
            unit: "L",
            expReward: 25,
            goldReward: 0,
            isCompleted: true
        ),
        DailyQuest(
            title: "Distraction Trap Evasion",
            description: "Active sensory filtering against digital noise.",
            statPillar: .perception,
            targetQuantity: 45,
            currentQuantity: 30,
            unit: "min",
            expReward: 35,
            goldReward: 0,
            isCompleted: false
        )
    ]
}
