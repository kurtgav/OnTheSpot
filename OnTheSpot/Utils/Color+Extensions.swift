import SwiftUI
import UIKit

extension Color {
    // 1. Background: System Black (Dark) / System White (Light)
    static let appBackground = Color(UIColor.systemBackground)
    
    // 2. Text: White (Dark) / Black (Light)
    static let primaryText = Color(UIColor.label)
    
    // 3. Smart Matcha: Neon in Dark Mode, Darker Olive in Light Mode
    static let primaryAccent = Color(UIColor { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(hexString: "#C2E078") : // Bright Matcha
            UIColor(hexString: "#556B2F")   // Dark Olive Green (Readable on White)
    })
    
    static let secondaryText = Color.gray
}

// Helper to allow Hex codes inside the UIColor logic above
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 3: (r, g, b) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b) = (0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: 1)
    }
}
