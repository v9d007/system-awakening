//
//  RadarPolygonMath.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation

/// Pure mathematical engine calculating polar-to-Cartesian coordinates for the 5-Point Radar Polygon.
///
/// **Interview Rationale:**
/// - Decoupling Math from SwiftUI Rendering: Isolating vector calculations into a pure Domain math struct allows
///   instantaneous unit testing with precision floating point assertions, independent of view lifecycle or screen scales.
public struct RadarPolygonMath: Sendable {
    public struct Point2D: Equatable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// The 5 stats in canonical clockwise vertex order starting from top (Strength).
    public static let orderedStats: [StatType] = [
        .strength,     // Top (0 deg / -90 deg from Cartesian standard)
        .intelligence, // Top Right
        .agility,      // Bottom Right
        .vitality,     // Bottom Left
        .perception    // Top Left
    ]

    /// Calculates the 2D Cartesian vertices for the 5-point data polygon.
    ///
    /// - Parameters:
    ///   - stats: Current values for each of the 5 attributes.
    ///   - maxStatValue: The threshold representing 100% radius (e.g., 100).
    ///   - center: Center coordinate of the bounding area.
    ///   - radius: Outer radius of the polygon.
    ///   - minFloorRatio: Minimum visual offset (e.g., 0.15) to prevent zero-value vertices from collapsing to center.
    /// - Returns: Ordered array of 5 `Point2D` Cartesian points.
    public static func calculateVertices(
        stats: [StatType: Int],
        maxStatValue: Int = 100,
        center: Point2D,
        radius: Double,
        minFloorRatio: Double = 0.15
    ) -> [Point2D] {
        let n = Double(orderedStats.count)

        return orderedStats.enumerated().map { index, stat in
            let rawValue = Double(stats[stat] ?? 10)
            let normalized = max(min(rawValue / Double(maxStatValue), 1.0), 0.0)
            let scaledRadius = radius * (minFloorRatio + (1.0 - minFloorRatio) * normalized)

            // Top is at -π/2 radians
            let angle = -Double.pi / 2.0 + (Double(index) * 2.0 * Double.pi / n)

            let x = center.x + scaledRadius * cos(angle)
            let y = center.y + scaledRadius * sin(angle)

            return Point2D(x: x, y: y)
        }
    }

    /// Calculates the concentric background web pentagons (e.g. at 20%, 40%, 60%, 80%, 100%).
    public static func calculateWebRings(
        center: Point2D,
        radius: Double,
        stepPercentages: [Double] = [0.2, 0.4, 0.6, 0.8, 1.0]
    ) -> [[Point2D]] {
        let n = Double(orderedStats.count)

        return stepPercentages.map { fraction in
            let ringRadius = radius * fraction
            return (0..<orderedStats.count).map { index in
                let angle = -Double.pi / 2.0 + (Double(index) * 2.0 * Double.pi / n)
                let x = center.x + ringRadius * cos(angle)
                let y = center.y + ringRadius * sin(angle)
                return Point2D(x: x, y: y)
            }
        }
    }
}
