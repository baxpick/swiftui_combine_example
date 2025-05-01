import SwiftUI

struct ButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
    }
}

struct VStackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
    }
}

struct ButttonTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
    }
}

struct BorderBackgroundStoke: ViewModifier {
    private let color: Color?
    
    init(color: Color? = nil) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        if let color = color {
            content
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(color, lineWidth: 2)
                )
        }
        else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 2)
                )
        }
    }
}

struct BorderOverlayStoke: ViewModifier {
    private let color: Color?
    
    init(color: Color? = nil) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        if let color = color {
            content
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 2)
                )
        }
        else {
            content
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(lineWidth: 2)
                )
        }
    }
}
