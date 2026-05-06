import SpriteKit
import SwiftUI

class LoadingScene: SKScene {
    
    override func didMove(to view: SKView) {
        // Set an underwater-style background color (optional)
        backgroundColor = SKColor(red: 0.05, green: 0.3, blue: 0.6, alpha: 1.0)
        
        // Setup UI and Particles
        addLoadingText()
        createBubbleParticles()
    }
    
    private func createBubbleParticles() {
        let bubbleEmitter = SKEmitterNode()
        
        // 1. Load your specific asset (Omit the .png, Xcode handles it automatically)
        bubbleEmitter.particleTexture = SKTexture(imageNamed: "waterBubble")
        
        // 2. Position: Center X, slightly below the bottom Y
        // Note: If your scene anchor point is (0,0), use size.width / 2.
        // If anchor point is (0.5, 0.5), use x: 0, y: -size.height / 2
        bubbleEmitter.position = CGPoint(x: size.width / 2, y: -50)
        
        // Spread the bubbles across the entire width of the screen
        bubbleEmitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        
        // 3. Direction: Straight up (90 degrees or .pi / 2)
        bubbleEmitter.emissionAngle = .pi / 2
        bubbleEmitter.emissionAngleRange = .pi / 8 // Slight spread left/right
        
        // 4. Speed & Buoyancy
        bubbleEmitter.particleSpeed = 100
        bubbleEmitter.particleSpeedRange = 40
        bubbleEmitter.yAcceleration = 25 // Positive Y pushes them up like buoyancy
        
        // 5. Amount & Lifetime
        bubbleEmitter.particleBirthRate = 20
        bubbleEmitter.particleLifetime = 10.0 // Ensure they live long enough to reach the top
        bubbleEmitter.particleLifetimeRange = 2.0
        
        // 6. Visual Adjustments (Size & Alpha)
        bubbleEmitter.particleScale = 0.00005       // Base size (adjust based on your image size)
        bubbleEmitter.particleScaleRange = 0.1  // Randomize sizes
        bubbleEmitter.particleScaleSpeed = 0.02 // Slowly grow as they rise
        
        bubbleEmitter.particleAlpha = 0.8
        bubbleEmitter.particleAlphaRange = 0.2
        bubbleEmitter.particleAlphaSpeed = -0.05 // Slowly fade out
        
        bubbleEmitter.particleBlendMode = .alpha
        bubbleEmitter.zPosition = 1 // Put behind the text, but above background
        
        // 7. THE MAGIC TRICK FOR LOADING SCREENS
        // Fast-forwards the emitter by 10 seconds so the screen is already full of bubbles
        bubbleEmitter.advanceSimulationTime(10.0)
        
        addChild(bubbleEmitter)
    }
    
    private func addLoadingText() {
        let loadingLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        loadingLabel.text = "LOADING..."
        loadingLabel.fontSize = 28
        loadingLabel.fontColor = .white
        
        // Position in the center
        loadingLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        loadingLabel.zPosition = 10 // Ensure this is layered above the bubbles
        
        // Optional: Add a simple pulsing animation to the text
        let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        loadingLabel.run(SKAction.repeatForever(pulse))
        
        addChild(loadingLabel)
    }
}


#Preview(traits: .landscapeRight) {
    // 1. Buat ukuran simulasi layar (misalnya ukuran iPhone 15 Pro)
    let size = CGSize(width: 393, height: 852)
    
    // 2. Inisialisasi LoadingScene kamu dengan ukuran tersebut
    let scene = LoadingScene(size: size)
    
    // 3. Atur scale mode agar memenuhi layar dengan baik
    scene.scaleMode = .aspectFill
    
    // 4. Bungkus scene dengan SpriteView agar bisa dibaca oleh SwiftUI Preview
    return SpriteView(scene: scene)
        .ignoresSafeArea() // Agar background penuh sampai ke ujung notch/dynamic island
}
