//
//  PenaltyAlertView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Penalty Zone Emergency Alert view matching Stitch Screen 5 (fb5b5e340a8c4bd089fffdaf9291be13).
@MainActor
public struct PenaltyAlertView: View {
    @Bindable var viewModel: PenaltyZoneViewModel

    public init(viewModel: PenaltyZoneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.systemDeepVoid
                .ignoresSafeArea()

            // Atmospheric Crimson Ambient Light Bleeds
            ambientCrimsonGlow

            ScrollView {
                VStack(spacing: 16) {
                    topHazardIsland
                    systemDirectiveBanner
                    hazardTickerTape
                    emergencyQuestCard
                    neonCountdownDialCard
                    survivalDirectivesCard
                    dockedActionButtons
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 110) // Safe area breathing room above bottom dock
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Subviews

    private var ambientCrimsonGlow: some View {
        VStack {
            Circle()
                .fill(Color.systemPenaltyCrimson.opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 90)
                .offset(y: -80)

            Spacer()

            Circle()
                .fill(Color.systemPenaltyCrimson.opacity(0.12))
                .frame(width: 280, height: 280)
                .blur(radius: 90)
                .offset(y: 80)
        }
        .allowsHitTesting(false)
    }

    private var topHazardIsland: some View {
        HStack {
            Text("00:00")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))

            Spacer()

            // Dynamic Island Hazard Pill
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemPenaltyCrimson)
                    .frame(width: 7, height: 7)
                    .shadow(color: .systemPenaltyCrimson, radius: 4)

                Text("PENALTY ZONE")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Color.systemCardSurface.opacity(0.95))
            .overlay(
                Capsule()
                    .stroke(Color.systemPenaltyCrimson.opacity(0.6), lineWidth: 1)
            )
            .clipShape(Capsule())
            .shadow(color: .systemPenaltyCrimson.opacity(0.4), radius: 6)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.50")
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white.opacity(0.8))
        }
    }

    private var systemDirectiveBanner: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.systemPenaltyCrimson)
                    .font(.system(size: 13))

                Text("[SYSTEM DIRECTIVE // SEVERE PENALTY]")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
            }

            Spacer()

            Button(action: {
                viewModel.toggleAlarmMute()
            }) {
                Image(systemName: viewModel.isAlarmMuted ? "speaker.slash.fill" : "speaker.wave.3.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(viewModel.isAlarmMuted ? .gray : .systemPenaltyCrimson)
                    .padding(6)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .holographicCard(cornerRadius: 10, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    private var hazardTickerTape: some View {
        HStack(spacing: 8) {
            Image(systemName: "triangle.fill")
                .rotationEffect(.degrees(90))
                .font(.system(size: 8))
                .foregroundColor(.systemPenaltyCrimson)

            Text("⚠️ SYSTEM FORCED WARP DETECTED • SURVIVE OR SUFFER PERMANENT DEMOTION • HOSTILE CLIMATE DETECTED •")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(Color(hex: "FF909E"))
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.systemPenaltyCrimson.opacity(0.12))
        .overlay(
            Rectangle()
                .stroke(Color.systemPenaltyCrimson.opacity(0.3), lineWidth: 1)
        )
    }

    private var emergencyQuestCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.systemPenaltyCrimson.opacity(0.2))
                    Image(systemName: "exclamationmark.octagon.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundColor(.systemPenaltyCrimson)
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("[EMERGENCY QUEST: SURVIVE IN THE PENALTY ZONE]")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(Color(hex: "FF909E"))

                    Text("Daily essential quests were not fulfilled before 23:59:59. You have been forcibly transported to the Penalty Zone.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                }
            }

            Divider()
                .background(Color.systemGridBorder)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "skull.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.systemPenaltyCrimson)
                    Text("RANK: DISASTER")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                Spacer()

                Text("PENALTY DURATION: 4 HOURS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14, glowColor: .systemPenaltyCrimson, isGlowing: true)
    }

    private var neonCountdownDialCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 12))
                    .foregroundColor(.systemPenaltyCrimson)
                Text("SURVIVAL COUNTDOWN // RUN OR FIGHT")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
            }

            // Neon Gauge Circle
            ZStack {
                Circle()
                    .stroke(Color.systemGridBorder, lineWidth: 6)
                    .frame(width: 170, height: 170)

                Circle()
                    .trim(from: 0.0, to: viewModel.survivalProgressFraction)
                    .stroke(
                        Color.systemPenaltyCrimson,
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .shadow(color: .systemPenaltyCrimson.opacity(0.9), radius: 10)

                VStack(spacing: 2) {
                    Text(viewModel.timeRemainingFormatted)
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .systemPenaltyCrimson.opacity(0.8), radius: 6)

                    Text("ZONE COLLAPSE IMMINENT")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("ELAPSED: \(viewModel.timeElapsedFormatted)")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                }
            }
            .padding(.vertical, 6)

            // Environmental Hazard Notice
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.systemPenaltyCrimson)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Zone Effect: Giant Desert Centipedes inbound.")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    Text("Fatigue accumulation rate +200% under high gravity.")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(16)
        .holographicCard(cornerRadius: 16, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    private var survivalDirectivesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("SURVIVAL DIRECTIVES")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()

                Text("MANDATORY")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPenaltyCrimson.opacity(0.15))
                    .clipShape(Capsule())
            }

            // Workout / Deep Focus Requirement
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 12))
                            .foregroundColor(.systemElectricCyan)
                        Text("Emergency Physical Exercise / Deep Focus")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text(viewModel.workoutProgressText)
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.systemDeepVoid)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.systemPenaltyCrimson, Color(hex: "FF6E84")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * viewModel.workoutProgressFraction, 6))
                            .shadow(color: .systemPenaltyCrimson.opacity(0.8), radius: 4)
                    }
                }
                .frame(height: 7)

                HStack {
                    Text("Tap to simulate exercise exertion (+5 min):")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.gray)

                    Spacer()

                    Button(action: {
                        withAnimation {
                            viewModel.incrementWorkoutProgress(minutes: 5)
                        }
                    }) {
                        Text("+5 MIN")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.systemElectricCyan)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Alternative Escape via Streak Shield
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 14))
                        .foregroundColor(.systemShadowPurple)
                    Text("Emergency Shield Bypass")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("\(viewModel.streakShieldsRemaining) INVENTORY ITEM")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.systemShadowPurple)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.systemShadowPurple.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Consequence Alert
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "exclamationmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.systemPenaltyCrimson)

                Text("Consequence of Failure: Level -1 Penalty, -250 EXP deduction, and Hunter Rank Demotion Warning upon countdown expiration.")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
            }
            .padding(10)
            .background(Color.systemPenaltyCrimson.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var dockedActionButtons: some View {
        VStack(spacing: 10) {
            // Primary Survival Protocol Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.beginSurvivalProtocol()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .black))
                    Text("BEGIN SURVIVAL PROTOCOL (30 MIN)")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "E51152"), .systemPenaltyCrimson, Color(hex: "FF6E84")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .systemPenaltyCrimson.opacity(0.8), radius: 8)
            }
            .buttonStyle(.plain)

            // Secondary Streak Shield Button
            Button(action: {
                withAnimation {
                    viewModel.useStreakShield()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                    Text("USE STREAK SHIELD (\(viewModel.streakShieldsRemaining) REMAINING)")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                }
                .foregroundColor(viewModel.streakShieldsRemaining > 0 ? Color(hex: "AF88FF") : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.systemCardSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.streakShieldsRemaining > 0 ? Color.systemShadowPurple.opacity(0.6) : Color.systemGridBorder,
                            lineWidth: 1
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(viewModel.streakShieldsRemaining == 0)

            // Emergency Status Footer
            HStack {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.systemPenaltyCrimson)
                        .frame(width: 5, height: 5)
                    Text("SYSTEM LOCK: ACTIVE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                Spacer()

                Text("SAFE HARBOR PROTOCOL: DISABLED")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    PenaltyAlertView(viewModel: PenaltyZoneViewModel())
}
