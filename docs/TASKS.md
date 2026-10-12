# End-to-End Master Task Breakdown (WBS) — "System: Awakening"

A comprehensive, production-grade roadmap covering **Design**, **Development**, and **Distribution**.

---

## Phase 1: Requirements, Specifications & Ground Rules
- [x] **Task 1.1:** Author Product Requirements Document ([`docs/PRD.md`](file:///Users/vinod/Documents/system-awakening/docs/PRD.md)).
- [x] **Task 1.2:** Author High-Level Design ([`docs/HLD.md`](file:///Users/vinod/Documents/system-awakening/docs/HLD.md)).
- [x] **Task 1.3:** Author Low-Level Design & Mathematical Models ([`docs/LLD.md`](file:///Users/vinod/Documents/system-awakening/docs/LLD.md)).
- [x] **Task 1.4:** Establish Coding Standards & Senior Interview Ground Rules ([`AGENTS.md`](file:///Users/vinod/Documents/system-awakening/AGENTS.md)).
- [x] **Task 1.5:** Initialize Git version control and project directory structure.

---

## Phase 2: Design System & Stitch Platform Prototyping
- [x] **Task 2.1:** Initialize the Stitch project using `StitchMCP` (`create_project`).
- [x] **Task 2.2:** Establish design system tokens targeting Apple HIG and Solo Leveling holographic HUD palette.
- [x] **Task 2.3:** Generate high-fidelity mobile mockups using Stitch MCP:
  - Screen 1: **Hunter Status Window & Radar Pentagon Chart** (Profile, level, rank badge, 5 stats).
  - Screen 2: **Daily Quest HUD & Progress Log** (Holographic quest popup, habit progress rings).
  - Screen 3: **Gate Raids & Dungeon Focus Timer** (Dungeon gate portal, countdown, boss encounter).
  - Screen 4: **Penalty Zone Emergency Alert** (Crimson hazard theme, countdown redemption task).
  - Screen 5: **System Shop & Hunter Inventory** (Gold currency vault, Streak Shields, custom real-world rewards).
- [ ] **Task 2.4:** Build reusable SwiftUI Design System primitives:
  - `SystemColors.swift` (Deep Void `#07080D`, Electric Cyan `#00E5FF`, Shadow Purple `#7C3AED`, Crimson `#FF2E63`, Amber `#F59E0B`).
  - `HolographicCardModifier.swift` (Glassmorphism with translucent material and cyan glow border).
  - `SystemHaptics.swift` (Rigid, medium, soft, and notification haptic triggers).

---

## Phase 3: Core Domain Layer & Gamification Engine
- [x] **Task 3.1:** Implement pure Domain Models:
  - `HunterRank.swift` (E to National Level hierarchy, XP thresholds, tier metadata).
  - `StatType.swift` (STR, INT, AGI, VIT, PER enums, icons, habit categories).
  - `DailyQuest.swift` (Value type, progress calculation, EXP & Gold rewards).
  - `HunterProfile.swift` (Leveling math, Gold balance, stat allocation, streak tracking).
  - `GateDungeon.swift` (Focus session models, dungeon tiers, clear rewards).
  - `SystemShopItem.swift` (Consumables like Streak Shields, and user-defined real-world rewards).
  - `BossRaid.swift` (Macro goals/projects modeled as epic boss battles with HP bars and milestones).
- [x] **Task 3.2:** Implement Radar Polygon Math Engine (`RadarPolygonMath.swift`):
  - Polar to Cartesian coordinates, 5-point geometry normalization, concentric web rings.
- [ ] **Task 3.3:** Implement Domain Use Cases:
  - `CompleteDailyQuestUseCase.swift` (Executes completion, grants EXP & Gold, handles level-up overflow).
  - `PurchaseShopItemUseCase.swift` (Validates gold balance, deducts cost, unlocks consumable or reward).
  - `DamageBossRaidUseCase.swift` (Applies focus session hours to Boss project HP).
  - `EvaluatePenaltyZoneUseCase.swift` (Midnight audit of essential quests).
- [x] **Task 3.4:** Comprehensive Domain Unit Testing:
  - `HunterProgressionTests.swift` (Leveling equations, EXP rollover, Gold earning/spending, Boss HP).
  - `RadarPolygonMathTests.swift` (Cartesian coordinates accuracy and bounds).

---

## Phase 4: Persistence & Data Layer (SwiftData + Swift 6 Concurrency)
- [ ] **Task 4.1:** Implement SwiftData Schema Models (`SDHunterProfile`, `SDDailyQuest`, `SDGateSession`, `SDShopItem`, `SDBossRaid`).
- [ ] **Task 4.2:** Implement `BackgroundDataActor: ModelActor` for safe async SwiftData operations off the main thread.
- [ ] **Task 4.3:** Implement Repository adapters conforming to Domain protocols.
- [ ] **Task 4.4:** In-memory integration testing for persistence layer.

---

## Phase 5: Presentation Layer (SwiftUI + @Observable MVVM)
- [ ] **Task 5.1:** Status Window HUD Module (`StatusWindowView.swift`, `RadarChartView.swift`).
- [ ] **Task 5.2:** Daily Quest Module (`DailyQuestListView.swift`, `QuestCardView.swift`).
- [ ] **Task 5.3:** Gate Dungeon Focus Timer Module (`DungeonTimerView.swift`, `DungeonTimerViewModel.swift`).
- [ ] **Task 5.4:** System Shop & Inventory Module (`SystemShopView.swift`, `SystemShopViewModel.swift`).
- [ ] **Task 5.5:** Penalty Zone Module (`PenaltyZoneView.swift`).
- [ ] **Task 5.6:** Root Navigation & HUD Tab Bar (`RootHUDView.swift`).

---

## Phase 6: Live Activities & Dynamic Island
- [ ] **Task 6.1:** Define `GateDungeonAttributes: ActivityAttributes`.
- [ ] **Task 6.2:** Implement Dynamic Island compact, minimal, and expanded views.
- [ ] **Task 6.3:** Implement Lock Screen Live Activity banner with real-time countdown timer.

---

## Phase 7: Polish, Motion, Audio & Senior Interview Defense
- [ ] **Task 7.1:** Custom Canvas glow shaders and "Arise" celebration particle effects on level-up.
- [ ] **Task 7.2:** Custom audio triggers (system ping, quest clear, penalty siren, "Arise" chant).
- [ ] **Task 7.3:** Xcode Instruments profiling (Time Profiler 120 FPS budget, Allocations & Leaks).
- [ ] **Task 7.4:** Author `docs/INTERVIEW_DEFENSE.md` detailing architectural tradeoffs and interview Q&As.

---

## Phase 8: Distribution, CI/CD & App Store Release
- [ ] **Task 8.1:** App Icon & holographic launch screen design for **System: Awakening**.
- [ ] **Task 8.2:** Fastlane pipeline (`Match`, `Gym`, `Deliver`, `TestFlight`).
- [ ] **Task 8.3:** GitHub Actions / Xcode Cloud CI pipeline.
- [ ] **Task 8.4:** App Store metadata and App Review guidelines compliance.
