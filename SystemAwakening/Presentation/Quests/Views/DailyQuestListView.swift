//
//  DailyQuestListView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// The Daily Quest Log HUD screen matching Stitch Screen 2.
@MainActor
public struct DailyQuestListView: View {
    @State private var viewModel: DailyQuestViewModel
    @State private var showCreateQuestSheet: Bool = false

    public init(viewModel: DailyQuestViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public init() {
        self.init(viewModel: DailyQuestViewModel.shared)
    }

    public var body: some View {
        ZStack {
            Color.systemBackground
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    topSystemHeader
                    questNotificationBanner
                    overallProgressCard
                    questsSectionView
                    claimRewardsButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 110) // Safe area breathing room above floating tab dock
            }
            .scrollIndicators(.hidden)
        }
        .overlay(claimSuccessOverlay)
        .sheet(isPresented: $showCreateQuestSheet) {
            CreateQuestModalView()
        }
    }

    // MARK: - Subviews

    private var topSystemHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.systemPrimary)
                    .frame(width: 8, height: 8)
                    .shadow(color: Color.systemPrimaryGlow, radius: 4)

                Text("SYSTEM DIRECTIVE")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }

            Spacer()

            // Issue New Directive Button
            Button(action: {
                showCreateQuestSheet = true
                SystemHaptics.shared.selectionTick()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 9, weight: .black))
                    Text("NEW DIRECTIVE")
                        .font(.system(size: 9.5, weight: .black, design: .monospaced))
                }
                .foregroundColor(Color.systemPrimary)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(Color.systemPrimary.opacity(0.12))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.systemPrimary.opacity(0.5), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Text("LOG // V2.5")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(Color.systemTextSecondary)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Color.systemCard)
                .clipShape(Capsule())
        }
    }

    private var questNotificationBanner: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header tag
            HStack {
                Text("[DAILY QUEST: PREPARATION TO BECOME STRONG]")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemTextPrimary)

                Spacer()
            }

            Text("Complete all objectives before 23:59:59 to prevent entering the Penalty Zone.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.systemTextSecondary)

            // Timer Badge
            HStack(spacing: 6) {
                Image(systemName: "hourglass")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.systemPrimary)

                Text("Time Remaining: \(viewModel.timeRemainingFormatted)")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.systemPrimary.opacity(0.12))
            .overlay(
                Capsule()
                    .stroke(Color.systemPrimary.opacity(0.6), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .padding(16)
        .holographicCard(cornerRadius: 16, glowColor: Color.systemPrimary, isGlowing: true)
    }

    private var overallProgressCard: some View {
        VStack(spacing: 8) {
            HStack {
                Text("DAILY CLEARANCE")
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundColor(Color.systemPrimary)

                Spacer()

                Text("\(viewModel.completedCount)/\(viewModel.totalCount) Cleared (\(viewModel.completionPercentageText))")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.systemCard)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(geo.size.width * viewModel.completionFraction, 8))
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.7), radius: 5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.completionFraction)
                }
            }
            .frame(height: 8)

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 10))
                        .foregroundColor(Color.systemPrimary)
                    Text("Penalty Zone Evasion Active")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.systemTextSecondary)
                }
                Spacer()
            }
            .padding(.top, 2)
        }
        .padding(14)
        .holographicCard(cornerRadius: 14)
    }

    private var questsSectionView: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.quests) { quest in
                QuestCardView(
                    quest: quest,
                    onIncrement: {
                        withAnimation {
                            viewModel.incrementQuest(id: quest.id)
                        }
                    },
                    onDelete: {
                        withAnimation {
                            viewModel.deleteQuest(id: quest.id)
                        }
                    }
                )
            }
        }
    }

    private var claimRewardsButton: some View {
        Button(action: {
            withAnimation {
                viewModel.claimRewards()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 14, weight: .bold))

                Text(viewModel.allCompleted ? "CLAIM DIRECTIVE REWARDS" : "COMPLETE ALL OBJECTIVES")
                    .font(.system(size: 13, weight: .black, design: .monospaced))
            }
            .foregroundColor(viewModel.allCompleted ? .black : Color.systemTextSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                viewModel.allCompleted
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [ThemeManager.shared.palette.expGradientStart, ThemeManager.shared.palette.expGradientEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    : AnyShapeStyle(Color.systemCard)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(viewModel.allCompleted ? Color.systemPrimary : Color.systemBorder, lineWidth: 1)
            )
            .shadow(color: viewModel.allCompleted ? Color.systemPrimaryGlow.opacity(0.6) : .clear, radius: 8)
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.allCompleted)
    }

    // MARK: - Claim Celebration Overlay

    @ViewBuilder
    private var claimSuccessOverlay: some View {
        if viewModel.showClaimAlert {
            ZStack {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color.systemPrimary)
                        .shadow(color: Color.systemPrimaryGlow.opacity(0.8), radius: 8)

                    Text("DIRECTIVES CLEARED!")
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(.white)

                    VStack(spacing: 6) {
                        Text("+\(viewModel.claimedExp) EXP GAINED")
                            .font(.system(size: 15, weight: .black, design: .monospaced))
                            .foregroundColor(Color.systemPrimary)

                        Text("LEVEL & STAT PROGRESSION UPDATED")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.systemTextSecondary)
                    }

                    Button(action: {
                        withAnimation {
                            viewModel.showClaimAlert = false
                        }
                    }) {
                        Text("CONFIRM")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.systemPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .frame(maxWidth: 320)
                .holographicCard(cornerRadius: 20, glowColor: Color.systemPrimaryGlow, isGlowing: true)
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    DailyQuestListView()
}
