//
//  DungeonPortalView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Animated circular Dungeon Gate Portal with dimensional energy rings and countdown timer.
public struct DungeonPortalView: View {
    public let timeRemainingFormatted: String
    public let timeElapsedFormatted: String
    public let progressFraction: Double
    public let rank: HunterRank
    public let isRunning: Bool

    @State private var rotationDegrees: Double = 0

    public init(
        timeRemainingFormatted: String,
        timeElapsedFormatted: String,
        progressFraction: Double,
        rank: HunterRank,
        isRunning: Bool
    ) {
        self.timeRemainingFormatted = timeRemainingFormatted
        self.timeElapsedFormatted = timeElapsedFormatted
        self.progressFraction = min(max(progressFraction, 0.0), 1.0)
        self.rank = rank
        self.isRunning = isRunning
    }

    private var rankColor: Color {
        Color(hex: rank.hexColor)
    }

    public var body: some View {
        ZStack {
            // Outermost Dimensional Aura Ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [rankColor.opacity(0.1), rankColor.opacity(0.8), .systemShadowPurple, rankColor.opacity(0.1)],
                        center: .center
                    ),
                    lineWidth: 3
                )
                .frame(width: 250, height: 250)
                .rotationEffect(.degrees(rotationDegrees))
                .shadow(color: rankColor.opacity(0.6), radius: 10)

            // Orbital Segmented Dash Ring
            Circle()
                .stroke(
                    Color.systemGridBorder,
                    style: StrokeStyle(lineWidth: 2, dash: [4, 8])
                )
                .frame(width: 226, height: 226)

            // Progress Arc
            Circle()
                .trim(from: 0.0, to: progressFraction)
                .stroke(
                    LinearGradient(
                        colors: [rankColor, .systemElectricCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 216, height: 216)
                .rotationEffect(.degrees(-90))
                .shadow(color: rankColor.opacity(0.8), radius: 8)

            // Inner Portal Surface
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.systemCardSurface, Color.systemDeepVoid],
                        center: .center,
                        startRadius: 10,
                        endRadius: 100
                    )
                )
                .frame(width: 196, height: 196)

            // Timer Readouts
            VStack(spacing: 4) {
                Text("REMAINING")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(rankColor)
                    .tracking(2)

                Text(timeRemainingFormatted)
                    .font(.system(size: 34, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .shadow(color: rankColor.opacity(0.7), radius: 6)

                Text("\(timeElapsedFormatted) Elapsed")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 270)
        .onAppear {
            withAnimation(.linear(duration: 12).repeatForever(autoreverses: false)) {
                rotationDegrees = 360
            }
        }
    }
}

#Preview {
    ZStack {
        Color.systemDeepVoid.ignoresSafeArea()
        DungeonPortalView(
            timeRemainingFormatted: "34:20",
            timeElapsedFormatted: "15:40",
            progressFraction: 0.68,
            rank: .c,
            isRunning: true
        )
    }
}
