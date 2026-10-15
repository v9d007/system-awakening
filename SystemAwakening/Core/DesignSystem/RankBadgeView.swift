//
//  RankBadgeView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// A high-tech, metallic-embossed badge displaying the Hunter's rank.
///
/// **Interview Rationale:**
/// - Declarative UI: Pure SwiftUI component driven entirely by the `HunterRank` domain enum, demonstrating
///   how design tokens and domain models cleanly interface without coupling the domain to SwiftUI.
public struct RankBadgeView: View {
    public let rank: HunterRank
    public var showTitle: Bool
    public var size: BadgeSize

    public enum BadgeSize {
        case small
        case medium
        case large

        var dimension: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 48
            case .large: return 64
            }
        }

        var fontSize: Font {
            switch self {
            case .small: return .system(size: 14, weight: .black, design: .monospaced)
            case .medium: return .system(size: 20, weight: .black, design: .monospaced)
            case .large: return .system(size: 28, weight: .black, design: .monospaced)
            }
        }
    }

    public init(rank: HunterRank, showTitle: Bool = false, size: BadgeSize = .medium) {
        self.rank = rank
        self.showTitle = showTitle
        self.size = size
    }

    private var rankColor: Color {
        Color(hex: rank.hexColor)
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Emblemed Rank Monogram Box
            ZStack {
                RoundedRectangle(cornerRadius: size.dimension * 0.25, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [rankColor.opacity(0.3), Color.systemCardSurface],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: size.dimension * 0.25, style: .continuous)
                            .stroke(rankColor, lineWidth: 1.5)
                            .shadow(color: rankColor.opacity(0.7), radius: 6)
                    )

                Text(rankLetter)
                    .font(size.fontSize)
                    .foregroundColor(rankColor)
                    .shadow(color: rankColor.opacity(0.8), radius: 4)
            }
            .frame(width: size.dimension, height: size.dimension)

            if showTitle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(rank.rawValue.uppercased())
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(rankColor)
                    Text(rank.canonicalTitle)
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(rank.rawValue), \(rank.canonicalTitle)")
    }

    private var rankLetter: String {
        switch rank {
        case .e: return "E"
        case .d: return "D"
        case .c: return "C"
        case .b: return "B"
        case .a: return "A"
        case .s: return "S"
        case .nationalLevel: return "NL"
        }
    }
}

#Preview {
    ZStack {
        Color.systemDeepVoid.ignoresSafeArea()
        VStack(spacing: 16) {
            RankBadgeView(rank: .e, showTitle: true)
            RankBadgeView(rank: .b, showTitle: true)
            RankBadgeView(rank: .s, showTitle: true)
            RankBadgeView(rank: .nationalLevel, showTitle: true)
        }
    }
}
