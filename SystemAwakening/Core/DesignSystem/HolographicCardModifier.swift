//
//  HolographicCardModifier.swift
//  SystemAwakening
//
//  Created for "System: Awakening" — Gamified Solo Leveling Productivity App
//

import SwiftUI

/// A reusable SwiftUI modifier providing the iconic Solo Leveling holographic frosted glass aesthetic.
///
/// **Interview Rationale:**
/// - Custom ViewModifiers vs Custom Container Views: Using a `ViewModifier` adheres to idiomatic SwiftUI composability,
///   allowing any arbitrary view (cards, lists, modals) to adopt the holographic HUD treatment with zero hierarchy pollution.
/// - Performance: Renders a hardware-accelerated rounded rectangle stroke and subtle shadow blur without allocating extra views.
public struct HolographicCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var glowColor: Color?
    public var isGlowing: Bool
    public var strokeWidth: CGFloat

    public init(
        cornerRadius: CGFloat = 16,
        glowColor: Color? = nil,
        isGlowing: Bool = false,
        strokeWidth: CGFloat = 1.0
    ) {
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
        self.isGlowing = isGlowing
        self.strokeWidth = strokeWidth
    }

    public func body(content: Content) -> some View {
        let palette = ThemeManager.shared.palette
        let activeGlow = glowColor ?? palette.primaryAccent
        let borderColor = isGlowing ? activeGlow : palette.cardBorder

        return content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(palette.cardSurface.opacity(0.85))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor, lineWidth: strokeWidth)
                    .shadow(color: isGlowing ? activeGlow.opacity(0.6) : .clear, radius: isGlowing ? 8 : 0)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

public extension View {
    /// Applies the holographic glass card HUD styling with optional neon glow.
    func holographicCard(
        cornerRadius: CGFloat = 16,
        glowColor: Color? = nil,
        isGlowing: Bool = false,
        strokeWidth: CGFloat = 1.0
    ) -> some View {
        modifier(HolographicCardModifier(
            cornerRadius: cornerRadius,
            glowColor: glowColor,
            isGlowing: isGlowing,
            strokeWidth: strokeWidth
        ))
    }
}
