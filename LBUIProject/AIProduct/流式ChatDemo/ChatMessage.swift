import UIKit

// MARK: - ChatRole

enum ChatRole {
    case user
    case assistant
}

// MARK: - ChatMessage

class ChatMessage {
    let id = UUID()
    let role: ChatRole
    var text: String
    var isStreaming: Bool
    var renderedHeight: CGFloat = 0

    init(role: ChatRole, text: String, isStreaming: Bool = false) {
        self.role = role
        self.text = text
        self.isStreaming = isStreaming
    }
}
