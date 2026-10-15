//
//  SystemHaptics.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import UIKit

/// Protocol defining the tactile sensory feedback contract for the app.
///
/// **Interview Rationale:**
/// - Protocol-Oriented Haptics: Allows mock implementations during unit tests or headless CI runs where UIKit
///   hardware feedback generators are either unavailable or shouldn't produce runtime side effects.
/// - Concurrency & MainActor: Hardware generators must be invoked on the `@MainActor` thread.
@MainActor
public protocol HapticServiceProtocol: Sendable {
    func statAllocated()
    func questCompleted()
    func levelUpCelebration()
    func penaltyAlert()
    func selectionTick()
}

/// Production implementation of `HapticServiceProtocol` using modern UIKit Feedback Generators.
@MainActor
public final class SystemHaptics: HapticServiceProtocol {
    public static let shared = SystemHaptics()

    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    private init() {
        // Pre-warm generators for near-zero latency
        rigidImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
        selection.prepare()
    }

    /// Sharp, precise mechanical notch for stat point increment.
    public func statAllocated() {
        rigidImpact.impactOccurred(intensity: 1.0)
        rigidImpact.prepare()
    }

    /// Success chime sequence when a daily quest objective is cleared.
    public func questCompleted() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }

    /// Heavy, thunderous multi-burst celebration for Level Up / "Arise" event.
    public func levelUpCelebration() {
        heavyImpact.impactOccurred(intensity: 1.0)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 120_000_000)
            self.rigidImpact.impactOccurred(intensity: 0.9)
            try? await Task.sleep(nanoseconds: 100_000_000)
            self.notification.notificationOccurred(.success)
        }
    }

    /// Urgent double-pulse warning when the Penalty Zone is activated.
    public func penaltyAlert() {
        notification.notificationOccurred(.error)
        notification.prepare()
    }

    /// Subtle micro-tick for tab switches and menu navigation.
    public func selectionTick() {
        selection.selectionChanged()
        selection.prepare()
    }
}
