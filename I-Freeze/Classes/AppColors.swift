import Foundation
import SwiftUI
extension Color {
    static let darkBlue = Color(red: 0.1, green: 0.1, blue: 0.3) // Custom dark blue color
}
extension Color {
    static let lightBlue = Color(red: 0.3, green: 0.5, blue: 1.0) // Light Blue Accent Color
}


extension Color {
    /// Initializes a `Color` from a hex string.
    /// - Parameter hex: The hex string representing the color (e.g., "#175AA8").
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue)
    }


}

