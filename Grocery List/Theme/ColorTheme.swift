import SwiftUI

struct ColorTheme {
    static let categoryColors: [GroceryItem.Category: Color] = [
        .fruit: Color(hex: "FF6B6B"),      // Coral Red
        .dairy: Color(hex: "4ECDC4"),      // Turquoise
        .meat: Color(hex: "FF8B94"),       // Salmon Pink
        .vegetables: Color(hex: "95E1D3"), // Mint Green
        .bakery: Color(hex: "FFD93D"),     // Golden Yellow
        .other: Color(hex: "B8B5FF")       // Lavender
    ]
    
    static let gradientColors: [Color] = [
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "FFD93D"),
        Color(hex: "B8B5FF")
    ]
    
    static let accentColors: [Color] = [
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "FF8B94"),
        Color(hex: "95E1D3"),
        Color(hex: "FFD93D"),
        Color(hex: "B8B5FF")
    ]
    
    // Enhanced gradient combinations
    static let categoryGradients: [GroceryItem.Category: LinearGradient] = [
        .fruit: LinearGradient(
            colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E8E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        .dairy: LinearGradient(
            colors: [Color(hex: "4ECDC4"), Color(hex: "6EDDD5")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        .meat: LinearGradient(
            colors: [Color(hex: "FF8B94"), Color(hex: "FFA5AC")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        .vegetables: LinearGradient(
            colors: [Color(hex: "95E1D3"), Color(hex: "A8E8DB")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        .bakery: LinearGradient(
            colors: [Color(hex: "FFD93D"), Color(hex: "FFE066")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        .other: LinearGradient(
            colors: [Color(hex: "B8B5FF"), Color(hex: "C7C4FF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    ]
    
    // Background gradients for different sections
    static let backgroundGradients: [LinearGradient] = [
        LinearGradient(
            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        LinearGradient(
            colors: [Color(hex: "43e97b"), Color(hex: "38f9d7")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    ]
    
    // Card background colors
    static let cardBackgrounds: [Color] = [
        Color(hex: "FFFFFF").opacity(0.9),
        Color(hex: "F8F9FA").opacity(0.9),
        Color(hex: "E9ECEF").opacity(0.9)
    ]
    
    // Success and error colors
    static let successColor = Color(hex: "28A745")
    static let errorColor = Color(hex: "DC3545")
    static let warningColor = Color(hex: "FFC107")
    static let infoColor = Color(hex: "17A2B8")
    
    // Text colors
    static let primaryText = Color(hex: "212529")
    static let secondaryText = Color(hex: "6C757D")
    static let mutedText = Color(hex: "ADB5BD")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Dynamic color that adapts to light/dark mode
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
} 