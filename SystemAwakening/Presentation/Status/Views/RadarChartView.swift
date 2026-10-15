//
//  RadarChartView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// An interactive 5-Point Pentagon Radar Chart faithfully reproducing the Stitch specification:
/// - Generous, commanding pentagon scale spanning the full width of the card
/// - Razor-sharp, theme-colored outer pentagon border and radial spoke lines
/// - Faded ambient radial bloom radiating from the core without blurring artifacts
/// - Luminous breathing animation for the mid data polygon and radiant core
/// - Precision dual-tone node beads (STR/AGI/VIT in Solar Gold/Monarch Purple, INT/PER in Electric Azure Cyan)
/// - Stitch-faithful dark vertex badges with theme-colored borders
public struct RadarChartView: View {
    public let stats: [StatType: Int]
    public let maxStatValue: Int
    public let unallocatedPoints: Int
    public let onAllocateStat: ((StatType) -> Void)?

    @State private var isBreathing: Bool = false

    public init(
        stats: [StatType: Int],
        maxStatValue: Int = 100,
        unallocatedPoints: Int = 0,
        onAllocateStat: ((StatType) -> Void)? = nil
    ) {
        self.stats = stats
        self.maxStatValue = maxStatValue
        self.unallocatedPoints = unallocatedPoints
        self.onAllocateStat = onAllocateStat
    }

