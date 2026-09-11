//
//  DoubaoUserBubbleCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 用户消息气泡 —— 右对齐蓝色圆角气泡（UICollectionView 版）
final class DoubaoUserBubbleCell: UICollectionViewCell {

    static let reuseId = "DoubaoUserBubbleCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private let messageLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)

        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.greaterThanOrEqualToSuperview().offset(60)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-4)
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.80)
        }
        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    required init?(coder: NSCoder) { nil }

    func configure(text: String) {
        messageLabel.text = text
    }
}
