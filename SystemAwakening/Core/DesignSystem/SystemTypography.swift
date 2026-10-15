//
//  SystemTypography.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Centralized Typography tokens for System: Awakening.
///
/// **Interview Rationale:**
/// - Dynamic Type Accessibility: While adopting a futuristic monospaced style, we anchor fonts to Apple's
///   system text styles (`.title`, `.headline`, `.callout`, etc.) so that text responds dynamically to user
///   accessibility text size settings (Dynamic Type).
public enum SystemTypography {
    /// Ominous system directive banners, e.g. "[DAILY QUEST: GETTING READY TO BECOME STRONG]".
    public static var systemBanner: Font {
        .system(.title3, design: .monospaced, weight: .black)
    }

    /// Hunter Level and primary stats numbers.
    public static var metricLarge: Font {
        .system(size: 32, weight: .heavy, design: .monospaced)
    }

    /// Standard numerical stat values (e.g. 45, 62).
    public static var metricMedium: Font {
        .system(.title3, design: .monospaced, weight: .bold)
    }

    /// Section titles and card headers.
    public static var sectionHeader: Font {
        .system(.headline, design: .monospaced, weight: .bold)
    }

    /// Standard card body copy.
    public static var bodyText: Font {
        .system(.subheadline, design: .default, weight: .regular)
    }

    /// Small system chips, timestamps, and currency indicators.
    public static var captionTech: Font {
        .system(.caption, design: .monospaced, weight: .semibold)
    }

    /// Micro-tag pill badges.
    public static var microTag: Font {
        .system(size: 10, weight: .bold, design: .monospaced)
    }
}
