//
//  SystemNotificationService.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import UserNotifications

/// Protocol defining the local offline notification capabilities of the System.
public protocol SystemNotificationServiceProtocol: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleQuestReminder(for quest: DailyQuest) async
    func cancelQuestReminder(for questId: UUID)
}

/// Thread-safe local offline notification service managing daily quest alerts.
public final class SystemNotificationService: SystemNotificationServiceProtocol, Sendable {
    public static let shared = SystemNotificationService()

    private let center: UNUserNotificationCenter

    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// Requests user authorization for local notifications.
    @discardableResult
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    /// Schedules a repeating daily notification for a user directive at its configured reminder time.
    public func scheduleQuestReminder(for quest: DailyQuest) async {
        guard quest.isReminderEnabled, let reminderTime = quest.reminderTime else {
            cancelQuestReminder(for: quest.id)
            return
        }

        let granted = await requestAuthorization()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "[SYSTEM DIRECTIVE ALERT]"
        content.subtitle = "\(quest.statPillar.displayName) Protocol Active"
        content.body = "Time to execute directive: \(quest.title) (\(quest.formattedProgress)). Evasion active."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier = reminderIdentifier(for: quest.id)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Cancel existing before adding updated
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        try? await center.add(request)
    }

    /// Cancels any scheduled reminder for the given directive ID.
    public func cancelQuestReminder(for questId: UUID) {
        let identifier = reminderIdentifier(for: questId)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    private func reminderIdentifier(for questId: UUID) -> String {
        "system-awakening-quest-\(questId.uuidString)"
    }
}
