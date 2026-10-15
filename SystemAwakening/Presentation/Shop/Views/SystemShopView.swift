//
//  SystemShopView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// The System Shop & Hunter Inventory screen matching Stitch Screen 4.
@MainActor
public struct SystemShopView: View {
    @State private var viewModel: SystemShopViewModel
    @State private var newRewardTitle = ""
    @State private var newRewardDescription = ""
    @State private var newRewardCost = "500"

    public init(viewModel: SystemShopViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public init() {
        self.init(viewModel: SystemShopViewModel())
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    shopHeader
                    goldWealthCard
                    categoryPicker
                    itemsGrid
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 120) // Safe area breathing room above floating tab dock
            }
            .scrollIndicators(.hidden)

            // Floating + Button to add custom real-life rewards (positioned above bottom dock)
            if viewModel.selectedCategory == .customRealReward {
                floatingAddButton
                    .padding(.trailing, 20)
                    .padding(.bottom, 96)
            }
        }
        .sheet(isPresented: $viewModel.showAddCustomRewardSheet) {
            addRewardSheet
        }
        .overlay(purchaseSuccessOverlay)
        .overlay(insufficientFundsOverlay)
    }

    // MARK: - Subviews

    private var shopHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemGateAmber)
                    .frame(width: 8, height: 8)
                    .shadow(color: .systemGateAmber, radius: 4)

                Text("[SYSTEM DIRECTIVE // REWARD STORE]")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.systemGateAmber)

                Spacer()

                Text("ONLINE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.systemPrimary.opacity(0.15))
                    .clipShape(Capsule())
            }

            Text("Exchange Earned Gold For Consumables & Real-Life Rewards")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    private var goldWealthCard: some View {
        HStack(spacing: 16) {
            // High-Tech Coin Emblem
            ZStack {
                Circle()
                    .fill(Color.systemGateAmber.opacity(0.2))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle().stroke(Color.systemGateAmber, lineWidth: 1.5)
                    )

                Image(systemName: "circle.circle.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(.systemGateAmber)
                    .shadow(color: .systemGateAmber.opacity(0.8), radius: 6)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("HUNTER VAULT BALANCE")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundColor(.gray)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(viewModel.goldBalance)")
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    Text("GOLD")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .foregroundColor(.systemGateAmber)
                }

                HStack(spacing: 12) {
                    Text("Lifetime: 8,920 G")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)

                    Text("Daily Boost: +15%")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)
                }
            }

            Spacer()
        }
        .padding(16)
        .holographicCard(cornerRadius: 16, glowColor: .systemGateAmber, isGlowing: false)
    }

    private var categoryPicker: some View {
        HStack(spacing: 8) {
            categoryTabButton(title: "System Consumables", type: .consumable)
            categoryTabButton(title: "Real-Life Rewards", type: .customRealReward)
        }
    }

    private func categoryTabButton(title: String, type: ShopItemType) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedCategory = type
            }
        }) {
            Text(title)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(viewModel.selectedCategory == type ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    viewModel.selectedCategory == type
                        ? AnyShapeStyle(Color.systemPrimary)
                        : AnyShapeStyle(Color.systemCard)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.selectedCategory == type ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    private var itemsGrid: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.displayedItems) { item in
                shopItemRow(item: item)
            }
        }
    }

    private func shopItemRow(item: SystemShopItem) -> some View {
        HStack(spacing: 14) {
            // Item Icon Box
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.systemCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.systemBorder, lineWidth: 1)
                    )

                Image(systemName: item.iconSystemName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(item.itemType == .consumable ? Color.systemPrimary : .systemGateAmber)
            }
            .frame(width: 44, height: 44)

            // Description
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.systemTextPrimary)

                Text(item.itemDescription)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color.systemTextSecondary)
                    .lineLimit(2)

                HStack(spacing: 4) {
                    Image(systemName: "circle.circle.fill")
                        .font(.system(size: 9))
                    Text("\(item.costGold) Gold")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .foregroundColor(.systemGateAmber)
                .padding(.top, 2)
            }

            Spacer()

            // Buy / Redeem Button
            Button(action: {
                withAnimation {
                    viewModel.purchaseItem(item)
                }
            }) {
                Text(item.itemType == .consumable ? "BUY" : "REDEEM")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Color.systemPrimary)
                    .clipShape(Capsule())
                    .shadow(color: Color.systemPrimaryGlow.opacity(0.6), radius: 5)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var floatingAddButton: some View {
        Button(action: {
            viewModel.showAddCustomRewardSheet = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 13, weight: .black))
                Text("ADD REWARD")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
            }
            .foregroundColor(.black)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.systemPrimary)
            .clipShape(Capsule())
            .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 8)
        }
    }

    // MARK: - Add Custom Reward Sheet

    private var addRewardSheet: some View {
        NavigationStack {
            ZStack {
                Color.systemBackground.ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("CREATE REAL-WORLD REWARD")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemPrimary)

                    TextField("Reward Title (e.g. 1h Gaming)", text: $newRewardTitle)
                        .padding()
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color.systemTextPrimary)

                    TextField("Description", text: $newRewardDescription)
                        .padding()
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color.systemTextPrimary)

                    TextField("Gold Cost (e.g. 500)", text: $newRewardCost)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.systemCard)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .foregroundColor(Color.systemTextPrimary)

                    Button("ADD TO REWARD STORE") {
                        if let cost = Int(newRewardCost) {
                            viewModel.addCustomReward(
                                title: newRewardTitle,
                                description: newRewardDescription,
                                cost: cost
                            )
                        }
                    }
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.systemPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Spacer()
                }
                .padding(20)
            }
            .preferredColorScheme(.dark)
        }
    }

    // MARK: - Overlays

    @ViewBuilder
    private var purchaseSuccessOverlay: some View {
        if viewModel.showPurchaseSuccessAlert, let item = viewModel.lastPurchasedItem {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: 14) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color.systemPrimary)

                    Text("TRANSACTION CONFIRMED")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(Color.systemTextPrimary)

                    Text("Acquired: \(item.title)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.systemGateAmber)

                    Button("PROCEED") {
                        viewModel.showPurchaseSuccessAlert = false
                    }
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.systemPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)
                .frame(maxWidth: 300)
                .holographicCard(cornerRadius: 16, glowColor: Color.systemPrimaryGlow, isGlowing: true)
            }
        }
    }

    @ViewBuilder
    private var insufficientFundsOverlay: some View {
        if viewModel.showInsufficientFundsAlert {
            ZStack {
                Color.black.opacity(0.8).ignoresSafeArea()
                VStack(spacing: 14) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 38))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("INSUFFICIENT GOLD")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(.systemPenaltyCrimson)

                    Text("Complete more daily quests or dungeon raids to earn Gold.")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Color.systemTextSecondary)
                        .multilineTextAlignment(.center)

                    Button("DISMISS") {
                        viewModel.showInsufficientFundsAlert = false
                    }
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.systemCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(20)
                .frame(maxWidth: 300)
                .holographicCard(cornerRadius: 16, glowColor: .systemPenaltyCrimson, isGlowing: true)
            }
        }
    }
}

#Preview {
    SystemShopView()
}
