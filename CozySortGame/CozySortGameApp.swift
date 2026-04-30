import SwiftUI
import SwiftData

@main
struct CozySortGameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .statusBarHidden(false)
        }
        .modelContainer(for: StarRecord.self)
    }
}
