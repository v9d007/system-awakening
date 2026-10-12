//
//  HunterRank.swift
//  Arise
//
//  Created for "Arise" — Gamified Solo Leveling Productivity App
//

import Foundation

/// Represents the Hunter's official guild evaluation rank.
///
/// **Interview Rationale:**
/// - Why `Comparable` enum: Enums provide exhaustive type safety. Conforming to `Comparable` allows natural ordering
///   queries like `profile.rank >= .b`, eliminating arbitrary integer rank checks.
/// - Value Type Purity: Kept strictly decoupled from UI and persistence frameworks, ensuring 100% thread safety across actors.
public enum HunterRank: String, Codable, CaseIterable, Comparable, Sendable {
    case e = "E-Rank"
    case d = "D-Rank"
    case c = "C-Rank"
    case b = "B-Rank"
    case a = "A-Rank"
    case s = "S-Rank"
    case nationalLevel = "National Level"

    /// The minimum Hunter level required to achieve this rank.
    public var minimumLevel: Int {
        switch self {
        case .e: return 1
        case .d: return 10
        case .c: return 25
        case .b: return 45
        case .a: return 70
        case .s: return 100
        case .nationalLevel: return 150
        }
    }

    /// The canonical honorary Hunter title associated with this rank.
    public var canonicalTitle: String {
        switch self {
        case .e: return "The Weakest Hunter"
        case .d: return "Awakened Novice"
        case .c: return "Dungeon Cleaner"
        case .b: return "Raid Specialist"
        case .a: return "Elite Vanguard"
        case .s: return "Shadow Sovereign"
        case .nationalLevel: return "Monarch of Shadows"
        }
    }

    /// Hex color code representing the rank tier.
    public var hexColor: String {
        switch self {
        case .e: return "64748B" // Slate Gray
        case .d: return "3B82F6" // Standard Blue
        case .c: return "10B981" // Emerald Green
        case .b: return "F59E0B" // Amber Gold
        case .a: return "EF4444" // Crimson Scarlet
        case .s: return "7C3AED" // Monarch Purple
        case .nationalLevel: return "00E5FF" // Electric Cyan
        }
    }

    /// Evaluates whether a Hunter of a given level qualifies for this rank or higher.
    public static func rank(for level: Int) -> HunterRank {
        if level >= HunterRank.nationalLevel.minimumLevel { return .nationalLevel }
        if level >= HunterRank.s.minimumLevel { return .s }
        if level >= HunterRank.a.minimumLevel { return .a }
        if level >= HunterRank.b.minimumLevel { return .b }
        if level >= HunterRank.c.minimumLevel { return .c }
        if level >= HunterRank.d.minimumLevel { return .d }
        return .e
    }

    // MARK: - Comparable Conformance
    private var sortOrder: Int {
        switch self {
        case .e: return 0
        case .d: return 1
        case .c: return 2
        case .b: return 3
        case .a: return 4
        case .s: return 5
        case .nationalLevel: return 6
        }
    }

    public static func < (lhs: HunterRank, rhs: HunterRank) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
