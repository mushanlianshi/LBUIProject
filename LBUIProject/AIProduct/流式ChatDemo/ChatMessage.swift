import UIKit

// MARK: - ChatRole

enum ChatRole {
    case user
    case assistant
}

// MARK: - ChatMessage

class ChatMessage {
    let id: UUID
    let role: ChatRole
    var text: String
    var isStreaming: Bool
    var renderedHeight: CGFloat = 0
    var isFromHistory = false

    /// id 参数化：从 DB 恢复历史消息时传入原 id（upsert 主键对齐，避免重复插入）
    init(id: UUID = UUID(), role: ChatRole, text: String, isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.text = text
        self.isStreaming = isStreaming
    }
}
