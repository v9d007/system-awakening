//
//  RadarPolygonMathTests.swift
//  SystemAwakeningTests
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import XCTest
@testable import SystemAwakening

final class RadarPolygonMathTests: XCTestCase {

    func testRadarVerticesCountAndOrder() {
        let stats: [StatType: Int] = [
            .strength: 50,
            .intelligence: 50,
            .agility: 50,
            .vitality: 50,
            .perception: 50
        ]

        let center = RadarPolygonMath.Point2D(x: 100.0, y: 100.0)
        let radius = 80.0
        let vertices = RadarPolygonMath.calculateVertices(
            stats: stats,
            maxStatValue: 100,
            center: center,
            radius: radius
        )

        // Exactly 5 vertices for a pentagon
        XCTAssertEqual(vertices.count, 5)

        // Vertex 0 (Strength) is at the top: x = center.x, y < center.y
        let topVertex = vertices[0]
        XCTAssertEqual(topVertex.x, 100.0, accuracy: 0.001)
        XCTAssertLessThan(topVertex.y, 100.0)
    }

    func testConcentricWebRingsGeneration() {
        let center = RadarPolygonMath.Point2D(x: 150.0, y: 150.0)
        let radius = 100.0
        let rings = RadarPolygonMath.calculateWebRings(
            center: center,
            radius: radius,
            stepPercentages: [0.2, 0.4, 0.6, 0.8, 1.0]
        )

        XCTAssertEqual(rings.count, 5)
        for ring in rings {
            XCTAssertEqual(ring.count, 5)
        }
    }
}
