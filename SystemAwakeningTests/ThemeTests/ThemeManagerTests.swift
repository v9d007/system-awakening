//
//  ThemeManagerTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
import SwiftUI
@testable import SystemAwakening

@MainActor
final class ThemeManagerTests: XCTestCase {

    private let storageKey = "system_awakening_selected_theme"
    private var originalStoredTheme: String?

    override func setUp() {
        super.setUp()
        originalStoredTheme = UserDefaults.standard.string(forKey: storageKey)
    }

    override func tearDown() {
        if let originalStoredTheme {
            UserDefaults.standard.set(originalStoredTheme, forKey: storageKey)
        } else {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
        super.tearDown()
    }

    func testAllThemesHaveCompletePalettes() {
        for theme in SystemTheme.allCases {
            XCTAssertFalse(theme.displayName.isEmpty)
            XCTAssertFalse(theme.iconSystemName.isEmpty)
            XCTAssertFalse(theme.subtitle.isEmpty)

            let palette = theme.palette
            XCTAssertNotNil(palette.canvasBackground)
            XCTAssertNotNil(palette.cardSurface)
            XCTAssertNotNil(palette.cardBorder)
            XCTAssertNotNil(palette.primaryAccent)
            XCTAssertNotNil(palette.primaryAccentGlow)
            XCTAssertNotNil(palette.secondaryAccent)
            XCTAssertNotNil(palette.textPrimary)
            XCTAssertNotNil(palette.textSecondary)
            XCTAssertNotNil(palette.expGradientStart)
            XCTAssertNotNil(palette.expGradientEnd)
            XCTAssertNotNil(palette.radarFill)
            XCTAssertNotNil(palette.radarStroke)
            XCTAssertNotNil(palette.penaltyCrimson)
            XCTAssertNotNil(palette.gateAmber)
        }
    }

    func testThemeMetadataMatchesSpecification() {
        let monarch = SystemTheme.shadowMonarch
        XCTAssertEqual(monarch.displayName, "SHADOW MONARCH")
        XCTAssertEqual(monarch.iconSystemName, "crown.fill")
        XCTAssertEqual(monarch.subtitle, "Obsidian & Ultraviolet")

        let solar = SystemTheme.solarSovereign
        XCTAssertEqual(solar.displayName, "SOLAR SOVEREIGN")
        XCTAssertEqual(solar.iconSystemName, "sun.max.fill")
        XCTAssertEqual(solar.subtitle, "Celestial Navy & Gold")
    }

    func testThemeSwitchingUpdatesStateAndStorage() {
        let manager = ThemeManager.shared

        // Switch to Solar Sovereign
        manager.switchTheme(to: .solarSovereign)
        XCTAssertEqual(manager.currentTheme, .solarSovereign)
        XCTAssertEqual(UserDefaults.standard.string(forKey: storageKey), SystemTheme.solarSovereign.rawValue)

        // Switch to Shadow Monarch
        manager.switchTheme(to: .shadowMonarch)
        XCTAssertEqual(manager.currentTheme, .shadowMonarch)
        XCTAssertEqual(UserDefaults.standard.string(forKey: storageKey), SystemTheme.shadowMonarch.rawValue)
    }

    func testThemeToggleCyclesBetweenThemes() {
        let manager = ThemeManager.shared

        manager.switchTheme(to: .shadowMonarch)
        XCTAssertEqual(manager.currentTheme, .shadowMonarch)

        manager.toggleTheme()
        XCTAssertEqual(manager.currentTheme, .solarSovereign)

        manager.toggleTheme()
        XCTAssertEqual(manager.currentTheme, .shadowMonarch)
    }

    func testDynamicSemanticColorsBindToActiveTheme() {
        let manager = ThemeManager.shared

        manager.switchTheme(to: .shadowMonarch)
        let monarchPalette = manager.palette
        XCTAssertEqual(Color.systemBackground, monarchPalette.canvasBackground)
        XCTAssertEqual(Color.systemCard, monarchPalette.cardSurface)
        XCTAssertEqual(Color.systemBorder, monarchPalette.cardBorder)
        XCTAssertEqual(Color.systemPrimary, monarchPalette.primaryAccent)
        XCTAssertEqual(Color.systemPrimaryGlow, monarchPalette.primaryAccentGlow)
        XCTAssertEqual(Color.systemSecondary, monarchPalette.secondaryAccent)
        XCTAssertEqual(Color.systemTextPrimary, monarchPalette.textPrimary)
        XCTAssertEqual(Color.systemTextSecondary, monarchPalette.textSecondary)

        manager.switchTheme(to: .solarSovereign)
        let solarPalette = manager.palette
        XCTAssertEqual(Color.systemBackground, solarPalette.canvasBackground)
        XCTAssertEqual(Color.systemCard, solarPalette.cardSurface)
        XCTAssertEqual(Color.systemBorder, solarPalette.cardBorder)
        XCTAssertEqual(Color.systemPrimary, solarPalette.primaryAccent)
        XCTAssertEqual(Color.systemPrimaryGlow, solarPalette.primaryAccentGlow)
        XCTAssertEqual(Color.systemSecondary, solarPalette.secondaryAccent)
        XCTAssertEqual(Color.systemTextPrimary, solarPalette.textPrimary)
        XCTAssertEqual(Color.systemTextSecondary, solarPalette.textSecondary)
    }
}
