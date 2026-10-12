//
//  GateDungeon.swift
//  Arise
//
//  Created for "Arise" — Gamified Solo Leveling Productivity App
//

import Foundation

/// Status state machine for a Gate focus session.
public enum GateStatus: String, Codable, Sendable {
    case available
    case inProgress
    case completed
    case gateBreakFailed // Session abandoned or interrupted
}

/// Domain model representing a Dungeon Gate focus block (Pomodoro / Deep Work).
public struct GateDungeon: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var rank: HunterRank
    public var durationMinutes: Int
    public var rewardExp: Int
    public var rewardStatPillar: StatType
    public var bossName: String
    public var status: GateStatus

    public init(
        id: UUID = UUID(),
        name: String,
        rank: HunterRank,
        durationMinutes: Int,
        rewardExp: Int,
        rewardStatPillar: StatType = .intelligence,
        bossName: String,
        status: GateStatus = .available
    ) {
        self.id = id
        self.name = name
        self.rank = rank
        self.durationMinutes = durationMinutes
        self.rewardExp = rewardExp
        self.rewardStatPillar = rewardStatPillar
        self.bossName = bossName
        self.status = status
    }

    /// Presets matching standard focus intervals
    public static let standardPresets: [GateDungeon] = [
        GateDungeon(name: "Goblin Outpost", rank: .e, durationMinutes: 25, rewardExp: 50, rewardStatPillar: .agility, bossName: "Hobgoblin Leader"),
        GateDungeon(name: "Shadow Wolf Den", rank: .d, durationMinutes: 45, rewardExp: 90, rewardStatPillar: .perception, bossName: "Steel-Fanged Lycan"),
        GateDungeon(name: "Golem Sanctuary", rank: .c, durationMinutes: 60, rewardExp: 140, rewardStatPillar: .strength, bossName: "Ancient Granite Golem"),
        GateDungeon(name: "High Orc Keep", rank: .b, durationMinutes: 90, rewardExp: 220, rewardStatPillar: .intelligence, bossName: "Kargalgan Shaman"),
        GateDungeon(name: "Red Gate (Extreme)", rank: .s, durationMinutes: 120, rewardExp: 400, rewardStatPillar: .vitality, bossName: "Ice Monarch's Vanguard")
    ]
}
