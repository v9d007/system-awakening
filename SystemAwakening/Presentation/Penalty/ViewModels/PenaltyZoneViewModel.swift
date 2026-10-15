//
//  PenaltyZoneViewModel.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// ViewModel managing Penalty Zone survival gameplay, countdown timers, vitals telemetry, and escape protocols.
///
/// **Interview Rationale:**
/// - Swift 6 Actor-Safe Convenience Initializers: To prevent crossing actor boundaries in default arguments,
///   designated initializers take explicit parameters, while convenience initializers resolve `@MainActor` dependencies
///   (`SystemHaptics.shared`) strictly inside their isolated method bodies.
/// - Fine-grained `@Observable`: Tracks bio-telemetry (HP, MP, Fatigue 84%), radar proximity blips, and survival countdowns.
@Observable
@MainActor
public final class PenaltyZoneViewModel {
    public var mode: PenaltyZoneMode
    public var survivalSecondsRemaining: Int
    public var workoutSecondsCompleted: Int
    public let workoutTargetSeconds: Int
    public var fatigue: Double
    public var hp: Int
    public let maxHP: Int
    public var mp: Int
    public let maxMP: Int
    public var streakShieldsRemaining: Int
    public var purifiedPotionsRemaining: Int
    public var isAlarmMuted: Bool
    public var hostiles: [HostileEntity]
    public var objectives: [SurvivalObjective]
    public var systemLogs: [SystemStreamLog]

    public var isEvasionOnCooldown: Bool
    public var isPotionAdministering: Bool
    public var showEscapeSuccessOverlay: Bool
    public var showItemDetailModal: Bool
    public var escapeMessage: String

    private let hapticService: HapticServiceProtocol

    public init(
        mode: PenaltyZoneMode,
        survivalSecondsRemaining: Int,
        workoutSecondsCompleted: Int,
        workoutTargetSeconds: Int,
        fatigue: Double,
        hp: Int,
        maxHP: Int,
        mp: Int,
        maxMP: Int,
        streakShieldsRemaining: Int,
        purifiedPotionsRemaining: Int,
        isAlarmMuted: Bool,
        hostiles: [HostileEntity],
        objectives: [SurvivalObjective],
        systemLogs: [SystemStreamLog],
        hapticService: HapticServiceProtocol
    ) {
        self.mode = mode
        self.survivalSecondsRemaining = survivalSecondsRemaining
        self.workoutSecondsCompleted = workoutSecondsCompleted
        self.workoutTargetSeconds = workoutTargetSeconds
        self.fatigue = fatigue
        self.hp = hp
        self.maxHP = maxHP
        self.mp = mp
        self.maxMP = maxMP
        self.streakShieldsRemaining = streakShieldsRemaining
        self.purifiedPotionsRemaining = purifiedPotionsRemaining
        self.isAlarmMuted = isAlarmMuted
        self.hostiles = hostiles
        self.objectives = objectives
        self.systemLogs = systemLogs
        self.isEvasionOnCooldown = false
        self.isPotionAdministering = false
        self.showEscapeSuccessOverlay = false
        self.showItemDetailModal = false
        self.escapeMessage = ""
        self.hapticService = hapticService
    }

    public convenience init(hapticService: HapticServiceProtocol) {
        self.init(
            mode: .alert,
            survivalSecondsRemaining: 14382, // 03:59:42
            workoutSecondsCompleted: 0,
            workoutTargetSeconds: 1800,      // 30 min focus/exercise
            fatigue: 84.0,
            hp: 7420,
            maxHP: 9800,
            mp: 1150,
            maxMP: 4200,
            streakShieldsRemaining: 1,
            purifiedPotionsRemaining: 1,
            isAlarmMuted: false,
            hostiles: HostileEntity.defaultHostiles,
            objectives: SurvivalObjective.defaultObjectives,
            systemLogs: SystemStreamLog.defaultLogs,
            hapticService: hapticService
        )
        self.restoreSavedStateIfAvailable()
    }

    public convenience init() {
        self.init(hapticService: SystemHaptics.shared)
    }

    // MARK: - Computed Properties

