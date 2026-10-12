//
//  StatType.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation

/// The 5 core Hunter attributes, mapping real-world productivity pillars to RPG stats.
///
/// **Interview Rationale:**
/// - Clean Domain Design: String raw values enable easy serialization (`Codable`) and UI display without bridging.
/// - `CaseIterable` & `Identifiable`: Allows direct consumption by SwiftUI `ForEach` and dynamic radar polygon generation.
public enum StatType: String, Codable, CaseIterable, Identifiable, Sendable {
    case strength = "STR"
    case intelligence = "INT"
    case agility = "AGI"
    case vitality = "VIT"
    case perception = "PER"

    public var id: String { rawValue }

    /// Human-readable full name of the attribute.
    public var displayName: String {
        switch self {
        case .strength: return "Strength"
        case .intelligence: return "Intelligence"
        case .agility: return "Agility"
        case .vitality: return "Vitality"
        case .perception: return "Perception"
        }
    }

    /// Real-world habit category mapped to this stat.
    public var habitCategory: String {
        switch self {
        case .strength: return "Physical Fitness & Workouts"
        case .intelligence: return "Deep Work & Technical Learning"
        case .agility: return "Habit Velocity & Morning Routines"
        case .vitality: return "Sleep, Hydration & Recovery"
        case .perception: return "Mindfulness & Unbroken Focus"
        }
    }

    /// SF Symbol icon name recommended for this stat.
    public var iconSystemName: String {
        switch self {
        case .strength: return "figure.run"
        case .intelligence: return "brain.head.profile"
        case .agility: return "bolt.fill"
        case .vitality: return "heart.fill"
        case .perception: return "eye.fill"
        }
    }

    /// Brief explanation of the stat's gameplay and productivity effect.
    public var description: String {
        switch self {
        case .strength: return "Increases physical stamina, reduces workout fatigue, boosts raw EXP output."
        case .intelligence: return "Accelerates dungeon raid clears, increases mana pool for deep work."
        case .agility: return "Reduces habit procrastination delay, improves daily task completion speed."
        case .vitality: return "Enhances daily fatigue recovery, protects against burn-out debuffs."
        case .perception: return "Unlocks critical focus focus multipliers and senses distraction traps."
        }
    }
}
