# End-to-End Master Task Breakdown (WBS) — "Arise"

A comprehensive, production-grade roadmap covering **Design**, **Development**, and **Distribution**.

---

## Phase 1: Requirements, Specifications & Ground Rules
- [x] **Task 1.1:** Author Product Requirements Document ([`docs/PRD.md`](file:///Users/vinod/Documents/Arise/docs/PRD.md)).
- [x] **Task 1.2:** Author High-Level Design ([`docs/HLD.md`](file:///Users/vinod/Documents/Arise/docs/HLD.md)).
- [x] **Task 1.3:** Author Low-Level Design & Mathematical Models ([`docs/LLD.md`](file:///Users/vinod/Documents/Arise/docs/LLD.md)).
- [x] **Task 1.4:** Establish Coding Standards & Senior Interview Ground Rules ([`AGENTS.md`](file:///Users/vinod/Documents/Arise/AGENTS.md)).
- [x] **Task 1.5:** Initialize Git version control and project directory structure.

---

## Phase 2: Design System & Stitch Platform Prototyping
- [ ] **Task 2.1:** Initialize the Arise Stitch project using `StitchMCP` (`create_project`).
- [ ] **Task 2.2:** Formulate and upload design system specification (`DESIGN.md`) targeting Apple Human Interface Guidelines and Solo Leveling holographic HUD palette.
- [ ] **Task 2.3:** Generate high-fidelity mobile mockups using Stitch MCP:
  - Screen 1: **Hunter Status Window & Radar Pentagon Chart** (Profile, level, rank badge, 5 stats).
  - Screen 2: **Daily Quest HUD & Progress Log** (Holographic quest popup, habit progress rings).
  - Screen 3: **Gate Raids & Dungeon Focus Timer** (Dungeon gate portal, countdown, boss raid status).
  - Screen 4: **Penalty Zone Emergency Alert** (Crimson hazard theme, countdown redemption task).
- [ ] **Task 2.4:** Build reusable SwiftUI Design System primitives:
  - `SystemColors.swift` (Deep Void `#07080D`, Electric Cyan `#00E5FF`, Shadow Purple `#7C3AED`, Crimson `#FF2E63`).
  - `SystemTypography.swift` (Custom monospaced headers, SF Pro dynamic scaling).
  - `HolographicCardModifier.swift` (Glassmorphism with translucent material and cyan glow border).
  - `SystemHaptics.swift` (Rigid, medium, soft, and notification haptic triggers).

---

## Phase 3: Core Domain Layer & Gamification Math Engine
- [ ] **Task 3.1:** Implement pure Domain Models:
  - `HunterRank.swift` (E to National Level hierarchy, XP thresholds, tier metadata).
  - `StatType.swift` (STR, INT, AGI, VIT, PER enums, icons, habit categories).
  - `DailyQuest.swift` (Value type, progress calculation, completion checks).
  - `HunterProfile.swift` (Leveling math, stat allocation, streak tracking).
  - `GateDungeon.swift` (Focus session models, dungeon tiers, clear rewards).
- [ ] **Task 3.2:** Implement Radar Polygon Math Engine (`RadarPolygonMath.swift`):
  - Polar to Cartesian coordinates, 5-point geometry normalization, bounding box calculations.
- [ ] **Task 3.3:** Implement Domain Use Cases:
  - `CompleteDailyQuestUseCase.swift` (Executes completion, grants EXP, handles level-up overflow).
  - `AllocateStatPointUseCase.swift` (Deducts unallocated points, increments stat, recalcs profile).
  - `EvaluatePenaltyZoneUseCase.swift` (Midnight audit of essential quests).
- [ ] **Task 3.4:** Comprehensive Domain Unit Testing:
  - `HunterProgressionTests.swift` (Verifies non-linear EXP equation, rollover, rank promotions).
  - `RadarChartMathTests.swift` (Verifies Cartesian coordinate accuracy and bounds).

---

## Phase 4: Persistence & Data Layer (SwiftData + Swift 6 Concurrency)
- [ ] **Task 4.1:** Implement SwiftData Schema Models:
  - `SDHunterProfile.swift`
  - `SDDailyQuest.swift`
  - `SDGateSession.swift`
- [ ] **Task 4.2:** Implement `BackgroundDataActor: ModelActor` for safe async SwiftData saves off the main thread.
- [ ] **Task 4.3:** Implement Repository adapters conforming to Domain protocols:
  - `SwiftDataHunterProfileRepository.swift`
  - `SwiftDataDailyQuestRepository.swift`
- [ ] **Task 4.4:** In-memory integration testing for persistence layer.

---

## Phase 5: Presentation Layer (SwiftUI + @Observable MVVM)
- [ ] **Task 5.1:** Status Window HUD Module:
  - `StatusWindowView.swift`
  - `RadarChartView.swift` (Interactive Canvas with glowing polygon and animated vertices).
  - `StatusWindowViewModel.swift` (`@Observable @MainActor`).
- [ ] **Task 5.2:** Daily Quest Module:
  - `DailyQuestListView.swift`
  - `QuestCardView.swift` (Glowing progress rings, micro-interaction buttons).
  - `DailyQuestViewModel.swift` (Live progress updates, level-up celebration trigger).
- [ ] **Task 5.3:** Gate Dungeon Focus Timer Module:
  - `DungeonTimerView.swift` (Circular portal animation, timer controls).
  - `DungeonTimerViewModel.swift` (Timer state machine, Gate Break detection).
- [ ] **Task 5.4:** Penalty Zone Module:
  - `PenaltyZoneView.swift` (Crimson hazard theme, emergency countdown challenge).
- [ ] **Task 5.5:** Root Navigation & HUD Tab Bar:
  - `RootHUDView.swift` (Custom holographic bottom HUD bar).

---

## Phase 6: Live Activities & Dynamic Island
- [ ] **Task 6.1:** Define `GateDungeonAttributes: ActivityAttributes`.
- [ ] **Task 6.2:** Implement Dynamic Island compact, minimal, and expanded views.
- [ ] **Task 6.3:** Implement Lock Screen Live Activity banner with real-time countdown timer.

---

## Phase 7: Polish, Motion, Audio & Senior Interview Defense
- [ ] **Task 7.1:** Custom Canvas glow shaders and particle celebration effects on level-up.
- [ ] **Task 7.2:** Custom audio triggers (system ping, quest clear, penalty siren).
- [ ] **Task 7.3:** Xcode Instruments profiling:
  - Time Profiler audit: Ensure 120 FPS render budget (< 8.33ms / 16.6ms).
  - Allocations & Leaks: Confirm 0 retain cycles during view navigation.
- [ ] **Task 7.4:** Author `docs/INTERVIEW_DEFENSE.md` documenting architecture tradeoffs and answers to staff iOS interview questions.

---

## Phase 8: Distribution, CI/CD & App Store Release
- [ ] **Task 8.1:** App Icon & holographic launch screen design.
- [ ] **Task 8.2:** Fastlane pipeline (`Match`, `Gym`, `Deliver`, `TestFlight`).
- [ ] **Task 8.3:** GitHub Actions / Xcode Cloud CI pipeline (build, test, lint on pull request).
- [ ] **Task 8.4:** App Store privacy nutrition label, screenshots, and review guidelines audit.