    public var timeRemainingFormatted: String {
        let hours = survivalSecondsRemaining / 3600
        let minutes = (survivalSecondsRemaining % 3600) / 60
        let seconds = survivalSecondsRemaining % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    public var timeElapsedFormatted: String {
        let total = 14400 // 4 hours
        let elapsed = max(total - survivalSecondsRemaining, 0)
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        let seconds = elapsed % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    public var survivalProgressFraction: Double {
        let total = 14400.0
        let elapsed = max(total - Double(survivalSecondsRemaining), 0.0)
        return min(max(elapsed / total, 0.0), 1.0)
    }

    public var workoutProgressFraction: Double {
        guard workoutTargetSeconds > 0 else { return 0.0 }
        return min(max(Double(workoutSecondsCompleted) / Double(workoutTargetSeconds), 0.0), 1.0)
    }

    public var workoutProgressText: String {
        "\(workoutSecondsCompleted / 60) / \(workoutTargetSeconds / 60) MIN"
    }

    public var hpFraction: Double {
        guard maxHP > 0 else { return 0.0 }
        return min(max(Double(hp) / Double(maxHP), 0.0), 1.0)
    }

    public var mpFraction: Double {
        guard maxMP > 0 else { return 0.0 }
        return min(max(Double(mp) / Double(maxMP), 0.0), 1.0)
    }

    public var fatigueFraction: Double {
        min(max(fatigue / 100.0, 0.0), 1.0)
    }

    // MARK: - User Actions

    /// Transitions from Emergency Alert to Tactical Survival Gameplay HUD.
    public func beginSurvivalProtocol() {
        self.mode = .tacticalGameplay
        hapticService.penaltyAlert()
        appendLog(tag: "SURVIVAL PROTOCOL", message: "Emergency combat HUD engaged. Hostile centipede swarms detected in perimeter.", colorHex: "FF2E63")
    }

    /// Redeems an inventory Streak Shield to safely bypass the Penalty Zone.
    public func useStreakShield() {
        guard streakShieldsRemaining > 0 else { return }
        streakShieldsRemaining -= 1
        escapeMessage = "Streak Shield Deployed! Penalty Zone nullified without demotion."
        showEscapeSuccessOverlay = true
        hapticService.levelUpCelebration()
        appendLog(tag: "SYSTEM DEFENSE", message: "Streak Shield activated. Hunter safely extracted to Real World.", colorHex: "00E5FF")
    }

    /// Performs Dash Evasion: Sprints to widen distance from hostile blips at the cost of fatigue.
    public func performDashEvasion() {
        guard !isEvasionOnCooldown else { return }
        isEvasionOnCooldown = true
        fatigue = min(fatigue + 8.0, 100.0)
        hapticService.statAllocated()

        // Slightly increase distance of closest hostile
        if !hostiles.isEmpty {
            hostiles[0].distanceMeters += 25
        }

        appendLog(tag: "TACTICAL EVASION", message: "Dash sprint executed. Centipede distance widened (+8 Fatigue).", colorHex: "00E5FF")

        // Reset cooldown after 4 seconds
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.isEvasionOnCooldown = false
        }
    }

    /// Consumes a Purified Essence Potion to restore HP and relieve critical fatigue.
    public func consumePurifiedPotion() {
        guard purifiedPotionsRemaining > 0, !isPotionAdministering else { return }
        isPotionAdministering = true

        Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: 900_000_000)
            self.purifiedPotionsRemaining -= 1
            self.fatigue = max(self.fatigue - 20.0, 0.0)
            self.hp = min(self.hp + 2000, self.maxHP)
            self.isPotionAdministering = false
            self.hapticService.questCompleted()
            self.appendLog(tag: "ITEM CONSUMED", message: "Purified Essence Potion administered: -20 Fatigue, +2,000 HP restored.", colorHex: "00E5FF")
        }
    }

    /// Progresses the 30-minute survival workout / focus exertion block.
    public func incrementWorkoutProgress(minutes: Int = 5) {
        workoutSecondsCompleted = min(workoutSecondsCompleted + (minutes * 60), workoutTargetSeconds)
        hapticService.statAllocated()

        if workoutSecondsCompleted >= workoutTargetSeconds {
            escapeMessage = "Survival Protocol Fulfilled! Warp gate opened. +500 EXP credited."
            showEscapeSuccessOverlay = true
            hapticService.levelUpCelebration()
            appendLog(tag: "ZONE CLEAR", message: "Survival directives fully cleared. Dimensional warp exit unlocked.", colorHex: "00E5FF")
        }
    }

    /// Toggles alarm sound effects and siren icon state.
    public func toggleAlarmMute() {
        isAlarmMuted.toggle()
        hapticService.selectionTick()
    }

    // MARK: - Offline State Persistence

    private static let storageKey = "system_awakening_penalty_state"

    public func saveStateToStorage() {
        let state = PenaltyZoneSavedState(
            survivalSecondsRemaining: survivalSecondsRemaining,
            workoutSecondsCompleted: workoutSecondsCompleted,
            hp: hp,
            mp: mp,
            fatigue: fatigue,
            mode: mode,
            lastSavedDate: Date()
        )
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    public func clearSavedState() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }

    public func restoreSavedStateIfAvailable() {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey),
              let saved = try? JSONDecoder().decode(PenaltyZoneSavedState.self, from: data) else {
            return
        }

        let elapsed = Int(max(Date().timeIntervalSince(saved.lastSavedDate), 0))
        self.survivalSecondsRemaining = max(saved.survivalSecondsRemaining - elapsed, 0)
        self.workoutSecondsCompleted = saved.workoutSecondsCompleted
        self.hp = saved.hp
        self.mp = saved.mp
        self.fatigue = saved.fatigue
        self.mode = saved.mode

        if self.survivalSecondsRemaining == 0 {
            self.escapeMessage = "Penalty Zone Survived! Time limit expired. Dimensional warp gate opened."
            self.showEscapeSuccessOverlay = true
            clearSavedState()
            ProfileManager.shared.setPenalty(active: false)
        }
    }

    // MARK: - Internal Helpers

    private func appendLog(tag: String, message: String, colorHex: String) {
        let entry = SystemStreamLog(tag: tag, message: message, colorHex: colorHex)
        systemLogs.insert(entry, at: 0)
        if systemLogs.count > 10 {
            systemLogs.removeLast()
        }
    }
}

/// Codable state representation of an in-progress Penalty Zone survival session.
public struct PenaltyZoneSavedState: Codable, Sendable {
    public var survivalSecondsRemaining: Int
    public var workoutSecondsCompleted: Int
    public var hp: Int
    public var mp: Int
    public var fatigue: Double
    public var mode: PenaltyZoneMode
    public var lastSavedDate: Date

    public init(
        survivalSecondsRemaining: Int,
        workoutSecondsCompleted: Int,
        hp: Int,
        mp: Int,
        fatigue: Double,
        mode: PenaltyZoneMode,
        lastSavedDate: Date
    ) {
        self.survivalSecondsRemaining = survivalSecondsRemaining
        self.workoutSecondsCompleted = workoutSecondsCompleted
        self.hp = hp
        self.mp = mp
        self.fatigue = fatigue
        self.mode = mode
        self.lastSavedDate = lastSavedDate
    }
}
