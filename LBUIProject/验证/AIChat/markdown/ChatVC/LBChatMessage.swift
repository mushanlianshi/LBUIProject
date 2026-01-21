import Foundation

enum LBMessageRole {
    case user
    case assistant
}

final class LBChatMessage {
    let id: UUID = .init()
    let role: LBMessageRole
    // accumulated plain-markdown (for persistence)
    var markdown: String
    // attributed content for display (mutable)
    var attributed: NSMutableAttributedString

    init(role: LBMessageRole, markdown: String = "") {
        self.role = role
        self.markdown = markdown
        self.attributed = NSMutableAttributedString(string: markdown)
    }
}
