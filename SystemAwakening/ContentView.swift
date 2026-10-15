//
//  ContentView.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// Root container managing offline app lifecycle synchronization, midnight rollover checks, and live timers.
@MainActor
public struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    public init() {}

    public var body: some View {
        RootHUDView()
            .preferredColorScheme(.dark)
            .onAppear {
                DailyCycleManager.shared.checkAndExecuteMidnightRollover()
                DailyQuestViewModel.shared.startLiveCountdownTimer()
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    DailyCycleManager.shared.checkAndExecuteMidnightRollover()
                    DailyQuestViewModel.shared.startLiveCountdownTimer()
                case .background, .inactive:
                    DailyQuestViewModel.shared.stopLiveCountdownTimer()
                    DailyQuestViewModel.shared.saveQuestsToStorage()
                @unknown default:
                    break
                }
            }
    }
}

#Preview {
    ContentView()
}
