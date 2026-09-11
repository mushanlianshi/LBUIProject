//
//  DoubaoUnsupportedCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 未知卡片占位 cell（前向兼容兜底的 UI 层）
///
/// 服务端发布新卡片类型（老版本 App 无对应 case）时展示：
/// 虚线边框灰色卡 +「[卡片类型] 暂不支持」+「升级 App 后可查看」。
/// 数据不丢：rawType/rawPayload 已随整轮 JSON 落库同步，新版本打开即正常渲染
final class DoubaoUnsupportedCell: UICollectionViewCell {

    static let reuseId = "DoubaoUnsupportedCell"

    private let container: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.blt.hexColor(0xF7F8FA)
        v.layer.cornerRadius = 10
        v.layer.masksToBounds = true
        v.layer.borderColor = UIColor.blt.hexColor(0xD9DEE5).cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 10
        return v
    }()

    private let iconLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "🧩"
        lbl.font = .systemFont(ofSize: 20)
        lbl.textAlignment = .center
        return lbl
    }()

    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.blt.hexColor(0x999999)
        lbl.font = .systemFont(ofSize: 14, weight: .medium)
        return lbl
    }()

    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "升级 App 后可查看"
        lbl.textColor = UIColor.blt.hexColor(0xAAAAAA)
        lbl.font = .systemFont(ofSize: 12)
        return lbl
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(container)
        container.addSubview(iconLabel)
        container.addSubview(titleLabel)
        container.addSubview(subtitleLabel)

        container.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-4)
        }
        iconLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconLabel.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    required init?(coder: NSCoder) { nil }

    func configure(model: DoubaoUnsupportedModel) {
        titleLabel.text = "「\(model.displayName)」暂不支持"
    }
}
