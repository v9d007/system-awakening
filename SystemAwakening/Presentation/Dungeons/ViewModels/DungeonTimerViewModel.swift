//
//  DungeonTimerViewModel.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// ViewModel managing the Gate Raid focus timer and boss damage mechanics.
@Observable
@MainActor
public final class DungeonTimerViewModel {
    public var selectedDungeon: GateDungeon
    public var totalSeconds: Int
    public var remainingSeconds: Int
    public var isRunning: Bool
    public var isPaused: Bool
    public var showVictoryOverlay: Bool
    public var showGateBreakOverlay: Bool

    private let hapticService: HapticServiceProtocol
    private var timerTask: Task<Void, Never>?

    public init(
        dungeon: GateDungeon,
        hapticService: HapticServiceProtocol
    ) {
        self.selectedDungeon = dungeon
        self.totalSeconds = dungeon.durationMinutes * 60
        self.remainingSeconds = Int(Double(dungeon.durationMinutes * 60) * 0.68) // Demo seed ~68%
        self.isRunning = true
        self.isPaused = false
        self.showVictoryOverlay = false
        self.showGateBreakOverlay = false
        self.hapticService = hapticService
    }

    public convenience init(hapticService: HapticServiceProtocol) {
        self.init(
            dungeon: GateDungeon.standardPresets[2],
            hapticService: hapticService
        )
    }

    public convenience init(dungeon: GateDungeon? = nil) {
        self.init(
            dungeon: dungeon ?? GateDungeon.standardPresets[2],
            hapticService: SystemHaptics.shared
        )
    }

    // MARK: - Computed Properties

    public var elapsedSeconds: Int {
        max(totalSeconds - remainingSeconds, 0)
    }

    public var progressFraction: Double {
        guard totalSeconds > 0 else { return 0.0 }
        return Double(elapsedSeconds) / Double(totalSeconds)
    }

    public var bossHPFraction: Double {
        guard totalSeconds > 0 else { return 0.0 }
        return Double(remainingSeconds) / Double(totalSeconds)
    }

    public var timeRemainingFormatted: String {
        let mins = remainingSeconds / 60
        let secs = remainingSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    public var timeElapsedFormatted: String {
        let mins = elapsedSeconds / 60
        let secs = elapsedSeconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    // MARK: - Actions

    public func togglePlayPause() {
        if isRunning {
            isRunning = false
            isPaused = true
            hapticService.selectionTick()
        } else {
            isRunning = true
            isPaused = false
            hapticService.selectionTick()
        }
    }

    public func abandonRaid() {
        isRunning = false
        showGateBreakOverlay = true
        hapticService.penaltyAlert()
    }

    public func claimVictory() {
        isRunning = false
        showVictoryOverlay = true
        hapticService.levelUpCelebration()
    }

    public func selectDungeon(_ dungeon: GateDungeon) {
        self.selectedDungeon = dungeon
        self.totalSeconds = dungeon.durationMinutes * 60
        self.remainingSeconds = dungeon.durationMinutes * 60
        self.isRunning = false
        self.isPaused = false
    }
}
