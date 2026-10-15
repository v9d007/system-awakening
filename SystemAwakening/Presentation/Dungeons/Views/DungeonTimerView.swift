//
//  DungeonTimerView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// The Gate Raids & Dungeon Focus Timer screen matching Stitch Screen 3.
@MainActor
public struct DungeonTimerView: View {
    @State private var viewModel: DungeonTimerViewModel

    public init(viewModel: DungeonTimerViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public init() {
        self.init(viewModel: DungeonTimerViewModel())
    }

    public var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    topRaidHeader
                    portalCenterpiece
                    bossEncounterCard
                    raidLootCard
                    systemRiskAlertCard
                    actionControls
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
            .scrollIndicators(.hidden)
        }
        .overlay(victoryOverlay)
        .overlay(gateBreakOverlay)
    }

    // MARK: - Subviews

    private var topRaidHeader: some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Text(viewModel.selectedDungeon.rank.rawValue.uppercased())
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color(hex: viewModel.selectedDungeon.rank.hexColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(hex: viewModel.selectedDungeon.rank.hexColor).opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: viewModel.selectedDungeon.rank.hexColor), lineWidth: 1)
                    )
                    .clipShape(Capsule())

                Text("GATE RAID: \(viewModel.selectedDungeon.name.uppercased())")
                    .font(.system(size: 14, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                Spacer()
            }

            HStack {
                Text("Target: \(viewModel.selectedDungeon.durationMinutes) Min Deep Work Session")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }

    private var portalCenterpiece: some View {
        DungeonPortalView(
            timeRemainingFormatted: viewModel.timeRemainingFormatted,
            timeElapsedFormatted: viewModel.timeElapsedFormatted,
            progressFraction: viewModel.progressFraction,
            rank: viewModel.selectedDungeon.rank,
            isRunning: viewModel.isRunning
        )
        .padding(.vertical, 8)
    }

    private var bossEncounterCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.systemCardSurface)
                        Image(systemName: "flame.fill")
                            .foregroundColor(.systemShadowPurple)
                    }
                    .frame(width: 28, height: 28)

                    Text(viewModel.selectedDungeon.bossName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("BOSS HP \(Int(viewModel.bossHPFraction * 100))%")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.systemShadowPurple)
            }

            // Boss Health Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.systemGridBorder)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.systemShadowPurple, .systemPenaltyCrimson],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * viewModel.bossHPFraction, 4))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.bossHPFraction)
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var raidLootCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles.rectangle.stack.fill")
                .font(.system(size: 20))
                .foregroundColor(.systemElectricCyan)

            VStack(alignment: .leading, spacing: 3) {
                Text("GUARANTEED CLEAR REWARDS")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.systemElectricCyan)

                Text("+\(viewModel.selectedDungeon.rewardExp) EXP  •  +3 INT  •  +\(viewModel.selectedDungeon.rewardGold) G")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var systemRiskAlertCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 16))
                .foregroundColor(.systemPenaltyCrimson)

            VStack(alignment: .leading, spacing: 2) {
                Text("DIMENSIONAL RUPTURE RISK")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)

                Text("Leaving the app or cancelling early will trigger a Gate Break penalty.")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(12)
        .holographicCard(cornerRadius: 12, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    private var actionControls: some View {
        VStack(spacing: 12) {
            // Play / Pause Button
            Button(action: {
                withAnimation {
                    viewModel.togglePlayPause()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))

                    Text(viewModel.isRunning ? "PAUSE CONCENTRATION" : "RESUME CONCENTRATION")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.systemPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 6)
            }
            .buttonStyle(.plain)

            // Abandon Button
            Button(action: {
                withAnimation {
                    viewModel.abandonRaid()
                }
            }) {
                Text("ABANDON RAID")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.systemCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.systemPenaltyCrimson.opacity(0.6), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Overlays

    @ViewBuilder
    private var victoryOverlay: some View {
        if viewModel.showVictoryOverlay {
            ZStack {
                Color.black.opacity(0.85).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.systemGateAmber)

                    Text("GATE CONQUERED!")
                        .font(.system(size: 26, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("Boss Vanquished: \(viewModel.selectedDungeon.bossName)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.systemPrimary)

                    Button("CLAIM DUNGEON LOOT") {
                        withAnimation { viewModel.showVictoryOverlay = false }
                    }
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.systemPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(24)
                .frame(maxWidth: 320)
                .holographicCard(cornerRadius: 20, glowColor: .systemElectricCyan, isGlowing: true)
            }
        }
    }

    @ViewBuilder
    private var gateBreakOverlay: some View {
        if viewModel.showGateBreakOverlay {
            ZStack {
                Color.black.opacity(0.85).ignoresSafeArea()
                VStack(spacing: 16) {
                    Image(systemName: "bolt.trianglebadge.exclamationmark.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("GATE BREAK OCCURRED")
                        .font(.system(size: 20, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("Focus session was terminated early. Dungeon monsters broke into the human world.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Button("DISMISS") {
                        withAnimation { viewModel.showGateBreakOverlay = false }
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(24)
                .frame(maxWidth: 320)
                .holographicCard(cornerRadius: 20, glowColor: .systemPenaltyCrimson, isGlowing: true)
            }
        }
    }
}

#Preview {
    DungeonTimerView()
}
