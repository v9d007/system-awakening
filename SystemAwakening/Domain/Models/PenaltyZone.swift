//
//  PenaltyZone.swift
//  System: Awakening
//
//  Created for "System: Awakening" (Arise) — Gamified Solo Leveling Productivity App
//

import Foundation

/// Active view state mode for the Penalty Zone dimension.
public enum PenaltyZoneMode: String, Codable, Sendable {
    /// Screen 5: Severe Penalty Emergency Alert with circular countdown dial and directives.
    case alert
    /// Screen 6: Tactical Survival Gameplay HUD with 2D hostile proximity scanner, bio-telemetry, and combat quickbar.
    case tacticalGameplay
}

/// An enemy monster detected in the Penalty Zone dimension (e.g. Sand Centipede).
public struct HostileEntity: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var rankTitle: String
    public var distanceMeters: Int
    public var depthMeters: Int?
    public var isSubterranean: Bool
    public var relativeAngleDegrees: Double // 0° to 360° on radar polar grid
    public var relativeRadiusRatio: Double  // 0.0 (center) to 1.0 (perimeter)
    public var speedDescription: String

    public init(
        id: UUID = UUID(),
        name: String,
        rankTitle: String,
        distanceMeters: Int,
        depthMeters: Int? = nil,
        isSubterranean: Bool = false,
        relativeAngleDegrees: Double,
        relativeRadiusRatio: Double,
        speedDescription: String = "Normal"
    ) {
        self.id = id
        self.name = name
        self.rankTitle = rankTitle
        self.distanceMeters = distanceMeters
        self.depthMeters = depthMeters
        self.isSubterranean = isSubterranean
        self.relativeAngleDegrees = relativeAngleDegrees
        self.relativeRadiusRatio = relativeRadiusRatio
        self.speedDescription = speedDescription
    }

    /// Default hostile entities detected in the Endless Desolation Dune penalty sector.
    public nonisolated static let defaultHostiles: [HostileEntity] = [
        HostileEntity(
            name: "Sand Centipede x3",
            rankTitle: "RANK B+",
            distanceMeters: 142,
            isSubterranean: false,
            relativeAngleDegrees: 48,
            relativeRadiusRatio: 0.72,
            speedDescription: "Fast"
        ),
        HostileEntity(
            name: "Dune Stalker",
            rankTitle: "RANK B",
            distanceMeters: 65,
            depthMeters: 18,
            isSubterranean: true,
            relativeAngleDegrees: 215,
            relativeRadiusRatio: 0.58,
            speedDescription: "Lurking"
        )
    ]
}

/// A survival directive requirement that must be satisfied to evade penalty zone demotion.
public struct SurvivalObjective: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var subtitle: String
    public var isCompleted: Bool
    public var progressText: String
    public var isExtremeDanger: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        isCompleted: Bool = false,
        progressText: String = "",
        isExtremeDanger: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.isCompleted = isCompleted
        self.progressText = progressText
        self.isExtremeDanger = isExtremeDanger
    }

    /// Default directives catalog.
    public nonisolated static let defaultObjectives: [SurvivalObjective] = [
        SurvivalObjective(
            title: "Evade Initial Swarm Surge (01h 00m)",
            subtitle: "COMPLETED // +500 EXP CREDITED",
            isCompleted: true,
            progressText: "1/1"
        ),
        SurvivalObjective(
            title: "Slay 1 Sand Centipede OR Endure 02h 17m 42s",
            subtitle: "IN PROGRESS • Eliminated: 0 / 1",
            isCompleted: false,
            progressText: "0 / 1"
        ),
        SurvivalObjective(
            title: "Maintain Fatigue Level Below 100",
            subtitle: "EXTREME DANGER (84/100) • Limit sustained sprints",
            isCompleted: false,
            progressText: "84 / 100",
            isExtremeDanger: true
        )
    ]
}

/// Monospaced live system log entry from the dimensional telemetry stream.
public struct SystemStreamLog: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var tag: String
    public var message: String
    public var colorHex: String

    public init(
        id: UUID = UUID(),
        tag: String,
        message: String,
        colorHex: String
    ) {
        self.id = id
        self.tag = tag
        self.message = message
        self.colorHex = colorHex
    }

    public nonisolated static let defaultLogs: [SystemStreamLog] = [
        SystemStreamLog(
            tag: "SYSTEM WARNING",
            message: "Ground tremor detected beneath coordinate (X:48, Y:92). Burrowing Stalker surfacing.",
            colorHex: "FF2E63" // Penalty Crimson
        ),
        SystemStreamLog(
            tag: "TELEMETRY",
            message: "Ambient heat index: 54°C. Hunter perspiration exceeding safe threshold.",
            colorHex: "75757C" // Muted Outline
        ),
        SystemStreamLog(
            tag: "SURVIVAL HINT",
            message: "Centipedes rely on thermal radiation. Avoid sustained sprints on dune crests.",
            colorHex: "00E5FF" // Electric Cyan
        )
    ]
}
