//
//  SystemShopViewModel.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import Foundation
import Observation

/// ViewModel managing the System Shop and custom reward redemptions.
@Observable
@MainActor
public final class SystemShopViewModel {
    public var goldBalance: Int
    public var selectedCategory: ShopItemType
    public var systemItems: [SystemShopItem]
    public var customRewards: [SystemShopItem]
    public var showPurchaseSuccessAlert: Bool
    public var showInsufficientFundsAlert: Bool
    public var lastPurchasedItem: SystemShopItem?
    public var showAddCustomRewardSheet: Bool

    private let hapticService: HapticServiceProtocol

    public init(
        goldBalance: Int,
        systemItems: [SystemShopItem],
        customRewards: [SystemShopItem],
        hapticService: HapticServiceProtocol
    ) {
        self.goldBalance = goldBalance
        self.selectedCategory = .consumable
        self.systemItems = systemItems
        self.customRewards = customRewards
        self.showPurchaseSuccessAlert = false
        self.showInsufficientFundsAlert = false
        self.lastPurchasedItem = nil
        self.showAddCustomRewardSheet = false
        self.hapticService = hapticService
    }

    public convenience init(hapticService: HapticServiceProtocol) {
        self.init(
            goldBalance: 1450,
            systemItems: SystemShopItem.defaultSystemItems,
            customRewards: SystemShopItem.sampleCustomRewards,
            hapticService: hapticService
        )
    }

    public convenience init(
        goldBalance: Int = 1450,
        systemItems: [SystemShopItem]? = nil,
        customRewards: [SystemShopItem]? = nil
    ) {
        self.init(
            goldBalance: goldBalance,
            systemItems: systemItems ?? SystemShopItem.defaultSystemItems,
            customRewards: customRewards ?? SystemShopItem.sampleCustomRewards,
            hapticService: SystemHaptics.shared
        )
    }

    public var displayedItems: [SystemShopItem] {
        switch selectedCategory {
        case .consumable: return systemItems
        case .customRealReward: return customRewards
        }
    }

    public func purchaseItem(_ item: SystemShopItem) {
        if goldBalance >= item.costGold {
            goldBalance -= item.costGold
            lastPurchasedItem = item
            showPurchaseSuccessAlert = true
            hapticService.questCompleted()
        } else {
            showInsufficientFundsAlert = true
            hapticService.penaltyAlert()
        }
    }

    public func addCustomReward(title: String, description: String, cost: Int) {
        guard !title.isEmpty, cost > 0 else { return }
        let newItem = SystemShopItem(
            title: title,
            itemDescription: description,
            costGold: cost,
            itemType: .customRealReward,
            iconSystemName: "star.fill"
        )
        customRewards.append(newItem)
        showAddCustomRewardSheet = false
        hapticService.selectionTick()
    }
}
