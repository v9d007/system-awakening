//
//  DailyCycleManager.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation

/// Centralized offline service evaluating calendar day rollovers, streaks, and penalty activations at midnight.
@MainActor
public final class DailyCycleManager: Sendable {
    public static let shared = DailyCycleManager()

    private let profileManager: ProfileManager
    private let questViewModel: DailyQuestViewModel

    public init(
        profileManager: ProfileManager = ProfileManager.shared,
        questViewModel: DailyQuestViewModel = DailyQuestViewModel.shared
    ) {
        self.profileManager = profileManager
        self.questViewModel = questViewModel
    }

    /// Evaluates if midnight has passed since the last active session.
    /// If a new day has arrived:
    /// - Checks yesterday's essential quests (awards streak or activates Penalty Zone).
    /// - Renews daily quest quantities for the new day while preserving all user-created directives.
    /// Returns `true` if a rollover was executed, `false` otherwise.
    @discardableResult
    public func checkAndExecuteMidnightRollover(currentDate: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let lastDate = profileManager.lastActiveDate

        // If today is the same calendar day as the last active check, no rollover is needed
        if calendar.isDate(lastDate, inSameDayAs: currentDate) {
            return false
        }

        // --- MIDNIGHT EVALUATION ---
        let quests = questViewModel.quests
        let essentialQuests = quests.filter { $0.isEssential }

        // A day is successfully cleared if all essential objectives were completed
        let allEssentialCleared = !essentialQuests.isEmpty && essentialQuests.allSatisfy { $0.isCompleted }

        if allEssentialCleared {
            // Hunter fulfilled their daily directives: increment streak and ensure penalty is evasion-cleared
            profileManager.incrementStreak()
            profileManager.setPenalty(active: false)
        } else if !essentialQuests.isEmpty {
            // Failure to clear essential directives before midnight activates Penalty Zone
            profileManager.setPenalty(active: true)
            // If more than 1 day missed, reset streak
            if let daysBetween = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: currentDate)).day,
               daysBetween > 1 {
                profileManager.resetStreak()
            }
        }

        // --- RENEW DIRECTIVES FOR NEW DAY ---
        questViewModel.renewDirectivesForNewDay(currentDate: currentDate)

        // Stamp new active calendar date
        profileManager.lastActiveDate = currentDate
        return true
    }

    /// Calculates formatted hours, minutes, and seconds remaining until midnight (23:59:59).
    public func formattedTimeUntilMidnight(from now: Date = Date()) -> String {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        let remainingSeconds = max(Int(endOfDay.timeIntervalSince(now)), 0)

        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }

    /// Seconds remaining until midnight.
    public func timeUntilMidnight(from now: Date = Date()) -> TimeInterval {
        let calendar = Calendar.current
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now
        return max(endOfDay.timeIntervalSince(now), 0)
    }
}