    public var body: some View {
        GeometryReader { geometry in
            let centerPoint = RadarPolygonMath.Point2D(
                x: geometry.size.width / 2.0,
                y: geometry.size.height / 2.0 - 2.0
            )
            // Generous scale matching the Stitch design
            let chartRadius = min(geometry.size.width * 0.36, 112.0)
            let palette = ThemeManager.shared.palette

            let vertices = RadarPolygonMath.calculateVertices(
                stats: stats,
                maxStatValue: maxStatValue,
                center: centerPoint,
                radius: chartRadius
            )

            ZStack {
                // 1. Background Web & Faded Ambient Radial Bloom
                Canvas { context, _ in
                    drawBackgroundWeb(
                        context: context,
                        center: centerPoint,
                        radius: chartRadius,
                        palette: palette
                    )
                }

                // 2. Mid Color Portion: Soft Radiant Center Flare
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                palette.primaryAccentGlow.opacity(isBreathing ? 0.60 : 0.35),
                                palette.primaryAccent.opacity(isBreathing ? 0.30 : 0.14),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: chartRadius * (isBreathing ? 0.55 : 0.40)
                        )
                    )
                    .frame(width: chartRadius * 1.1, height: chartRadius * 1.1)
                    .position(x: centerPoint.x, y: centerPoint.y)
                    .blur(radius: isBreathing ? 8 : 4)

                // 3. Mid Color Portion: Breathing Data Polygon
                RadarPolygonShape(vertices: vertices)
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                palette.primaryAccentGlow.opacity(isBreathing ? 0.65 : 0.42),
                                palette.primaryAccent.opacity(isBreathing ? 0.38 : 0.22),
                                palette.primaryAccent.opacity(0.10)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: chartRadius * (isBreathing ? 0.85 : 0.70)
                        )
                    )
                    .overlay(
                        RadarPolygonShape(vertices: vertices)
                            .stroke(palette.primaryAccentGlow, lineWidth: 1.8)
                            .shadow(
                                color: palette.primaryAccentGlow.opacity(isBreathing ? 0.75 : 0.35),
                                radius: isBreathing ? 6 : 3
                            )
                    )
                    .scaleEffect(
                        isBreathing ? 1.02 : 0.985,
                        anchor: UnitPoint(x: centerPoint.x / geometry.size.width, y: centerPoint.y / geometry.size.height)
                    )

                // 4. Glowing Circular Node Beads with Dual-Tone Theme Colors
                ForEach(Array(RadarPolygonMath.orderedStats.enumerated()), id: \.offset) { index, stat in
                    if index < vertices.count {
                        let vertex = vertices[index]
                        let nodeColor = statColor(for: stat, palette: palette)

                        ZStack {
                            // Pulsing halo
                            Circle()
                                .fill(nodeColor.opacity(isBreathing ? 0.40 : 0.20))
                                .frame(width: isBreathing ? 12 : 9, height: isBreathing ? 12 : 9)

                            // Solid node bead with crisp white center
                            Circle()
                                .fill(nodeColor)
                                .frame(width: 7.5, height: 7.5)
                                .overlay(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 3.0, height: 3.0)
                                )
                                .shadow(color: nodeColor.opacity(0.85), radius: 3)
                        }
                        .position(x: vertex.x, y: vertex.y)
                        .scaleEffect(
                            isBreathing ? 1.02 : 0.985,
                            anchor: UnitPoint(x: centerPoint.x / geometry.size.width, y: centerPoint.y / geometry.size.height)
                        )
                    }
                }

                // 5. Stitch-faithful Vertex Badges (STR, INT, VIT, PER, AGI)
                ForEach(Array(RadarPolygonMath.orderedStats.enumerated()), id: \.offset) { index, stat in
                    if index < vertices.count {
                        let vertex = vertices[index]
                        let statValue = stats[stat] ?? 10

                        vertexOverlay(
                            stat: stat,
                            value: statValue,
                            vertex: vertex,
                            center: centerPoint,
                            chartRadius: chartRadius,
                            palette: palette
                        )
                    }
                }
            }
        }
        .frame(height: 300)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.8)
                .repeatForever(autoreverses: true)
            ) {
                isBreathing = true
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Hunter Attribute Radar Chart")
    }

    // MARK: - Canvas Drawing Helpers

    private func drawBackgroundWeb(
        context: GraphicsContext,
        center: RadarPolygonMath.Point2D,
        radius: Double,
        palette: ThemePalette
    ) {
        let webRings = RadarPolygonMath.calculateWebRings(center: center, radius: radius)

        // 1. Faded Ambient Glow inside Outer Pentagon
        if let outerRing = webRings.last, let first = outerRing.first {
            var outerPath = Path()
            outerPath.move(to: CGPoint(x: first.x, y: first.y))
            for point in outerRing.dropFirst() {
                outerPath.addLine(to: CGPoint(x: point.x, y: point.y))
            }
            outerPath.closeSubpath()

            // Subtle dark translucent fill
            context.fill(outerPath, with: .color(palette.cardSurface.opacity(0.65)))

            // Soft radial bloom from center
            let radialBloom = Gradient(colors: [
                palette.primaryAccent.opacity(0.18),
                palette.primaryAccent.opacity(0.05),
                Color.clear
            ])
            context.fill(
                outerPath,
                with: .radialGradient(
                    radialBloom,
                    center: CGPoint(x: center.x, y: center.y),
                    startRadius: 0,
                    endRadius: radius
                )
            )
        }

        // 2. Concentric Pentagons (Razor-sharp lines matching Stitch)
        for (idx, ring) in webRings.enumerated() {
            var path = Path()
            guard let first = ring.first else { continue }
            path.move(to: CGPoint(x: first.x, y: first.y))
            for point in ring.dropFirst() {
                path.addLine(to: CGPoint(x: point.x, y: point.y))
            }
            path.closeSubpath()
            let isOuter = idx == (webRings.count - 1)

            if isOuter {
                // Crisp theme-colored outer ring (thin and sharp, exactly like Stitch!)
                context.stroke(
                    path,
                    with: .color(palette.primaryAccentGlow.opacity(0.30)),
                    lineWidth: 2.2
                )
                context.stroke(
                    path,
                    with: .color(palette.primaryAccent),
                    lineWidth: 1.4
                )
            } else {
                // Inner concentric rings with cybernetic dashed styling
                let isDashed = (idx == 1 || idx == 2)
                if isDashed {
                    context.stroke(
                        path,
                        with: .color(palette.primaryAccent.opacity(0.32)),
                        style: StrokeStyle(lineWidth: 0.8, dash: [4, 4])
                    )
                } else {
                    context.stroke(
                        path,
                        with: .color(palette.primaryAccent.opacity(0.22)),
                        lineWidth: 0.8
                    )
                }
            }
        }

        // 3. Spoke Lines from Center to Outer Vertices (Theme-Colored)
        if let outerRing = webRings.last {
            for vertex in outerRing {
                var spokePath = Path()
                spokePath.move(to: CGPoint(x: center.x, y: center.y))
                spokePath.addLine(to: CGPoint(x: vertex.x, y: vertex.y))
                context.stroke(
                    spokePath,
                    with: .color(palette.primaryAccent.opacity(0.40)),
                    lineWidth: 0.8
                )
            }
        }
    }

    // MARK: - Dual-Tone Stat Color Mapper

    private func statColor(for stat: StatType, palette: ThemePalette) -> Color {
        switch stat {
        case .strength, .agility, .vitality:
            // Martial physical attributes adopt primary theme color (Gold in Solar, Violet in Monarch)
            return palette.primaryAccent
        case .intelligence, .perception:
            // Mana / sensory attributes adopt electric azure cyan accent
            return palette.secondaryAccent
        }
    }

    // MARK: - Vertex Overlay Component

    @ViewBuilder
    private func vertexOverlay(
        stat: StatType,
        value: Int,
        vertex: RadarPolygonMath.Point2D,
        center: RadarPolygonMath.Point2D,
        chartRadius: Double,
        palette: ThemePalette
    ) -> some View {
        let dx = vertex.x - center.x
        let dy = vertex.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        let normalizedDx = distance > 0 ? dx / distance : 0
        let normalizedDy = distance > 0 ? dy / distance : -1

        let labelOffsetDistance = chartRadius + 23.0
        let labelX = center.x + normalizedDx * labelOffsetDistance
        let labelY = center.y + normalizedDy * labelOffsetDistance
        let statThemeColor = statColor(for: stat, palette: palette)

        VStack(spacing: 1) {
            Text(stat.abbr)
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .foregroundColor(statThemeColor)

            Text("\(value)")
                .font(.system(size: 11, weight: .heavy, design: .monospaced))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(Color(hex: "0E121E").opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(statThemeColor.opacity(0.85), lineWidth: 0.9)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 3, y: 1)
        .position(x: labelX, y: labelY)
    }
}

/// Standalone Shape for the dynamic 5-point data polygon enabling hardware-accelerated animations and gradients.
public struct RadarPolygonShape: Shape {
    public let vertices: [RadarPolygonMath.Point2D]

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = vertices.first else { return path }
        path.move(to: CGPoint(x: first.x, y: first.y))
        for pt in vertices.dropFirst() {
            path.addLine(to: CGPoint(x: pt.x, y: pt.y))
        }
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.systemDeepVoid.ignoresSafeArea()
        RadarChartView(
            stats: [
                .strength: 45,
                .intelligence: 62,
                .agility: 38,
                .vitality: 50,
                .perception: 35
            ],
            unallocatedPoints: 3
        )
    }
}
