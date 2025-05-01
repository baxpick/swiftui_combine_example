import SwiftUI

struct Colors {
    
    static func defaultText(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    static func defaultBorderSelected(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .blue : .blue
    }
    
    static func defaultBorderNotSelected(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .clear : .clear
    }
}
