//
//  DoubaoContactCardCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 找人卡片 cell —— 正文流式中途穿插插入的结构性卡片：
/// 头像（姓名首字 + 稳定取色）、姓名/头衔、一句话介绍、擅长标签、「找 TA 追问」按钮
final class DoubaoContactCardCell: UICollectionViewCell {

    static let reuseId = "DoubaoContactCardCell"

    /// 点击「找 TA 追问」
    var onChatTapped: ((String) -> Void)?

    private let cardView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.blt.hexColor(0xE8EEF5).cgColor
        return v
    }()

    private let avatarLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 20
        lbl.layer.masksToBounds = true
        return lbl
    }()

    private let nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x333333)
        lbl.font = .systemFont(ofSize: 15, weight: .semibold)
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x0E8AFD)
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()

    private let introLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x666666)
        lbl.font = .systemFont(ofSize: 13)
        lbl.numberOfLines = 2
        return lbl
    }()

    private let tagsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x999999)
        lbl.font = .systemFont(ofSize: 11)
        lbl.numberOfLines = 1
        return lbl
    }()

    private lazy var chatButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("找 TA 追问", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
        return btn
    }()

    private var contactName: String = ""

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(cardView)
        cardView.addSubview(avatarLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(titleLabel)
        cardView.addSubview(introLabel)
        cardView.addSubview(tagsLabel)
        cardView.addSubview(chatButton)

        cardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-4)
        }
        avatarLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(40)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarLabel).offset(1)
            make.leading.equalTo(avatarLabel.snp.trailing).offset(10)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
        }
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }
        tagsLabel.snp.makeConstraints { make in
            make.top.equalTo(introLabel.snp.bottom).offset(6)
            make.leading.trailing.equalTo(introLabel)
        }
        chatButton.snp.makeConstraints { make in
            make.top.equalTo(tagsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder: NSCoder) { nil }

    @objc private func chatTapped() {
        onChatTapped?(contactName)
    }

    func configure(model: DoubaoContactModel) {
        contactName = model.name
        avatarLabel.text = String(model.name.prefix(1))
        avatarLabel.backgroundColor = UIColor.blt.hexColor(model.avatarColorHex)
        nameLabel.text = model.name
        titleLabel.text = model.title
        introLabel.text = model.intro
        tagsLabel.text = "擅长：\(model.tags.joined(separator: " / "))"
    }
}
