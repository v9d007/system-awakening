# Product Requirements Document (PRD) — "System: Awakening"

**Project Title:** System: Awakening  
**Subtitle:** Gamified Solo Leveling Productivity App  
**Platform:** Native iOS 17.0+ (Swift 6 Strict Concurrency, modern SwiftUI)  
**Target Audience:** High-performing knowledge workers, software engineers, students, and anime/RPG enthusiasts seeking serious personal accountability.

---

## 1. Executive Summary & Problem Statement

### 1.1 The Problem
Standard habit trackers and productivity apps suffer from extreme churn and low long-term retention:
- **Boring UI:** Generic checkboxes and bland flat lists fail to stimulate the brain's dopamine reward circuitry.
- **Lack of High-Stakes Accountability:** When users miss a habit, there are usually zero consequences, making procrastination friction-free.
- **Disconnected Growth:** Habit completion is disconnected from a cohesive sense of personal character progression.
- **Missing Real-Life Rewards:** Digital streaks alone eventually lose motivation without tangible, extrinsic rewards.

### 1.2 The Solution: The "System: Awakening"
Inspired by the *Solo Leveling* phenomenon, **System: Awakening** re-contextualizes everyday self-discipline as an urgent RPG Awakening:
- **Real-Life Hunter Stats:** Physical health, deep work, agility, sleep, and mindfulness increase tangible RPG stats (STR, INT, AGI, VIT, PER).
- **The Daily Quest System:** Holographic HUD notifications with immediate level-up feedback, stat point allocation, and rank badges.
- **Gates & Dungeon Raids:** Focus blocks (Pomodoro sessions) are framed as Dungeon Raids with clear clear-conditions, loot rewards, and Gate Break penalties.
- **The Penalty Zone:** Missed essential daily quests trigger a high-stress survival state at midnight, enforcing real-world commitment.
- **The Gold Economy & System Shop:** Complete quests and dungeons to earn Gold. Spend Gold on user-defined real-life rewards (e.g. guilt-free gaming, takeout meals) or in-game emergency consumables (Streak Shields, Dungeon Keys).
- **Boss Battles for Macro Goals:** Transform major milestones (e.g., AWS certification, finishing a portfolio project, marathon training) into epic Boss Battles with shared HP bars.

---

## 2. Core Functional Requirements

### FR-1: Hunter Profile & Status HUD
- **Rank Hierarchy:** E-Rank -> D-Rank -> C-Rank -> B-Rank -> A-Rank -> S-Rank -> National Level.
- **5-Core Stat Pentagon (Radar Chart):**
  - Strength (STR): Workouts, physical fitness, steps.
  - Intelligence (INT): Deep work focus, reading, study.
  - Agility (AGI): Habit speed, punctuality, morning routine.
  - Vitality (VIT): Sleep duration, hydration, recovery.
  - Perception (PER): Mindfulness, meditation, journaling.
- **Stat Point Allocation:** 3 points per level-up with interactive manual allocation.
- **Dynamic Titles:** E.g., "The Weakest Hunter", "Wolf Slayer", "Dungeon Specialist", "Shadow Sovereign".
- **Economy:** Hunter Gold balance earned from all activities.

### FR-2: Daily Quest HUD
- **Daily Quests:** Auto-reset at midnight; clear numerical progress indicators (e.g. 0/100 Push-ups, 0/120 min Deep Work).
- **Completion Feedback:** Instant particle/holographic burst, sensory haptic trigger (`UIImpactFeedbackGenerator`), floating EXP & Gold animation (`+50 EXP, +20 Gold`), audio cue.
- **The "Arise" Level-Up Chant:** The signature action button triggering celebrations on quest completion and level advancement.

### FR-3: Gate Raids (Focus Timer / Pomodoro) & Boss Battles
- **Gate Tiers:** 25m E-Rank, 50m C-Rank, 90m B-Rank, 120m Red Gate (S-Rank).
- **Live Activity Integration:** Lock Screen and Dynamic Island display remaining time, gate rank, and current boss encounter.
- **Boss Battles:** Connect deep work sessions to major multi-week projects, dealing damage to the Boss's HP with each completed focus hour.

### FR-4: Penalty Zone Protocol
- **Trigger:** Midnight evaluation of uncompleted core daily quests.
- **State Change:** HUD transforms into Crimson Alert Mode (`#FF2E63`) with glitch animation.
- **Redemption:** User must complete an emergency 30-minute focus/exercise session or consume a **Streak Shield** purchased from the System Shop.

### FR-5: System Shop & Inventory
- **System Consumables:** Streak Shields (nullifies Penalty Zone), Red Gate Keys (unlocks 120m deep work raids), Elixirs of Vitality (resets fatigue).
- **Custom Real-World Rewards:** User-created custom rewards purchased with earned Gold (e.g., guilt-free gaming, favorite food, leisure time).

---

## 3. Non-Functional Requirements (NFR)
1. **Performance:** 60/120 FPS fluid ProMotion animations; radar chart recalculation < 2ms.
2. **Swift 6 Strict Concurrency:** Compiled with `-strict-concurrency=complete` and 0 warnings.
3. **Offline-First:** 100% functionality without internet connection using SwiftData local persistence.
4. **Apple HIG & Accessibility:** Dynamic Type support, minimum 44x44 pt hit targets, full VoiceOver accessibility.
