//
//  StatusWindowView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// The centerpiece Hunter Status Window HUD for System: Awakening.
///
/// **Interview Rationale:**
/// - Observation Consumption Pattern: Declares `@State private var viewModel: StatusWindowViewModel` for
///   lifecycle ownership. Child views read directly from the `@Observable` instance with fine-grained reactivity.
/// - Swift 6 Actor-Safe Initializers: Avoids default parameter expressions for `@MainActor`-isolated types,
///   instead providing explicit parameterless and dependency-injected initializer overloads.
@MainActor
public struct StatusWindowView: View {
    @State private var viewModel: StatusWindowViewModel

    public init(viewModel: StatusWindowViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public init() {
        self.init(viewModel: StatusWindowViewModel())
    }

    public var body: some View {
        ZStack {
            // Dynamic Theme Background
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerView
                    expSectionView
                    radarSectionView
                    unallocatedPointsBanner
                    statsListView
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
            .scrollIndicators(.hidden)
        }
        .overlay(levelUpOverlay)
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(spacing: 12) {
            // Theme Switcher & System Directive Bar
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.systemPrimary)
                        .frame(width: 7, height: 7)
                        .shadow(color: Color.systemPrimaryGlow, radius: 4)

                    Text("SYSTEM DIRECTIVE // V2.5")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }

                Spacer()

                // Theme Switcher Toggle Pill
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        ThemeManager.shared.toggleTheme()
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: ThemeManager.shared.currentTheme.iconSystemName)
                            .font(.system(size: 10, weight: .black))
                        Text(ThemeManager.shared.currentTheme.displayName)
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                    }
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.systemCard)
                    .overlay(
                        Capsule()
                            .stroke(Color.systemPrimary.opacity(0.6), lineWidth: 1)
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.systemPrimaryGlow.opacity(0.3), radius: 4)
                }
                .buttonStyle(.plain)
            }

            // Hunter Identity Row
            HStack(alignment: .center, spacing: 12) {
                // Rank Badge Emblem
                RankBadgeView(rank: viewModel.rank, showTitle: false, size: .medium)

                // Hunter Name, Title & Level
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(viewModel.hunterName)
                            .font(.system(size: 18, weight: .black, design: .default))
                            .foregroundColor(Color.systemTextPrimary)

                        Text("LVL \(viewModel.level)")
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.systemPrimary)
                            .clipShape(Capsule())
                    }

                    Text(viewModel.rank.canonicalTitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.systemTextSecondary)
                }

                Spacer()

                // Gold Vault Balance Pill
                HStack(spacing: 5) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.systemGateAmber)

                    Text("\(viewModel.gold)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.systemCard)
                .overlay(
                    Capsule()
                        .stroke(Color.systemGateAmber.opacity(0.6), lineWidth: 1)
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .holographicCard(cornerRadius: 16)
    }

    private var expSectionView: some View {
        VStack(spacing: 8) {
            HStack {
                Text("EXP PROGRESSION")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)

                Spacer()

                Text("\(viewModel.expText) (\(viewModel.expPercentageText))")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)
            }

            // High-Tech Neon EXP Gauge
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.systemCard)
                        .overlay(
                            Capsule()
                                .stroke(Color.systemBorder, lineWidth: 1)
                        )

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * viewModel.expProgress, 8))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.expProgress)
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .holographicCard(cornerRadius: 14)
    }

    private var radarSectionView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "hexagon.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color.systemPrimary)

                Text("ATTRIBUTE MATRIX")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemTextPrimary)

                Spacer()

                Text("5-AXIS")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemTextSecondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemCard)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)

            RadarChartView(
                stats: viewModel.stats,
                unallocatedPoints: viewModel.unallocatedPoints,
                onAllocateStat: { stat in
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        viewModel.allocateStat(type: stat)
                    }
                }
            )
            .padding(.vertical, 8)
        }
        .holographicCard(cornerRadius: 18)
    }

    @ViewBuilder
    private var unallocatedPointsBanner: some View {
        if viewModel.canAllocateStats {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 26, height: 26)
                    .background(Color.systemPrimary)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("SYSTEM NOTIFICATION")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)

                    Text("\(viewModel.unallocatedPoints) Unallocated Stat Points Available")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.systemTextPrimary)
                }

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.systemPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .holographicCard(cornerRadius: 12, glowColor: Color.systemPrimary, isGlowing: true)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private var statsListView: some View {
        VStack(spacing: 10) {
            ForEach(StatType.allCases) { stat in
                StatAllocationRow(
                    stat: stat,
                    value: viewModel.stats[stat] ?? 10,
                    canAllocate: viewModel.canAllocateStats,
                    onAllocate: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            viewModel.allocateStat(type: stat)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Level-Up Celebratory Overlay

    @ViewBuilder
    private var levelUpOverlay: some View {
        if viewModel.showLevelUpAlert {
            ZStack {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("LEVEL UP!")
                        .font(.system(size: 30, weight: .black, design: .monospaced))
                        .foregroundColor(.systemElectricCyan)
                        .shadow(color: .systemElectricCyan.opacity(0.9), radius: 10)

                    Text("You have reached Level \(viewModel.level)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text("+ \(viewModel.lastLevelGained * 3) Stat Points Awarded")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.systemGateAmber)

                    Button(action: {
                        withAnimation {
                            viewModel.showLevelUpAlert = false
                        }
                    }) {
                        Text("ARISE")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.systemElectricCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .systemElectricCyan.opacity(0.8), radius: 8)
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .frame(maxWidth: 320)
                .holographicCard(cornerRadius: 20, glowColor: .systemElectricCyan, isGlowing: true)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    StatusWindowView()
}
