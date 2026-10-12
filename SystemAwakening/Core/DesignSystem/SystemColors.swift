//
//  SystemColors.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Solo Leveling System HUD Color Palette.
///
/// **Interview Rationale:**
/// - Why centralized Color extensions: Prevents magic hex strings scattered across views, guarantees consistent theming,
///   and enables effortless support for accessibility contrast compliance and future theme variants (e.g. Red Gate mode).
/// - Dynamic Semantic Tokens: By extending `Color`, SwiftUI views can use `.systemDeepVoid`, `.systemElectricCyan`, etc.,
///   with full preview support and zero runtime overhead.
public extension Color {
    /// Deep Obsidian Void Canvas background (`#07080D`).
    static let systemDeepVoid = Color(hex: "07080D")

    /// Elevated frosted glass card background (`#0F121D`).
    static let systemCardSurface = Color(hex: "0F121D")

    /// Electric Cyan neon glow for System notifications, active progress, and primary accents (`#00E5FF`).
    static let systemElectricCyan = Color(hex: "00E5FF")

    /// Shadow Sovereign Purple for S-Rank tier, Monarch skills, and high-level mastery (`#7C3AED`).
    static let systemShadowPurple = Color(hex: "7C3AED")

    /// Penalty Crimson for urgent emergency quests, timer breaks, and survival states (`#FF2E63`).
    static let systemPenaltyCrimson = Color(hex: "FF2E63")

    /// Gate Amber for dungeon alerts and rare achievement badges (`#F59E0B`).
    static let systemGateAmber = Color(hex: "F59E0B")

    /// Muted Slate for inactive grid lines and borders (`#1E2235`).
    static let systemGridBorder = Color(hex: "1E2235")
}

public extension Color {
    /// Initializes a SwiftUI `Color` from a 6-character hex string (e.g. "00E5FF" or "#00E5FF").
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
