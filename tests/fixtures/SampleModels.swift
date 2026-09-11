import Foundation

struct UserProfile: Codable, Identifiable, Equatable {
    let id: UUID
    var username: String
    var email: String?
    var loginCount: Int
    var isVerified: Bool
    let createdAt: Date
}

enum ConnectionStatus: String, CaseIterable {
    case disconnected
    case connecting
    case connected
    case failed
}

enum AppEvent {
    case windowResized(width: Double, height: Double)
    case userAuthenticated(token: String)
    case sessionTerminated
}
