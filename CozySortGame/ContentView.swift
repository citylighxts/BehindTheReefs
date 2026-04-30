import SwiftUI
import SpriteKit
import SwiftData

extension Color {
    static let linenWhite    = Color(red: 0.97, green: 0.95, blue: 0.91)
    static let dustyLavender = Color(red: 0.78, green: 0.73, blue: 0.90)
    static let sage          = Color(red: 0.68, green: 0.82, blue: 0.74)
    static let softPeach     = Color(red: 0.98, green: 0.80, blue: 0.69)
    static let mutedInk      = Color(red: 0.28, green: 0.24, blue: 0.22)
    static let fadedStone    = Color(red: 0.58, green: 0.54, blue: 0.50)
}

struct ContentView: View {
    @State private var viewModel = GameViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Color.linenWhite.ignoresSafeArea()

            switch viewModel.currentScreen {
            case .menu:
                MenuView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            case .playing, .solved:
                GameView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.currentScreen)
        .onAppear {
            viewModel.modelContext = modelContext
            viewModel.loadStars()
        }
    }
}

struct MenuView: View {
    let viewModel: GameViewModel
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("A Place")
                    .font(.system(size: 52, weight: .thin, design: .serif))
                    .foregroundStyle(Color.mutedInk)
                Text("for Everything")
                    .font(.system(size: 34, weight: .light, design: .serif))
                    .foregroundStyle(Color.dustyLavender)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)

            Spacer().frame(height: 24)

            Text("Sort gently. No rush.")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Color.fadedStone)
                .opacity(appeared ? 1 : 0)

            Spacer().frame(height: 16)

            if viewModel.totalStars > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.softPeach)
                    Text("\(viewModel.totalStars)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.fadedStone)
                }
                .opacity(appeared ? 1 : 0)
            }

            Spacer().frame(height: 48)

            HStack(alignment: .bottom, spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.dustyLavender)
                    .frame(width: 28, height: 52)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.sage)
                    .frame(width: 28, height: 36)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.softPeach)
                    .frame(width: 28, height: 24)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.85)

            Spacer().frame(height: 56)

            Button(action: viewModel.startGame) {
                Text("Begin")
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 200, height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 27)
                            .fill(Color.dustyLavender)
                            .shadow(color: Color.dustyLavender.opacity(0.40), radius: 12, y: 6)
                    )
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)

            Spacer()

            Text("Sincerely made by Ciwi-ciwi + Ian!")
                .font(.system(size: 12, weight: .light, design: .rounded))
                .foregroundStyle(Color.fadedStone.opacity(0.6))
                .padding(.bottom, 28)
                .opacity(appeared ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.85).delay(0.1)) { appeared = true }
        }
    }
}

struct GameView: View {
    let viewModel: GameViewModel

    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        ZStack {
            SpriteView(scene: scene, options: [.allowsTransparency])
                .ignoresSafeArea()
                .onAppear { scene.viewModel = viewModel }

            VStack {
                HStack {
                    Button(action: { viewModel.returnToMenu() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.mutedInk)
                            .padding(14)
                            .background(Circle().fill(Color.white.opacity(0.80))
                                .shadow(color: .black.opacity(0.07), radius: 6, y: 3))
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 20)
                    .padding(.top, 56)

                    Spacer()

                    Text("Tallest → shortest")
                        .font(.system(size: 13, weight: .light, design: .rounded))
                        .foregroundStyle(Color.fadedStone)
                        .padding(.trailing, 20)
                        .padding(.top, 56)
                }
                Spacer()
            }

            if viewModel.isSolved {
                WinOverlayView(viewModel: viewModel, scene: scene)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.7), value: viewModel.isSolved)
            }
        }
    }
}

struct WinOverlayView: View {
    let viewModel: GameViewModel
    let scene: GameScene
    @State private var appeared = false

    var body: some View {
        ZStack {
            Color.linenWhite.opacity(0.88).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.softPeach)
                    .scaleEffect(appeared ? 1.0 : 0.3)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 20)

                Text("Everything in its place.")
                    .font(.system(size: 28, weight: .thin, design: .serif))
                    .foregroundStyle(Color.mutedInk)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 8)

                Text("⭐️ \(viewModel.totalStars) star\(viewModel.totalStars == 1 ? "" : "s") earned")
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundStyle(Color.fadedStone)
                    .opacity(appeared ? 1 : 0)

                Spacer().frame(height: 48)

                VStack(spacing: 14) {
                    Button(action: {
                        viewModel.resetGame()
                        scene.resetPuzzle()
                    }) {
                        Text("Try Again")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 220, height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 26)
                                    .fill(Color.sage)
                                    .shadow(color: Color.sage.opacity(0.4), radius: 10, y: 5)
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: viewModel.returnToMenu) {
                        Text("Go Home")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.fadedStone)
                    }
                    .buttonStyle(.plain)
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 14)

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.72).delay(0.15)) {
                appeared = true
            }
        }
    }
}

struct StarShape: Shape {
    let points: Int
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.45
        let offset = -CGFloat.pi / 2
        var path = Path()
        for i in 0 ..< points * 2 {
            let r = (i % 2 == 0) ? outer : inner
            let angle = offset + CGFloat(i) * .pi / CGFloat(points)
            let pt = CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

#Preview { ContentView() }
