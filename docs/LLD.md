# Low-Level Design (LLD) — "Arise"

**Component Specifications, Data Schemas, Math Models & Protocol Contracts**

---

## 1. Domain Entities Specification

### 1.1 `HunterRank`
```swift
public enum HunterRank: String, Codable, CaseIterable, Comparable, Sendable {
    case e = "E-Rank"
    case d = "D-Rank"
    case c = "C-Rank"
    case b = "B-Rank"
    case a = "A-Rank"
    case s = "S-Rank"
    case nationalLevel = "National Level"

    public var minimumLevel: Int {
        switch self {
        case .e: return 1
        case .d: return 10
        case .c: return 25
        case .b: return 45
        case .a: return 70
        case .s: return 100
        case .nationalLevel: return 150
        }
    }

    public var title: String {
        switch self {
        case .e: return "The Weakest Hunter"
        case .d: return "Awakened Novice"
        case .c: return "Dungeon Cleaner"
        case .b: return "Raid Specialist"
        case .a: return "Elite Vanguard"
        case .s: return "Shadow Sovereign"
        case .nationalLevel: return "Monarch of Shadows"
        }
    }
}
```

### 1.2 `StatType`
```swift
public enum StatType: String, Codable, CaseIterable, Identifiable, Sendable {
    case strength = "STR"
    case intelligence = "INT"
    case agility = "AGI"
    case vitality = "VIT"
    case perception = "PER"

    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .strength: return "Strength"
        case .intelligence: return "Intelligence"
        case .agility: return "Agility"
        case .vitality: return "Vitality"
        case .perception: return "Perception"
        }
    }

    public var habitCategory: String {
        switch self {
        case .strength: return "Physical Fitness & Workouts"
        case .intelligence: return "Deep Work & Study"
        case .agility: return "Execution Speed & Routines"
        case .vitality: return "Sleep & Recovery"
        case .perception: return "Mindfulness & Focus"
        }
    }
}
```

### 1.3 `HunterProfile`
```swift
public struct HunterProfile: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var rank: HunterRank
    public var level: Int
    public var currentExp: Int
    public var stats: [StatType: Int]
    public var unallocatedStatPoints: Int
    public var currentStreakDays: Int
    public var isPenaltyActive: Bool
    public var manaFatiguePercentage: Double

    public var expRequiredForNextLevel: Int {
        Int(floor(100.0 * pow(Double(level), 1.5)))
    }

    public var expProgressPercentage: Double {
        let req = expRequiredForNextLevel
        guard req > 0 else { return 0.0 }
        return min(max(Double(currentExp) / Double(req), 0.0), 1.0)
    }
}
```

### 1.4 `DailyQuest`
```swift
public struct DailyQuest: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var title: String
    public var description: String
    public var statPillar: StatType
    public var targetCount: Double
    public var currentCount: Double
    public var unit: String
    public var rewardExp: Int
    public var rewardStatPoints: Int
    public var isCompleted: Bool
    public var isEssential: Bool // Uncompleted essential quests trigger Penalty Zone
    public var deadline: Date

    public var progressFraction: Double {
        guard targetCount > 0 else { return 0.0 }
        return min(max(currentCount / targetCount, 0.0), 1.0)
    }
}
```

---

## 2. Gamification Math: 5-Point Radar Polygon Engine

The 5 stats ($N=5$) are rendered on a normalized 2D Cartesian plane mapped from polar coordinates.

### Geometry Formulas:
For any vertex $i \in \{0, 1, 2, 3, 4\}$ with stat value $S_i$ and cap $S_{max}$:
$$v_i = \min\left(\max\left(\frac{S_i}{S_{max}}, 0.1\right), 1.0\right)$$
$$\theta_i = -\frac{\pi}{2} + i \cdot \frac{2\pi}{5}$$
$$\text{Point}_i(x, y) = \left( x_{\text{center}} + R \cdot v_i \cdot \cos(\theta_i), \; y_{\text{center}} + R \cdot v_i \cdot \sin(\theta_i) \right)$$

### Visual Canvas Implementation:
- **Background Web:** Draw concentric pentagons at $20\%$, $40\%$, $60\%$, $80\%$, $100\%$ radius with `#1A2035` strokes.
- **Axis Spokes:** Draw 5 lines from center $(x_c, y_c)$ to each maximum vertex.
- **Data Polygon:** Close path across all 5 computed data points.
  - Fill with `LinearGradient` from Electric Cyan (`#00E5FF`) to Shadow Purple (`#7C3AED`) with $0.35$ opacity.
  - Stroke with `#00E5FF` at width $2.5$ pt and a glowing shadow blur of $8$ pt.
- **Interactive Vertices:** Circle handles with a `+` badge when `unallocatedStatPoints > 0`. Tapping awards $+1$ stat with immediate spring interpolation.

---

## 3. Protocol Contracts (Domain Repositories & Use Cases)

```swift
public protocol HunterProfileRepositoryProtocol: Sendable {
    func fetchProfile() async throws -> HunterProfile
    func updateProfile(_ profile: HunterProfile) async throws
}

public protocol DailyQuestRepositoryProtocol: Sendable {
    func fetchActiveQuests() async throws -> [DailyQuest]
    func updateQuestProgress(id: UUID, currentCount: Double) async throws -> DailyQuest
    func resetDailyQuests() async throws -> [DailyQuest]
}

public protocol CompleteDailyQuestUseCaseProtocol: Sendable {
    func execute(questId: UUID) async throws -> (updatedProfile: HunterProfile, completedQuest: DailyQuest, didLevelUp: Bool)
}
```

---

## 4. SwiftData Schema Layer (Data Layer)

```swift
import SwiftData
import Foundation

@Model
public final class SDHunterProfile {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var rankRaw: String
    public var level: Int
    public var currentExp: Int
    public var statStrength: Int
    public var statIntelligence: Int
    public var statAgility: Int
    public var statVitality: Int
    public var statPerception: Int
    public var unallocatedStatPoints: Int
    public var currentStreakDays: Int
    public var isPenaltyActive: Bool
    public var updatedAt: Date

    public init(id: UUID = UUID(), name: String, rankRaw: String, level: Int, currentExp: Int) {
        self.id = id
        self.name = name
        self.rankRaw = rankRaw
        self.level = level
        self.currentExp = currentExp
        self.statStrength = 10
        self.statIntelligence = 10
        self.statAgility = 10
        self.statVitality = 10
        self.statPerception = 10
        self.unallocatedStatPoints = 0
        self.currentStreakDays = 0
        self.isPenaltyActive = false
        self.updatedAt = Date()
    }
}
```
