import SwiftUI

// Centralized "Matcha" Color Palette
extension Color {
    // A deep, rich charcoal (Dark Roast) to contrast with the Matcha
    static let appBackground = Color(hex: "#1A1A1A")
    
    // THE NEW MATCHA GREEN (Ceremonial Grade)
    // Replaces the old Neon Lime
    static let primaryAccent = Color(hex: "#C2E078")
    
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "#8E8E93")
}

// Hex Helper (Standard)
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        
        let r = Double((hexNumber & 0xff0000) >> 16) / 255
        let g = Double((hexNumber & 0x00ff00) >> 8) / 255
        let b = Double(hexNumber & 0x0000ff) / 255
        
        self.init(red: r, green: g, blue: b)
    }
}
