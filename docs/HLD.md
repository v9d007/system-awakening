# High-Level Design (HLD) — "Arise"

**Architecture Style:** Clean Architecture + MVVM + Observation Framework  
**Target:** iOS 17.0+ (Swift 6 Strict Concurrency)  
**Primary Persistence:** SwiftData with Actor-isolated Background Saves

---

## 1. System Architecture Overview

The system strictly divides concerns into three distinct layers according to Clean Architecture principles:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│                                                                        │
│   SwiftUI Views               ◄──────►   @Observable ViewModels        │
│   (HUD / RadarChart / Quests)            (Isolated to @MainActor)      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Calls Interactors
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                           DOMAIN LAYER                                 │
│                                                                        │
│   Use Cases / Interactors                                              │
│   • CompleteDailyQuestUseCase                                          │
│   • CalculateHunterProgressionUseCase                                  │
│   • ProcessDungeonSessionUseCase                                       │
│                                                                        │
│   Domain Repository Protocols (POP)                                    │
│   • HunterProfileRepositoryProtocol                                    │
│   • DailyQuestRepositoryProtocol                                       │
│   • DungeonSessionRepositoryProtocol                                   │
│                                                                        │
│   Pure Domain Entities (Immutable Sendable Structs)                   │
│   • HunterProfile, HunterRank, StatType, DailyQuest, GateDungeon       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    ▲ Implements Protocols
                                    │
┌────────────────────────────────────────────────────────────────────────┐
│                            DATA LAYER                                  │
│                                                                        │
│   Repository Implementations (SwiftDataHunterRepository, etc.)         │
│   SwiftData Persistence Schema (@Model: SDHunterProfile, SDDailyQuest) │
│   BackgroundModelActor (Swift 6 ModelActor for async DB mutations)     │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Unidirectional Data Flow (UDF)

Within each feature module, data flows strictly unidirectionally:
1. **User Action:** The user interacts with a SwiftUI View (e.g., taps "+" to allocate a stat point, or checks off a daily push-up quest).
2. **ViewModel Intent:** The View calls an `async` method on its `@Observable @MainActor` ViewModel (e.g., `viewModel.completeQuest(id:)`).
3. **Domain Interactor:** The ViewModel invokes a domain Use Case (e.g., `CompleteDailyQuestUseCase`).
4. **Repository & Background Actor:** The Use Case requests persistence through a Repository protocol. The Repository delegates writes to `BackgroundModelActor`, keeping the main thread free.
5. **State Update:** The Use Case returns the updated pure `HunterProfile` value type back to the ViewModel. The ViewModel updates its internal state.
6. **Fine-Grained View Re-render:** Thanks to the `@Observable` macro, only the specific SwiftUI subviews reading the mutated properties re-render.

---

## 3. Swift 6 Concurrency & Threading Model

### 3.1 MainActor Protection
- All UI-facing components (`SwiftUI.View`, `@Observable` ViewModels, `HapticManager`) are explicitly decorated with `@MainActor`.
- Guarantees 0 main-thread race conditions or UI update warnings from Xcode.

### 3.2 ModelActor for Database Isolation
- In Swift 6, accessing `ModelContext` across different threads causes fatal data race crashes.
- We implement `BackgroundModelActor: ModelActor`, Apple's official concurrency-safe pattern for SwiftData:
```swift
@ModelActor
actor BackgroundDataActor {
    func saveQuestProgress(questId: UUID, progress: Double) throws {
        // Safe execution on the actor's dedicated executor
    }
}
```

### 3.3 Sendability Guarantees
- All entities crossing between the Data actor, Domain use cases, and MainActor view models conform to `Sendable`.
- By using pure Swift `struct` value types for Domain entities, sendability is naturally preserved with zero synchronization overhead.

---

## 4. Key Architectural Tradeoffs (Senior Interview Talking Points)

| Decision | Alternative Considered | Rationale & Trade-off |
| :--- | :--- | :--- |
| **Pure Struct Domain vs SwiftData `@Model` in Views** | Binding `@Model` directly to SwiftUI via `@Query` | **Chosen:** Pure Domain Structs decouple business logic from database schema, making unit testing lightning-fast and actor-safe.<br>**Tradeoff:** Requires manual mapping between `@Model` and Domain structs. |
| **Observation Framework (`@Observable`) vs Combine (`ObservableObject`)** | `ObservableObject` + `@Published` | **Chosen:** `@Observable` tracks property access at compile-time via Swift macros; views only re-render when properties they actually access change. Eliminates Combine boilerplate. |
| **Clean Architecture Use Cases vs Fat ViewModels** | Direct Repository calls from ViewModels | **Chosen:** Use Cases ensure single-responsibility domain rules (e.g., leveling math, EXP carryover) can be reused across widgets, App Clips, and Live Activities. |
