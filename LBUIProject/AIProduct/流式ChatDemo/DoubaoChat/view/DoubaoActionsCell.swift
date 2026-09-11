//
//  DoubaoActionsCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 回答操作栏 cell：播报 🔊 / 复制 📋 / 点赞 👍 / 点踩 👎
/// 点赞/点踩互斥高亮（状态变化由 VC reconfigure 本 item 增量刷新）
final class DoubaoActionsCell: UICollectionViewCell {

    static let reuseId = "DoubaoActionsCell"

    var onSpeech: (() -> Void)?
    var onCopy: (() -> Void)?
    var onLike: (() -> Void)?
    var onDislike: (() -> Void)?

    private let normalColor = UIColor.blt.hexColor(0x999999)
    private let highlightColor = UIColor.blt.hexColor(0x0E8AFD)

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 26
        return sv
    }()

    private lazy var speechButton = makeButton(icon: "🔊", title: "播报")
    private lazy var copyButton = makeButton(icon: "📋", title: "复制")
    private lazy var likeButton = makeButton(icon: "👍", title: "赞")
    private lazy var dislikeButton = makeButton(icon: "👎", title: "踩")

    private var copyFeedbackTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(stackView)
        stackView.addArrangedSubview(speechButton)
        stackView.addArrangedSubview(copyButton)
        stackView.addArrangedSubview(likeButton)
        stackView.addArrangedSubview(dislikeButton)

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-6)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        copyButton.setTitle("📋 复制", for: .normal)
        copyFeedbackTimer?.invalidate()
    }

    deinit {
        copyFeedbackTimer?.invalidate()
    }

    private func makeButton(icon: String, title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("\(icon) \(title)", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13)
        btn.setTitleColor(normalColor, for: .normal)
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return btn
    }

    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender {
        case speechButton: onSpeech?()
        case copyButton: onCopy?()
        case likeButton: onLike?()
        case dislikeButton: onDislike?()
        default: break
        }
    }

    func configure(model: DoubaoActionsModel) {
        likeButton.setTitleColor(model.isLiked ? highlightColor : normalColor, for: .normal)
        dislikeButton.setTitleColor(model.isDisliked ? highlightColor : normalColor, for: .normal)
    }

    /// 复制成功的轻反馈：按钮短暂变「已复制」（无 HUD 依赖的最简方案）
    func showCopyFeedback() {
        copyButton.setTitle("✅ 已复制", for: .normal)
        copyFeedbackTimer?.invalidate()
        copyFeedbackTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
            self?.copyButton.setTitle("📋 复制", for: .normal)
        }
    }
}
