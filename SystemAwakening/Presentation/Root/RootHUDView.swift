//
//  RootHUDView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Canonical tab definitions for the Solo Leveling System HUD.
public enum HUDTab: String, CaseIterable, Identifiable, Sendable {
    case home = "HOME"
    case tasks = "TASKS"
    case penalty = "PENALTY"
    case profile = "PROFILE"

    public var id: String { rawValue }

    public var iconSystemName: String {
        switch self {
        case .home: return "shield.fill"
        case .tasks: return "checklist"
        case .penalty: return "exclamationmark.triangle.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}

/// The Root Navigation HUD uniting the 4 core modules (Home, Tasks, Penalty Zone, Profile)
/// with a balanced custom holographic bottom dock.
@MainActor
public struct RootHUDView: View {
    @State private var selectedTab: HUDTab = .home

    public init(selectedTab: HUDTab = .home) {
        self._selectedTab = State(initialValue: selectedTab)
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            Color.systemBackground
                .ignoresSafeArea()

            // Active Screen Content
            Group {
                switch selectedTab {
                case .home:
                    HomeDashboardView(
                        onNavigateToTasks: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedTab = .tasks
                            }
                        },
                        onNavigateToPenalty: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedTab = .penalty
                            }
                        }
                    )
                case .tasks:
                    DailyQuestListView()
                case .penalty:
                    PenaltyZoneView(showsDismissButton: false)
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Holographic Bottom Navigation Dock (4 canonical tabs)
            bottomHolographicDock
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Bottom Holographic Dock

    private var bottomHolographicDock: some View {
        HStack(spacing: 0) {
            ForEach(HUDTab.allCases) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.systemCard.opacity(0.92))
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.systemPrimary.opacity(0.4), lineWidth: 1)
        )
        .shadow(
            color: Color.systemPrimaryGlow.opacity(0.25),
            radius: 12,
            y: 4
        )
    }

    private func tabButton(for tab: HUDTab) -> some View {
        let isSelected = selectedTab == tab
        let isPenalty = tab == .penalty
        let activeColor = isPenalty ? Color.systemPenaltyCrimson : Color.systemPrimary
        let activeGlow = isPenalty ? Color.systemPenaltyCrimson : Color.systemPrimaryGlow

        return Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
            if isPenalty {
                SystemHaptics.shared.penaltyAlert()
            } else {
                SystemHaptics.shared.selectionTick()
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.iconSystemName)
                    .font(.system(size: 17, weight: isSelected ? .black : .semibold))
                    .foregroundColor(
                        isSelected ? activeColor : Color.systemTextSecondary
                    )
                    .shadow(
                        color: isSelected ? activeGlow.opacity(0.8) : .clear,
                        radius: 6
                    )
                    .frame(height: 22)

                Text(tab.rawValue)
                    .font(.system(size: 9, weight: isSelected ? .black : .bold, design: .monospaced))
                    .foregroundColor(
                        isSelected ? (isPenalty ? Color.systemPenaltyCrimson : Color.systemTextPrimary) : Color.systemTextSecondary
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootHUDView()
}
