import SwiftUI

struct GlassBackground: ViewModifier {
    let intensity: Double
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    
    init(intensity: Double = 0.8, cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10) {
        self.intensity = intensity
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: Color.black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: shadowRadius / 2
            )
    }
}

struct FrostedGlassBackground: ViewModifier {
    let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: Color.black.opacity(0.15),
                radius: 15,
                x: 0,
                y: 8
            )
    }
}

struct GradientGlassBackground: ViewModifier {
    let gradient: LinearGradient
    let cornerRadius: CGFloat
    
    init(gradient: LinearGradient, cornerRadius: CGFloat = 20) {
        self.gradient = gradient
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(gradient.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                gradient.opacity(0.3),
                                lineWidth: 1
                            )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(
                color: Color.black.opacity(0.1),
                radius: 12,
                x: 0,
                y: 6
            )
    }
}

extension View {
    func glassBackground(intensity: Double = 0.8, cornerRadius: CGFloat = 20, shadowRadius: CGFloat = 10) -> some View {
        modifier(GlassBackground(intensity: intensity, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    func frostedGlassBackground(cornerRadius: CGFloat = 20) -> some View {
        modifier(FrostedGlassBackground(cornerRadius: cornerRadius))
    }
    
    func gradientGlassBackground(gradient: LinearGradient, cornerRadius: CGFloat = 20) -> some View {
        modifier(GradientGlassBackground(gradient: gradient, cornerRadius: cornerRadius))
    }
} 