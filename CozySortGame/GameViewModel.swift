import SwiftUI
import Observation
import SwiftData

enum GameScreen { case menu, playing, solved }

@Observable
final class GameViewModel {

    var currentScreen: GameScreen = .menu
    var isSolved: Bool = false
    var earnedStar: Bool = false
    var totalStars: Int = 0

    var modelContext: ModelContext?

    func startGame() {
        isSolved = false
        earnedStar = false
        withAnimation(.easeInOut(duration: 0.5)) { currentScreen = .playing }
    }

    func resetGame() {
        isSolved = false
        earnedStar = false
        withAnimation(.easeInOut(duration: 0.5)) { currentScreen = .playing }
    }

    func returnToMenu() {
        isSolved = false
        earnedStar = false
        withAnimation(.easeInOut(duration: 0.5)) { currentScreen = .menu }
    }

    func finishGame(correct: Bool = true) {
        earnedStar = correct
        if correct, let ctx = modelContext {
            ctx.insert(StarRecord(earnedAt: .now))
            try? ctx.save()
            loadStars()
        }
        withAnimation(.easeInOut(duration: 0.6)) {
            isSolved = true
            currentScreen = .solved
        }
    }

    func loadStars() {
        guard let ctx = modelContext else { return }
        let count = (try? ctx.fetchCount(FetchDescriptor<StarRecord>())) ?? 0
        totalStars = count
    }
}
