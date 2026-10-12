# Product Requirements Document (PRD) — "Arise"

**Project Title:** Arise  
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

### 1.2 The Solution: The "Solo Leveling" System
Inspired by the *Solo Leveling* phenomenon, **Arise** re-contextualizes everyday self-discipline as an urgent RPG Awakening:
- **Real-Life Hunter Stats:** Physical health, deep work, agility, sleep, and mindfulness increase tangible RPG stats (STR, INT, AGI, VIT, PER).
- **The Daily Quest System:** Holographic HUD notifications with immediate level-up feedback, stat point allocation, and rank badges.
- **Gates & Dungeon Raids:** Focus blocks (Pomodoro sessions) are framed as Dungeon Raids with clear clear-conditions, loot rewards, and Gate Break penalties.
- **The Penalty Zone:** Missed essential daily quests trigger a high-stress survival state at midnight, enforcing real-world commitment.

---

## 2. Personas

### Persona A: "The Grinding Hunter" (Alex, 26, Software Engineer)
- **Pain Points:** Struggles to stay focused during 90-minute deep work blocks; skips gym routines after tiring work days.
- **Needs:** Clear visual progress of cognitive skills (INT) and physical resilience (STR); motivating feedback loops that make grinding feel rewarding.

### Persona B: "The Aspiring Awakened" (Maya, 21, Pre-Med Student)
- **Pain Points:** Overwhelmed by study volume; suffers from habit tracking burnout across 5 different apps.
- **Needs:** A unified, visually striking HUD dashboard that turns grueling study sessions into dungeon raids with tangible stat points.

---

## 3. Core Functional Requirements

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

### FR-2: Daily Quest HUD
- **Daily Quests:** Auto-reset at midnight; clear numerical progress indicators (e.g. 0/100 Push-ups, 0/120 min Deep Work).
- **Completion Feedback:** Instant particle/holographic burst, sensory haptic trigger (`UIImpactFeedbackGenerator`), floating XP animation, audio cue.
- **Streak & Fatigue Tracking:** Cumulative completion streaks with bonus EXP multipliers.

### FR-3: Gate Raids (Focus Timer / Pomodoro)
- **Gate Tiers:**
  - E-Rank: 25 minutes
  - C-Rank: 50 minutes
  - A-Rank: 90 minutes
  - Red Gate: 120 minutes (Extreme high-stakes focus)
- **Live Activity Integration:** Lock Screen and Dynamic Island display remaining time, gate rank, and current boss encounter.
- **Gate Break (Failure):** Leaving the app or aborting timer induces fatigue penalties and forfeits dungeon rewards.

### FR-4: Penalty Zone Protocol
- **Trigger:** Midnight evaluation of uncompleted core daily quests.
- **State Change:** HUD transforms into Crimson Alert Mode (`#FF2E63`) with glitch animation.
- **Redemption:** User must complete an emergency 30-minute focus/exercise session or consume a rare "Streak Shield".

---

## 4. Non-Functional Requirements (NFR)

1. **Performance:**
   - 60 FPS standard / 120 FPS on ProMotion devices.
   - Zero main thread blocking; radar chart polygon recalculation < 2ms.
2. **Reliability & Concurrency:**
   - Swift 6 strict concurrency (`-strict-concurrency=complete`) with 0 warnings.
   - Background database operations isolated inside `ModelActor`.
3. **Offline First:**
   - 100% functionality without internet connection using SwiftData local persistence.
4. **Accessibility & Apple HIG:**
   - Dynamic Type support across all text labels.
   - VoiceOver accessibility labels for radar charts, progress rings, and rank badges.
   - Minimum 44x44 pt hit targets for all interactive controls.
