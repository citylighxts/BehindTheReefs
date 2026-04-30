import SpriteKit
import UIKit

private struct PuzzleBook {
    let id: Int
    let name: String
    let color: UIColor
    let height: CGFloat
    let width: CGFloat = 44
}

final class GameScene: SKScene {

    weak var viewModel: GameViewModel?

    private let snapDuration: TimeInterval = 0.25
    private let shadowAlpha: CGFloat = 0.18
    private let liftScale: CGFloat = 1.06
    private let shelfYRatio: CGFloat = 0.55
    private let slotXRatios: [CGFloat] = [0.28, 0.50, 0.72]

    private var books: [PuzzleBook] = []
    private var slotOccupant: [Int: String] = [:]   // slot index → book name
    private var bookSlot: [String: Int] = [:]        // book name → slot index
    private var draggedNode: SKNode?
    private var touchStartX: CGFloat = 0
    private var shadowNodes: [String: SKShapeNode] = [:]

    private let hapticLight = UIImpactFeedbackGenerator(style: .light)
    private let hapticSoft  = UIImpactFeedbackGenerator(style: .soft)

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1)
        physicsWorld.gravity = .zero
        buildBooks()
        spawnScene()
        hapticLight.prepare()
        hapticSoft.prepare()
    }

    private func buildBooks() {
        books = [
            PuzzleBook(id: 1, name: "book1", color: UIColor(red: 0.78, green: 0.73, blue: 0.90, alpha: 1), height: 130),
            PuzzleBook(id: 2, name: "book2", color: UIColor(red: 0.68, green: 0.82, blue: 0.74, alpha: 1), height: 90),
            PuzzleBook(id: 3, name: "book3", color: UIColor(red: 0.98, green: 0.80, blue: 0.69, alpha: 1), height: 60),
        ]
    }

    private func spawnScene() {
        drawShelf()

        let shuffledBooks = books.shuffled()
        for (slotIdx, book) in shuffledBooks.enumerated() {
            slotOccupant[slotIdx] = book.name
            bookSlot[book.name] = slotIdx
            spawnBook(book, at: slotPosition(index: slotIdx))
        }
    }

    private func drawShelf() {
        let W = size.width, H = size.height
        let y = H * shelfYRatio - 2

        let path = CGMutablePath()
        path.move(to: CGPoint(x: W * 0.10, y: y))
        path.addLine(to: CGPoint(x: W * 0.90, y: y))

        let shelf = SKShapeNode(path: path)
        shelf.strokeColor = UIColor(red: 0.72, green: 0.65, blue: 0.58, alpha: 0.8)
        shelf.lineWidth = 3
        shelf.lineCap = .round
        shelf.zPosition = -1
        addChild(shelf)
    }

    private func spawnBook(_ book: PuzzleBook, at position: CGPoint) {
        let rect = CGRect(x: -book.width / 2, y: 0, width: book.width, height: book.height)

        let shadowRect = CGRect(x: -book.width / 2 - 3, y: -3, width: book.width + 6, height: book.height + 6)
        let shadow = SKShapeNode(rect: shadowRect, cornerRadius: 7)
        shadow.fillColor = UIColor(red: 0.20, green: 0.15, blue: 0.10, alpha: shadowAlpha)
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: position.x + 4, y: position.y - 4)
        shadow.zPosition = 1
        shadow.name = "shadow_\(book.name)"
        addChild(shadow)
        shadowNodes[book.name] = shadow

        let node = SKShapeNode(rect: rect, cornerRadius: 6)
        node.fillColor = book.color
        node.strokeColor = book.color.withAlphaComponent(0.5)
        node.lineWidth = 1.5
        node.name = book.name
        node.position = position
        node.zPosition = 2
        node.userData = NSMutableDictionary()
        node.userData?["bookID"] = book.id

        addChild(node)
    }

    private func slotPosition(index: Int) -> CGPoint {
        CGPoint(x: size.width * slotXRatios[index], y: size.height * shelfYRatio)
    }

    private func nearestSlot(to point: CGPoint) -> Int {
        var best = 0
        var bestDist = CGFloat.infinity
        for i in 0..<slotXRatios.count {
            let d = abs(point.x - slotPosition(index: i).x)
            if d < bestDist { bestDist = d; best = i }
        }
        return best
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        let candidates = nodes(at: loc).filter {
            guard let n = $0.name else { return false }
            return !n.hasPrefix("shadow_") && $0 is SKShapeNode
        }
        guard let picked = candidates.max(by: { $0.zPosition < $1.zPosition }),
              picked.userData?["bookID"] != nil else { return }

        draggedNode = picked
        touchStartX = loc.x
        picked.zPosition = 10
        picked.run(SKAction.scale(to: liftScale, duration: 0.12))

        if let shadow = shadowNodes[picked.name ?? ""] {
            shadow.run(SKAction.group([
                SKAction.move(by: CGVector(dx: 6, dy: -6), duration: 0.12),
                SKAction.fadeAlpha(to: shadowAlpha * 1.8, duration: 0.12)
            ]))
        }
        hapticLight.impactOccurred(); hapticLight.prepare()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let node = draggedNode else { return }
        let loc = touch.location(in: self)
        let shelfY = size.height * shelfYRatio
        // Only move horizontally — Y stays on the shelf
        node.position = CGPoint(x: loc.x, y: shelfY)
        shadowNodes[node.name ?? ""]?.position = CGPoint(x: loc.x + 6, y: shelfY - 6)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = draggedNode else { return }
        finalizeDrop(node)
        draggedNode = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = draggedNode else { return }
        finalizeDrop(node)
        draggedNode = nil
    }

    private func finalizeDrop(_ node: SKNode) {
        guard let name = node.name else { return }

        let targetSlot = nearestSlot(to: node.position)
        let originSlot = bookSlot[name]!

        if targetSlot != originSlot, let occupantName = slotOccupant[targetSlot] {
            // Swap the two books
            slotOccupant[originSlot] = occupantName
            slotOccupant[targetSlot] = name
            bookSlot[occupantName] = originSlot
            bookSlot[name] = targetSlot

            // Animate the displaced book back to origin slot
            let originPos = slotPosition(index: originSlot)
            if let otherNode = childNode(withName: occupantName) {
                otherNode.run(SKAction.move(to: originPos, duration: snapDuration))
                shadowNodes[occupantName]?.run(
                    SKAction.move(to: CGPoint(x: originPos.x + 4, y: originPos.y - 4), duration: snapDuration)
                )
            }
        }

        // Snap dragged book to its (possibly new) slot
        let finalPos = slotPosition(index: bookSlot[name]!)
        let glide = SKAction.move(to: finalPos, duration: snapDuration)
        glide.timingMode = .easeInEaseOut
        let scale = SKAction.scale(to: 1.0, duration: snapDuration)

        node.run(SKAction.group([glide, scale])) { [weak self] in
            guard let self else { return }
            node.zPosition = 2
            self.hapticSoft.impactOccurred(); self.hapticSoft.prepare()
            self.shadowNodes[name]?.run(SKAction.group([
                SKAction.move(to: CGPoint(x: finalPos.x + 4, y: finalPos.y - 4), duration: 0.15),
                SKAction.fadeAlpha(to: self.shadowAlpha, duration: 0.15)
            ]))
            self.checkWin()
        }
    }

    private func checkWin() {
        guard slotOccupant.count == 3,
              slotOccupant[0] == "book1",
              slotOccupant[1] == "book2",
              slotOccupant[2] == "book3" else { return }

        for book in books {
            childNode(withName: book.name)?.run(SKAction.sequence([
                SKAction.scale(to: 1.10, duration: 0.18),
                SKAction.scale(to: 1.0,  duration: 0.18)
            ]))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
            self?.viewModel?.finishGame(correct: true)
        }
    }

    func resetPuzzle() {
        removeAllChildren()
        slotOccupant.removeAll()
        bookSlot.removeAll()
        shadowNodes.removeAll()
        draggedNode = nil
        buildBooks()
        spawnScene()
    }
}
