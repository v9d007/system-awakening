# AGENTS.md — Ground Rules & Engineering Standards for "Arise"

Welcome to **"Arise"** — a production-grade, gamified Solo Leveling productivity app built natively for iOS 17+ using modern Swift & SwiftUI.

This project is built to the standards of senior and staff iOS engineering interviews. Every agent, contributor, and automated tool working on this codebase must adhere strictly to the following architectural contracts and development principles.

---

## 1. Core Architecture: Clean Architecture + MVVM + Observation

We strictly enforce Clean Architecture boundaries to maintain testability, separation of concerns, and framework independence.

```
Presentation (SwiftUI + @Observable ViewModels)
     │
     ▼ (depends on)
Domain (Pure Swift Models, Use Cases, Repository Protocols)
     ▲
     │ (implements)
Data (SwiftData @Model, Repositories, Background ModelActor)
```

### Layer Constraints
1. **Domain Layer (`Arise/Domain/`)**:
   - **Zero Framework Coupling:** Absolutely no imports of `SwiftUI`, `UIKit`, or `SwiftData`. Only `Foundation` and pure Swift standard library.
   - **Value Types:** All models (`HunterProfile`, `DailyQuest`, `HunterRank`, `StatType`) must be immutable Swift `struct` or `enum` types conforming to `Sendable`, `Identifiable`, `Codable`, and `Equatable`.
   - **Protocol-Oriented Programming (POP):** All repositories and services must be defined as protocols in `Domain/Repositories/` or `Domain/Services/`.
   - **Use Cases / Interactors:** Encapsulate business logic into single-responsibility interactor structs/classes (e.g., `CompleteQuestUseCase`).

2. **Presentation Layer (`Arise/Presentation/`)**:
   - **Observation Framework:** All ViewModels MUST use `@Observable` from the Swift standard `Observation` framework (iOS 17+).
   - **No Legacy Combine State:** Do NOT use `ObservableObject`, `@Published`, or `@StateObject` in new code.
   - **View State Ownership:** Views initialize ViewModels using `@State var viewModel: MyViewModel`. For two-way bindings to properties, use `@Bindable var viewModel = viewModel`.
   - **Actor Isolation:** All ViewModels interacting with SwiftUI views must be annotated with `@MainActor`.

3. **Data Layer (`Arise/Data/`)**:
   - **Decoupled Persistence:** SwiftData models (`SDHunterProfile`, `SDDailyQuest`) belong solely to the Data layer. They must never leak into the Domain or Presentation layers.
   - **Repository Mapping:** Repositories convert SwiftData `@Model` classes to pure Domain structs when returning data, and map Domain structs back to `@Model` for persistence.
   - **Background Concurrency:** Heavy database writes, daily quest resets, or migrations must execute on background threads via a custom Swift 6 `ModelActor`.

---

## 2. Modern Swift Concurrency & Memory Management

The project is compiled with **Swift 6 Language Mode** and `-strict-concurrency=complete`.

### Mandatory Rules:
1. **Actor Isolation & Sendability:**
   - Every type that crosses concurrency boundaries (Tasks, TaskGroups, Actors) must conform to `Sendable`.
   - Avoid mutable shared state. Use actors or immutable structs.
2. **MainActor Protection:**
   - UI updates, ViewModel state changes, and haptic/audio triggers must run on `@MainActor`.
   - Async background operations must yield back to `@MainActor` before updating state consumed by views.
3. **Structured Concurrency:**
   - Prefer structured concurrency (`async let`, `withTaskGroup`, `withThrowingTaskGroup`) over unstructured `Task { }`.
   - When an unstructured `Task` is required inside a View or ViewModel, always store a reference to cancel it upon view disappearance (`.onDisappear` or `deinit`), or use the SwiftUI `.task { }` view modifier which cancels automatically on view dismissal.
4. **Memory Leak Prevention:**
   - Always avoid retain cycles in closures. Use `[weak self]` in escaping closures when referencing class instances.
   - Monitor memory lifecycle: ViewModels must cleanly `deinit` when their host view is popped from navigation.

---

## 3. Solo Leveling "System HUD" & Apple HIG Balance

The app features a holographic RPG aesthetic inspired by the *Solo Leveling* anime/manhwa, balanced against Apple's Human Interface Guidelines (HIG).

### Visual Tokens:
- **Deep Void Background:** `#07080D` (Pure obsidian dark canvas).
- **Surface Elevation:** `#0F121D` (Translucent dark slate glass cards with `UltraThinMaterial`).
- **Electric Cyan Glow:** `#00E5FF` (System notification borders, active quest rings, level badges).
- **Shadow Sovereign Purple:** `#7C3AED` (Monarch skills, S-Rank emblems, high-tier focus states).
- **Penalty Crimson:** `#FF2E63` (Penalty zone alerts, failed timers, emergency challenges).
- **Gate Amber:** `#F59E0B` (Dungeon alerts and rare achievements).

### Apple HIG Compliance Rules:
1. **Touch Targets:** All interactive buttons and controls must have an active hit area of at least **44x44 points**.
2. **Typography & Dynamic Type:** Support dynamic scale with system font metrics (e.g., `.font(.system(.title3, design: .monospaced, weight: .bold))`).
3. **Accessibility:** Every custom graphical component (such as the 5-Stat Pentagon Radar Chart) must provide `.accessibilityLabel` and `.accessibilityValue` descriptions for VoiceOver.
4. **Haptics:** Use native `SensoryFeedback` and `UIImpactFeedbackGenerator(style: .rigid / .medium)` thoughtfully to accompany physical actions (level up, quest completion, stat increment).

---

## 4. Senior iOS Interview Commentary Convention

Because this codebase is built as a premier technical portfolio, all significant architectural choices, algorithms, or structural tradeoffs must be accompanied by an inline **Interview Rationale** docstring.

### Standard Format:
```swift
/// [Feature/Type Name]
///
/// **Interview Rationale:**
/// - Why this approach: [Explain why this was chosen]
/// - Alternatives considered: [E.g., SwiftData @Model in views vs Pure Domain Structs]
/// - Trade-offs: [Memory, performance, complexity, boilerplate]
```

---

## 5. Testing & Code Quality Bar

- **Domain Logic:** 100% test coverage on leveling equations, EXP rollover, stat calculations, and rank promotions using the modern **Swift Testing** framework (`@Test`, `#expect`).
- **ViewModels:** Unit tested using mock repositories.
- **Zero Warnings:** Code must compile with 0 warnings under `-strict-concurrency=complete` and SwiftLint/SwiftFormat guidelines.
