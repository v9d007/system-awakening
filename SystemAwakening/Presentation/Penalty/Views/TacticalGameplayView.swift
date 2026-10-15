//
//  TacticalGameplayView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Penalty Zone Tactical Survival Gameplay HUD matching Stitch Screen 6 (d2da439ef3984c70b54d69b0330389c1).
@MainActor
public struct TacticalGameplayView: View {
    @Bindable var viewModel: PenaltyZoneViewModel
    @State private var scanAngle: Double = 0.0

    public init(viewModel: PenaltyZoneViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            Color.systemDeepVoid
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    topTacticalHeader
                    emergencyQuestHeroBanner
                    hunterBioTelemetryCard
                    tacticalRadarCard
                    survivalObjectivesCard
                    emergencyQuickbarCard
                    systemStreamLogCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 110) // Safe area breathing room above bottom dock
            }
            .scrollIndicators(.hidden)
        }
        .sheet(isPresented: $viewModel.showItemDetailModal) {
            ItemInspectionModalView(viewModel: viewModel)
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                scanAngle = 360.0
            }
        }
    }

    // MARK: - Subviews

    private var topTacticalHeader: some View {
        VStack(spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.systemPenaltyCrimson)
                        .frame(width: 8, height: 8)
                        .shadow(color: .systemPenaltyCrimson, radius: 4)

                    Text("[DIMENSION: PENALTY ZONE // HOSTILE]")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                Spacer()

                Text("DISASTER")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPenaltyCrimson.opacity(0.4))
                    .clipShape(Capsule())

                // Return to Alert mode button
                Button(action: {
                    withAnimation {
                        viewModel.mode = .alert
                    }
                }) {
                    Image(systemName: "exclamationmark.octagon")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.systemPenaltyCrimson)
                        .padding(6)
                        .background(Color.systemCardSurface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            HStack {
                HStack(spacing: 6) {
                    Text("TACTICAL HUD")
                        .font(.system(size: 12, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("//")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.gray)

                    Text("SURVIVE: \(viewModel.timeRemainingFormatted)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "FF909E"))
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "battery.alert.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.systemPenaltyCrimson)
                    Text("FATIGUE \(Int(viewModel.fatigue))%")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.systemCardSurface)
                .clipShape(Capsule())
            }
        }
        .padding(12)
        .holographicCard(cornerRadius: 12, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    private var emergencyQuestHeroBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("QUEST: SURVIVE")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.systemPenaltyCrimson)
                    .clipShape(Capsule())

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.systemPenaltyCrimson)
                        .frame(width: 6, height: 6)
                    Text("DIMENSION LOCK: ACTIVE")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("ENDLESS DESOLATION DUNE")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                HStack {
                    Text("ELAPSED // REMAINING")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("\(viewModel.timeElapsedFormatted) / 04:00:00")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.systemDeepVoid)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.systemPenaltyCrimson, Color(hex: "FF6E84"), .systemElectricCyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * viewModel.survivalProgressFraction, 8))
                    }
                }
                .frame(height: 6)
            }

            // Environmental Warning
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.systemPenaltyCrimson)

                Text("Environmental Penalty: Extreme Heat & Gravitational Pressure (+250% Fatigue Rate)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14, glowColor: .systemPenaltyCrimson, isGlowing: false)
    }

    private var hunterBioTelemetryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 13))
                        .foregroundColor(.systemElectricCyan)

                    Text("BIO-TELEMETRY OVERLAY")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("CRITICAL STRAIN")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPenaltyCrimson.opacity(0.18))
                    .clipShape(Capsule())
            }

            // Health Pool (HP)
            VStack(spacing: 4) {
                HStack {
                    Text("HP VITAL INTEGRITY")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemElectricCyan)
                    Spacer()
                    Text("\(viewModel.hp) / \(viewModel.maxHP) (\(Int(viewModel.hpFraction * 100))%)")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.systemDeepVoid)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.systemElectricCyan, Color(hex: "00B4D8")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * viewModel.hpFraction, 6))
                            .shadow(color: .systemElectricCyan.opacity(0.7), radius: 4)
                    }
                }
                .frame(height: 8)
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Mana Pool (MP)
            VStack(spacing: 4) {
                HStack {
                    Text("MP MANA RESERVOIR")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemShadowPurple)
                    Spacer()
                    Text("\(viewModel.mp) / \(viewModel.maxMP) [DEPLETED]")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.systemDeepVoid)
                        Capsule()
                            .fill(Color.systemShadowPurple)
                            .frame(width: max(geo.size.width * viewModel.mpFraction, 6))
                    }
                }
                .frame(height: 6)
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Fatigue Gauge
            VStack(spacing: 4) {
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "skull.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.systemPenaltyCrimson)
                        Text("FATIGUE GAUGE")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.systemPenaltyCrimson)
                    }
                    Spacer()
                    Text("\(Int(viewModel.fatigue)) / 100 [\(Int(viewModel.fatigue))%]")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.systemDeepVoid)
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "E51152"), .systemPenaltyCrimson],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * viewModel.fatigueFraction, 6))
                            .shadow(color: .systemPenaltyCrimson, radius: 6)
                    }
                }
                .frame(height: 10)

                Text("At 100 Fatigue, instantaneous coma & penalty death sequence triggers.")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            .padding(10)
            .background(Color.systemCardSurface)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Active Buffs / Debuffs
            HStack(spacing: 6) {
                buffChip(icon: "drop.fill", title: "Dehydration (-20% Agi)", color: .systemPenaltyCrimson)
                buffChip(icon: "bolt.fill", title: "Adrenaline (+15% Spd)", color: .systemElectricCyan)
                buffChip(icon: "lock.fill", title: "Shadows Sealed", color: .systemShadowPurple)
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private func buffChip(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Color.systemCardSurface)
        .clipShape(Capsule())
    }

    private var tacticalRadarCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "scope")
                        .font(.system(size: 13))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("HOSTILE PROXIMITY SCANNER")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("SWARM CLOSING")
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundColor(.systemPenaltyCrimson)
            }

            HStack(spacing: 12) {
                // 2D Circular Radar Canvas
                ZStack {
                    // Concentric Web Circles
                    Circle()
                        .stroke(Color.systemGridBorder, lineWidth: 1)
                        .frame(width: 130, height: 130)
                    Circle()
                        .stroke(Color.systemGridBorder, lineWidth: 1)
                        .frame(width: 90, height: 90)
                    Circle()
                        .stroke(Color.systemGridBorder, lineWidth: 1)
                        .frame(width: 50, height: 50)

                    // Crosshair Lines
                    Rectangle()
                        .fill(Color.systemGridBorder)
                        .frame(width: 130, height: 1)
                    Rectangle()
                        .fill(Color.systemGridBorder)
                        .frame(width: 1, height: 130)

                    // Rotating Sonar Line
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.systemPenaltyCrimson.opacity(0.8), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 1.5, height: 65)
                        .offset(y: -32.5)
                        .rotationEffect(.degrees(scanAngle))

                    // Center Hunter Blip (Cyan)
                    Circle()
                        .fill(Color.systemElectricCyan)
                        .frame(width: 8, height: 8)
                        .shadow(color: .systemElectricCyan, radius: 5)

                    // Hostile 1 Blip (Centipede - Top Right)
                    Circle()
                        .fill(Color.systemPenaltyCrimson)
                        .frame(width: 7, height: 7)
                        .shadow(color: .systemPenaltyCrimson, radius: 4)
                        .offset(x: 34, y: -30)

                    // Hostile 2 Blip (Subterranean - Bottom Left)
                    Circle()
                        .fill(Color.systemShadowPurple)
                        .frame(width: 6, height: 6)
                        .shadow(color: .systemShadowPurple, radius: 4)
                        .offset(x: -28, y: 26)
                }
                .frame(width: 140, height: 140)
                .background(Color.systemDeepVoid)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Targets Info List
                VStack(spacing: 8) {
                    ForEach(viewModel.hostiles) { hostile in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Text(hostile.name)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Spacer()
                                Text(hostile.rankTitle)
                                    .font(.system(size: 8, weight: .black, design: .monospaced))
                                    .foregroundColor(hostile.isSubterranean ? .systemShadowPurple : .systemPenaltyCrimson)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 2)
                                    .background(Color.systemCardSurface)
                                    .clipShape(Capsule())
                            }

                            HStack {
                                Text(hostile.isSubterranean ? "Position:" : "Distance:")
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                Text(hostile.isSubterranean ? "-\(hostile.depthMeters ?? 18)m (Lurking)" : "\(hostile.distanceMeters)m ↓ (\(hostile.speedDescription))")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(hostile.isSubterranean ? Color(hex: "AF88FF") : .systemPenaltyCrimson)
                            }
                        }
                        .padding(8)
                        .background(Color.systemCardSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var survivalObjectivesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checklist")
                        .font(.system(size: 13))
                        .foregroundColor(.systemElectricCyan)

                    Text("SURVIVAL DIRECTIVES")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("1 / 3 COMPLETE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
            }

            VStack(spacing: 8) {
                ForEach(viewModel.objectives) { objective in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: objective.isCompleted ? "checkmark.circle.fill" : (objective.isExtremeDanger ? "exclamationmark.circle.fill" : "circle"))
                            .font(.system(size: 14))
                            .foregroundColor(objective.isCompleted ? .systemElectricCyan : (objective.isExtremeDanger ? .systemPenaltyCrimson : .gray))
                            .padding(.top, 2)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(objective.title)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(objective.isCompleted ? .gray : .white)
                                .strikethrough(objective.isCompleted, color: .gray)

                            Text(objective.subtitle)
                                .font(.system(size: 9, weight: .medium, design: .monospaced))
                                .foregroundColor(objective.isCompleted ? .systemElectricCyan : (objective.isExtremeDanger ? .systemPenaltyCrimson : .gray))
                        }

                        Spacer()
                    }
                    .padding(8)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var emergencyQuickbarCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.white)

                    Text("EMERGENCY SLOTS")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("TAP TO EXECUTE")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                // Slot 1: Dash Evasion
                Button(action: {
                    withAnimation {
                        viewModel.performDashEvasion()
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "figure.run")
                                .font(.system(size: 14))
                                .foregroundColor(.systemElectricCyan)
                            Spacer()
                            Text(viewModel.isEvasionOnCooldown ? "CD: 4s" : "READY")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(.systemElectricCyan)
                        }
                        Text("DASH EVASION")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("+8 Fatigue per use")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.systemGridBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isEvasionOnCooldown)
                .opacity(viewModel.isEvasionOnCooldown ? 0.6 : 1.0)

                // Slot 2: Stealth Cloak (Disabled MP)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "eye.slash.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                        Text("NO MP")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .foregroundColor(.systemPenaltyCrimson)
                    }
                    Text("STEALTH CLOAK")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Req. 200 MP (1,150)")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(Color.systemCardSurface.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.systemGridBorder, lineWidth: 1)
                )

                // Slot 3: Purified Potion (Interactive)
                Button(action: {
                    withAnimation {
                        viewModel.showItemDetailModal = true
                    }
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "cross.vial.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.systemPenaltyCrimson)
                            Spacer()
                            Text(viewModel.isPotionAdministering ? "USE..." : "QTY: \(viewModel.purifiedPotionsRemaining)")
                                .font(.system(size: 8, weight: .black, design: .monospaced))
                                .foregroundColor(.systemPenaltyCrimson)
                        }
                        Text("PURIFIED POTION")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                        Text("-20 Fatigue // +2k HP")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .background(Color.systemCardSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(viewModel.purifiedPotionsRemaining > 0 ? Color.systemPenaltyCrimson.opacity(0.6) : Color.systemGridBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.purifiedPotionsRemaining == 0)
                .opacity(viewModel.purifiedPotionsRemaining == 0 ? 0.5 : 1.0)

                // Slot 4: Arise Soldier (Locked)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                        Image(systemName: "lock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }
                    Text("ARISE // SOLDIER")
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .foregroundColor(.gray)
                    Text("Penalty Zone Lock")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                .padding(10)
                .background(Color.systemCardSurface.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.systemGridBorder, lineWidth: 1)
                )
            }
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var systemStreamLogCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SYSTEM STREAM LOG // LIVE")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.gray)

                Spacer()

                Circle()
                    .fill(Color.systemPenaltyCrimson)
                    .frame(width: 6, height: 6)
            }

            VStack(alignment: .leading, spacing: 4) {
                ForEach(viewModel.systemLogs) { log in
                    Text("[\(log.tag)] \(log.message)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color(hex: log.colorHex))
                        .lineLimit(2)
                }
            }
        }
        .padding(12)
        .holographicCard(cornerRadius: 12)
    }
}

#Preview {
    TacticalGameplayView(viewModel: PenaltyZoneViewModel())
}
