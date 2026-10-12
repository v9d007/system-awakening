//
//  DailyQuest.swift
//  System: Awakening
//
//  Created for "System: Awakening" (Arise) — Gamified Solo Leveling Productivity App
//

import Foundation

/// Pure Domain model representing a daily quest issued by the System.
///
/// **Interview Rationale:**
/// - Immutability via Structs: Eliminates shared mutable state bugs across concurrent tasks. State transformations
///   return a new copy (`withProgress`), conforming to functional programming and UDF best practices.
/// - Conformance to `Sendable`: Guarantees thread-safe boundary crossing between background persistence actors and `@MainActor` UI.
public struct DailyQuest: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String
    public var statPillar: StatType
    public var targetQuantity: Double
    public var currentQuantity: Double
    public var unit: String
    public var expReward: Int
    public var goldReward: Int // Gold earned to spend in System Shop
    public var statPointsReward: Int
    public var isCompleted: Bool
    public var isEssential: Bool // Uncompleted essential quests activate the Penalty Zone at midnight
    public var deadline: Date

    public init(
        id: UUID = UUID(),
        title: String,
        description: String = "",
        statPillar: StatType,
        targetQuantity: Double,
        currentQuantity: Double = 0.0,
        unit: String,
        expReward: Int,
        goldReward: Int = 20,
        statPointsReward: Int = 1,
        isCompleted: Bool = false,
        isEssential: Bool = true,
        deadline: Date = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86399) // 23:59:59
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.statPillar = statPillar
        self.targetQuantity = targetQuantity
        self.currentQuantity = currentQuantity
        self.unit = unit
        self.expReward = expReward
        self.goldReward = goldReward
        self.statPointsReward = statPointsReward
        self.isCompleted = isCompleted
        self.isEssential = isEssential
        self.deadline = deadline
    }

    /// Normalized completion progress between 0.0 and 1.0.
    public var progressFraction: Double {
        guard targetQuantity > 0 else { return 0.0 }
        return min(max(currentQuantity / targetQuantity, 0.0), 1.0)
    }

    /// User-facing formatted progress string (e.g. "75/100 Push-ups").
    public var formattedProgress: String {
        let currentInt = Int(currentQuantity)
        let targetInt = Int(targetQuantity)
        if targetQuantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(currentInt)/\(targetInt) \(unit)"
        } else {
            return String(format: "%.1f/%.1f %@", currentQuantity, targetQuantity, unit)
        }
    }

    /// Returns a new `DailyQuest` updated with additional progress.
    public func withProgress(increment: Double) -> DailyQuest {
        var copy = self
        copy.currentQuantity = min(copy.currentQuantity + increment, copy.targetQuantity)
        if copy.currentQuantity >= copy.targetQuantity {
            copy.isCompleted = true
        }
        return copy
    }

    /// Returns a new `DailyQuest` toggling completion directly.
    public func withCompletion(_ completed: Bool) -> DailyQuest {
        var copy = self
        copy.isCompleted = completed
        if completed {
            copy.currentQuantity = copy.targetQuantity
        }
        return copy
    }
}
