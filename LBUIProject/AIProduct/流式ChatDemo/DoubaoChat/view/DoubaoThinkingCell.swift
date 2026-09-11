//
//  DoubaoThinkingCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit
import BLTBasicUIKit

/// 思考过程块 cell（豆包「深度思考」交互）
/// - 流式中：头部 spinner + 「思考中」，body 展示流式思考文本（强制展开）
/// - 结束后：折叠成一行「已深度思考 · 用时 Ns」，点击整块切换展开/收起
/// - 折叠/展开是内容变化（id 不变），由 VC reconfigure 刷新，不产生结构 diff
final class DoubaoThinkingCell: UICollectionViewCell {

    static let reuseId = "DoubaoThinkingCell"

    /// 整块点击切换展开态。
    /// ⚠️ 传 id 而不是捕获 model：闭包是 configure 时生成的，reconfigure 未落地前连点，
    /// 捕获的旧 model 会把两次切换算成同一个值 → 表现为「点了不动」
    var onToggleExpand: ((UUID) -> Void)?

    /// 当前配置的思考块 id（点击回调回传给 VC）
    private var modelID: UUID?

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.blt.hexColor(0xF7F8FA)
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        return v
    }()

    private let iconLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "🧠"
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x666666)
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        return lbl
    }()

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        return s
    }()

    private let chevronLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 12, weight: .semibold)
        lbl.textColor = UIColor.blt.hexColor(0x999999)
        return lbl
    }()

    private let bodyLabel: BLTContentInsetLabel = {
        let lbl = BLTContentInsetLabel()
        lbl.contentEdgeInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        lbl.textColor = UIColor.blt.hexColor(0x8A8A8A)
        lbl.font = .systemFont(ofSize: 13)
        lbl.numberOfLines = 0
        return lbl
    }()

    /// 竖向 stack：折叠时 body 隐藏，高度自动收缩
    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerView, bodyLabel])
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    private lazy var headerView: UIView = {
        let v = UIView()
        v.addSubview(iconLabel)
        v.addSubview(titleLabel)
        v.addSubview(spinner)
        v.addSubview(chevronLabel)
        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        spinner.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
        chevronLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        v.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(container)
        container.addSubview(stackView)

        // 命中区域 = 整个灰色块（头部 + 正文 + 内边距），不再只有 34pt 的头部条；
        // 挂在 container 上而非 contentView，避免与上下 item 间距重叠误触
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blockTapped)))

        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-4)
        }
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 0, bottom: 8, right: 0))
        }
        headerView.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
    }

    required init?(coder: NSCoder) { nil }

    /// 按压反馈：整块在手指出没期间有一次底色变化，避免「点了没反应」的错觉
    override var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }
            container.backgroundColor = UIColor.blt.hexColor(isHighlighted ? 0xEDEFF3 : 0xF7F8FA)
        }
    }

    @objc private func blockTapped() {
        guard let modelID else { return }
        onToggleExpand?(modelID)
    }

    func configure(model: DoubaoThinkingModel) {
        modelID = model.id
        if model.isStreaming {
            titleLabel.text = "思考中"
            spinner.startAnimating()
            chevronLabel.text = ""
        } else {
            titleLabel.text = "已深度思考 · 用时 \(model.elapsedSeconds) 秒"
            spinner.stopAnimating()
            chevronLabel.text = model.isExpanded ? "收起 ▲" : "展开 ▼"
        }
        bodyLabel.text = model.text
        // 流式中强制展开；结束后按 isExpanded
        bodyLabel.isHidden = model.isStreaming ? false : !model.isExpanded
        // 复用防串色：上一次高亮态可能残留在复用的 cell 上
        container.backgroundColor = UIColor.blt.hexColor(0xF7F8FA)
    }
}
