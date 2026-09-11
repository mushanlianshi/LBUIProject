//
//  DoubaoRecommendCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 推荐问卡片 cell —— 「猜你想问」+ 竖排问题 chips，点击 chip 发起新一轮对话
final class DoubaoRecommendCell: UICollectionViewCell {

    static let reuseId = "DoubaoRecommendCell"

    /// 点击某个推荐问题（VC 以此作为用户提问发起新一轮流式）
    var onQuestionTapped: ((String) -> Void)?

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "猜你想问"
        lbl.textColor = UIColor.blt.hexColor(0x999999)
        lbl.font = .systemFont(ofSize: 12, weight: .medium)
        return lbl
    }()

    /// 竖排 chips 容器（问题数量运行时变化，StackView 动态增删）
    private lazy var chipStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(titleLabel)
        contentView.addSubview(chipStack)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(44)
        }
        chipStack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) { nil }

    /// 当前 questions（chip 点击时取用，configure 每次刷新）
    private var currentQuestions: [String] = []

    func configure(model: DoubaoRecommendModel) {
        currentQuestions = model.questions
        // diffable reconfigure 会重复调用 configure，先清空旧 chips 再重建
        chipStack.arrangedSubviews.forEach {
            chipStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        model.questions.enumerated().forEach { index, question in
            chipStack.addArrangedSubview(makeChip(question: question, index: index))
        }
    }

    private func makeChip(question: String, index: Int) -> UIView {
        let btn = UIButton(type: .system)
        btn.tag = index
        btn.setTitle("  \(question)  ", for: .normal)
        btn.setTitleColor(UIColor.blt.hexColor(0x0E8AFD), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.contentHorizontalAlignment = .left
        btn.backgroundColor = UIColor.blt.hexColor(0xE8F1FE)
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        btn.snp.makeConstraints { make in
            // priority 999：self-size 测量期 contentView 可能被临时钉在 estimated 高度（如 60），
            // 与 chips 固有高度冲突刷屏；降级后测量冲突可被打破，布局阶段仍按 38 生效
            make.height.equalTo(38).priority(999)
        }
        return btn
    }

    @objc private func chipTapped(_ sender: UIButton) {
        // tag 存的是问题下标；currentQuestions 每次 configure 都会刷新，不担心复用错位
        guard sender.tag < currentQuestions.count else { return }
        onQuestionTapped?(currentQuestions[sender.tag])
    }
}
