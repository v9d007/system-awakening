//
//  SystemTheme.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI
import Observation

/// The selectable aesthetic visual themes for the Solo Leveling System HUD.
///
/// **Interview Rationale:**
/// - Theme Value Types: Decouples color definitions from views into an immutable, `Sendable` value contract (`ThemePalette`),
///   enabling atomic runtime theme switching without view reconstruction.
/// - Swift 6 Strict Concurrency: `ThemeManager` is strictly `@MainActor`-isolated and `@Observable`, guaranteeing thread-safe
///   UI mutations and zero Combine boilerplate.
public enum SystemTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    /// Theme 1: Lore-accurate deep obsidian canvas, royal ultraviolet glow, platinum silver, and soft lavender accents.
    case shadowMonarch = "SHADOW MONARCH"
    /// Theme 3: Majestic celestial navy canvas, radiant imperial gold, champagne ivory, and electric azure mana highlights.
    case solarSovereign = "SOLAR SOVEREIGN"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .shadowMonarch: return "SHADOW MONARCH"
        case .solarSovereign: return "SOLAR SOVEREIGN"
        }
    }

    public var iconSystemName: String {
        switch self {
        case .shadowMonarch: return "crown.fill"
        case .solarSovereign: return "sun.max.fill"
        }
    }

    public var subtitle: String {
        switch self {
        case .shadowMonarch: return "Obsidian & Ultraviolet"
        case .solarSovereign: return "Celestial Navy & Gold"
        }
    }

    public var palette: ThemePalette {
        switch self {
        case .shadowMonarch:
            return ThemePalette(
                canvasBackground: Color(hex: "0A0B12"),
                cardSurface: Color(hex: "121324"),
                cardBorder: Color(hex: "2E2A4A"),
                primaryAccent: Color(hex: "8B5CF6"),
                primaryAccentGlow: Color(hex: "A78BFA"),
                secondaryAccent: Color(hex: "C4B5FD"),
                textPrimary: Color(hex: "F8FAFC"),
                textSecondary: Color(hex: "94A3B8"),
                expGradientStart: Color(hex: "7C3AED"),
                expGradientEnd: Color(hex: "A78BFA"),
                radarFill: Color(hex: "8B5CF6").opacity(0.28),
                radarStroke: Color(hex: "A78BFA"),
                penaltyCrimson: Color(hex: "FF2E63"),
                gateAmber: Color(hex: "F59E0B")
            )
        case .solarSovereign:
            return ThemePalette(
                canvasBackground: Color(hex: "070A12"),
                cardSurface: Color(hex: "101524"),
                cardBorder: Color(hex: "3D2E14"),
                primaryAccent: Color(hex: "F59E0B"),
                primaryAccentGlow: Color(hex: "FBBF24"),
                secondaryAccent: Color(hex: "38BDF8"),
                textPrimary: Color(hex: "FEF3C7"),
                textSecondary: Color(hex: "94A3B8"),
                expGradientStart: Color(hex: "D97706"),
                expGradientEnd: Color(hex: "FBBF24"),
                radarFill: Color(hex: "F59E0B").opacity(0.25),
                radarStroke: Color(hex: "FBBF24"),
                penaltyCrimson: Color(hex: "FF2E63"),
                gateAmber: Color(hex: "F59E0B")
            )
        }
    }
}

/// Immutable design tokens defining an active theme's visual contract.
public struct ThemePalette: Sendable {
    public let canvasBackground: Color
    public let cardSurface: Color
    public let cardBorder: Color
    public let primaryAccent: Color
    public let primaryAccentGlow: Color
    public let secondaryAccent: Color
    public let textPrimary: Color
    public let textSecondary: Color
    public let expGradientStart: Color
    public let expGradientEnd: Color
    public let radarFill: Color
    public let radarStroke: Color
    public let penaltyCrimson: Color
    public let gateAmber: Color
}

/// Centralized state manager for the app's active visual theme.
@Observable
@MainActor
public final class ThemeManager {
    public static let shared = ThemeManager()

    private static let themeStorageKey = "system_awakening_selected_theme"

    public var currentTheme: SystemTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Self.themeStorageKey)
        }
    }

    public var palette: ThemePalette {
        currentTheme.palette
    }

    private init() {
        if let saved = UserDefaults.standard.string(forKey: Self.themeStorageKey),
           let theme = SystemTheme(rawValue: saved) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .shadowMonarch
        }
    }

    /// Explicitly sets the active design theme.
    public func switchTheme(to theme: SystemTheme) {
        guard theme != currentTheme else { return }
        self.currentTheme = theme
        SystemHaptics.shared.selectionTick()
    }

    /// Toggles between Shadow Monarch and Solar Sovereign.
    public func toggleTheme() {
        switch currentTheme {
        case .shadowMonarch:
            switchTheme(to: .solarSovereign)
        case .solarSovereign:
            switchTheme(to: .shadowMonarch)
        }
    }
}
