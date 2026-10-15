//
//  SystemShopItem.swift
//  System: Awakening
//
//  Created for "System: Awakening" (Arise) — Gamified Solo Leveling Productivity App
//

import Foundation

/// Defines the category of item available in the System Shop.
public enum ShopItemType: String, Codable, Sendable {
    /// In-app system consumables that modify gameplay rules.
    case consumable
    /// User-defined real-life rewards (e.g. 1 hour gaming, cheat meal, weekend trip).
    case customRealReward
}

/// Domain model representing an item available in the System Shop.
///
/// **Interview Rationale:**
/// - Extensible Value Types: By separating `consumable` vs `customRealReward`, we support both built-in RPG utility
///   (like Streak Shields) and extrinsic user-driven real-life motivation, without muddying business rules.
public struct SystemShopItem: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var itemDescription: String
    public var costGold: Int
    public var itemType: ShopItemType
    public var iconSystemName: String
    public var isAvailable: Bool

    public init(
        id: UUID = UUID(),
        title: String,
        itemDescription: String,
        costGold: Int,
        itemType: ShopItemType,
        iconSystemName: String,
        isAvailable: Bool = true
    ) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.costGold = costGold
        self.itemType = itemType
        self.iconSystemName = iconSystemName
        self.isAvailable = isAvailable
    }

    /// Default system catalog presets.
    public nonisolated static let defaultSystemItems: [SystemShopItem] = [
        SystemShopItem(
            title: "Streak Shield",
            itemDescription: "Protects your active streak and nullifies one emergency Penalty Zone trip.",
            costGold: 250,
            itemType: .consumable,
            iconSystemName: "shield.fill"
        ),
        SystemShopItem(
            title: "Red Gate Key",
            itemDescription: "Grants access to extreme 120-minute deep work Red Gate raids with 2x EXP drops.",
            costGold: 500,
            itemType: .consumable,
            iconSystemName: "key.fill"
        ),
        SystemShopItem(
            title: "Elixir of Vitality",
            itemDescription: "Instantly resets fatigue accumulation and grants a temporary 10% focus boost.",
            costGold: 150,
            itemType: .consumable,
            iconSystemName: "cross.vial.fill"
        )
    ]

    /// Default examples of user custom real-world rewards.
    public nonisolated static let sampleCustomRewards: [SystemShopItem] = [
        SystemShopItem(
            title: "1-Hour Guilt-Free Gaming",
            itemDescription: "Redeem 1 hour of uninterrupted video game time.",
            costGold: 300,
            itemType: .customRealReward,
            iconSystemName: "gamecontroller.fill"
        ),
        SystemShopItem(
            title: "Cheat Meal Feast",
            itemDescription: "Order your favorite takeout dinner guilt-free.",
            costGold: 800,
            itemType: .customRealReward,
            iconSystemName: "fork.knife"
        ),
        SystemShopItem(
            title: "New Tech / Book Purchase",
            itemDescription: "Buy that new gadget or programming book you've been eyeing.",
            costGold: 3000,
            itemType: .customRealReward,
            iconSystemName: "bag.fill"
        )
    ]
}
