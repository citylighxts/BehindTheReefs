import Foundation
import SwiftData

@Model
final class StarRecord {
    var earnedAt: Date
    init(earnedAt: Date = .now) {
        self.earnedAt = earnedAt
    }
}
