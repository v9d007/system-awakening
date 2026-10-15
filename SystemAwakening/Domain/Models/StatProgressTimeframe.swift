//
//  StatProgressTimeframe.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation

/// Represents the selectable temporal granularity for the Pentagon Attribute Matrix telemetry.
public enum StatProgressTimeframe: String, CaseIterable, Identifiable, Sendable {
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case yearly = "YEARLY"

    public var id: String { rawValue }

    public var shortTitle: String {
        switch self {
        case .weekly: return "WEEK"
        case .monthly: return "MONTH"
        case .yearly: return "YEAR"
        }
    }

    /// Evaluates simulated growth delta points for this timeframe given current base stats.
    public func growthPoints(for stat: StatType, currentValue: Int) -> Int {
        switch self {
        case .weekly:
            // Recent week gains
            switch stat {
            case .strength: return 2
            case .intelligence: return 3
            case .agility: return 1
            case .vitality: return 2
            case .perception: return 1
            }
        case .monthly:
            // 30-day cumulative progression
            switch stat {
            case .strength: return 8
            case .intelligence: return 11
            case .agility: return 6
            case .vitality: return 7
            case .perception: return 5
            }
        case .yearly:
            // All-time awakened growth from baseline 10
            return max(0, currentValue - 10)
        }
    }

    /// Total Power (PWR) gained during this timeframe across all 5 attributes.
    public func totalGrowth(stats: [StatType: Int]) -> Int {
        StatType.allCases.reduce(0) { sum, stat in
            sum + growthPoints(for: stat, currentValue: stats[stat] ?? 10)
        }
    }

    /// User-facing telemetry summary string (e.g. "+9 PWR THIS WEEK").
    public func telemetrySummary(stats: [StatType: Int]) -> String {
        let delta = totalGrowth(stats: stats)
        switch self {
        case .weekly: return "+\(delta) PWR THIS WEEK"
        case .monthly: return "+\(delta) PWR THIS MONTH"
        case .yearly: return "+\(delta) PWR ALL-TIME"
        }
    }

    /// Adjusted visual stat values for the radar diagram to illustrate comparative progression.
    public func adjustedStats(currentStats: [StatType: Int]) -> [StatType: Int] {
        switch self {
        case .weekly:
            return currentStats
        case .monthly:
            var adjusted = currentStats
            for (stat, val) in currentStats {
                adjusted[stat] = min(100, val + growthPoints(for: stat, currentValue: val) / 3)
            }
            return adjusted
        case .yearly:
            var adjusted = currentStats
            for (stat, val) in currentStats {
                adjusted[stat] = min(100, max(15, val))
            }
            return adjusted
        }
    }
}
