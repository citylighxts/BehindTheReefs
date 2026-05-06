import SwiftUI

private struct MenuButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )
    }
}

private extension View {
    func menuButtonStyle() -> some View {
        modifier(MenuButtonStyle())
    }
}

struct HomeScene: View {
    var body: some View {
        ZStack {
            Color.blueBackground.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Behind The Reefs")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                VStack(spacing: 10) {
                    Text("Start Game")
                        .menuButtonStyle()
                        .font(.title2)
                        .bold()
                    
                    Text("Credits")
                        .menuButtonStyle()
                        .font(.title3)
                }
                
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    HomeScene()
}
