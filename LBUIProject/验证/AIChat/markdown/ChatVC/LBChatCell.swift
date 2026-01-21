import UIKit

final class LBChatCell: UITableViewCell {
    static let reuseId = "MessageCell"

    private let bubbleView = UIView()
    let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.dataDetectorTypes = [.link]
        return tv
    }()

    private var bubbleLeading: NSLayoutConstraint!
    private var bubbleTrailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
    }

    func configure(for message: LBChatMessage) {
        // alignment and background
        if message.role == .user {
            bubbleView.snp.remakeConstraints { make in
                make.right.equalTo(-15)
                make.top.equalTo(10)
                make.bottom.equalTo(0)
                make.left.lessThanOrEqualTo(15)
            }
            bubbleView.backgroundColor = UIColor.systemBlue
            textView.textColor = .white
//            bubbleLeading.isActive = false
//            bubbleTrailing.isActive = true
        } else {
            bubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            textView.textColor = .black
//            bubbleTrailing.isActive = false
//            bubbleLeading.isActive = true
            bubbleView.snp.remakeConstraints { make in
                make.left.equalTo(15)
                make.top.equalTo(10)
                make.bottom.equalTo(0)
                make.right.equalTo(-15)
            }
        }
        // set attributed from message.attributed — but don't replace if streaming update will append later
        textView.attributedText = message.attributed
    }

    required init?(coder: NSCoder) { fatalError() }
}
