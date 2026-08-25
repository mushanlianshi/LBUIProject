//
//  LBBluetoothUIKitRow.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/25.
//

import Foundation
import SwiftUI

// MARK: - UIViewRepresentable 桥接
struct LBBluetoothUIKitRow: UIViewRepresentable {

    let name: String
    let mode: LBBluetoothUIKitRowContainer.RowMode
    /// 普通态是否绘制行底部分割线（末行无）
    var showsSeparator: Bool = false

    func makeUIView(context: Context) -> LBBluetoothUIKitRowContainer {
        LBBluetoothUIKitRowContainer(frame: .zero)
    }

    func updateUIView(_ uiView: LBBluetoothUIKitRowContainer, context: Context) {
        uiView.render(name: name, mode: mode, showsSeparator: showsSeparator)
    }
}




// MARK: - UIKit 行视图容器（右上角 UIKitCell 按钮选中时启用）
/// 用 UIKit 实现的行内容（BLT 约定创建控件，SnapKit 布局），
/// 经 UIViewRepresentable 桥接到 SwiftUI，三种渲染状态与 SwiftUI 行内容一一对应
class LBBluetoothUIKitRowContainer: UIView {

    enum RowMode {
        case selected       // 上卡片选中态：设备名 + 蓝色对勾
        case normal         // 「其它」分组行：设备名 + 未连接
        case placeholder    // 上卡片空态占位
    }

    /// 设备名 14pt #333 medium
    private lazy var nameLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(14), textColor: .blt.threeThreeBlackColor())
        return label
    }()

    /// 「未连接」14pt #777
    private lazy var statusLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: UIColor.blt.hexColor(0x777777))
        return label
    }()

    /// 选中对勾（项目蓝还原设计稿 duihao 图层）
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "checkmark")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
        return imageView
    }()

    /// 行底部分割线 0.5pt #DDD，左缩进 12
    private lazy var separatorLine: UIView = {
        let view = UIView.blt.initWithBackgroundColor(color: UIColor.blt.hexColor(0xDDDDDD))
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(checkImageView)
        addSubview(separatorLine)

        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        checkImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(12)
        }
        separatorLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 渲染（每次恢复基础色，避免占位态灰字污染其它状态）
    func render(name: String, mode: RowMode, showsSeparator: Bool = false) {
        switch mode {
        case .selected:
            nameLabel.text = name
            nameLabel.textColor = .blt.threeThreeBlackColor()
            statusLabel.isHidden = true
            checkImageView.isHidden = false
            separatorLine.isHidden = true
        case .normal:
            nameLabel.text = name
            nameLabel.textColor = .blt.threeThreeBlackColor()
            statusLabel.text = "未连接"
            statusLabel.isHidden = false
            checkImageView.isHidden = true
            separatorLine.isHidden = !showsSeparator
        case .placeholder:
            nameLabel.text = "暂未选择设备"
            nameLabel.textColor = .blt.ninenineBlackColor()
            statusLabel.isHidden = true
            checkImageView.isHidden = true
            separatorLine.isHidden = true
        }
    }
}
