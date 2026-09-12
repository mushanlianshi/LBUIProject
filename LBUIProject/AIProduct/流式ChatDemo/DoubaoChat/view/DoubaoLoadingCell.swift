//
//  DoubaoLoadingCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/12.
//

import UIKit
import SnapKit

/// 加载占位 cell：三个点依次跳动（豆包等待动画风格）。
/// 纯 UI 态卡片：随插入出现、内容开始输出时被结构性删除（diffable 自动算 delete）
///
/// 动画时序要点（复用场景的坑）：
/// - 不能在 layoutSubviews 启动：self-size 测量会反复触发 layout（复用时尤甚），
///   每次 layout 掐掉 layer 上的动画 → 第二轮复用时「三点不动」
/// - 不能依赖 UIView.animate：复用后的约束更新会隐式重置 transform/alpha
/// - 正解：didMoveToWindow（cell 真正上屏）启动 CABasicAnimation——
///   显式动画挂在 presentation layer 上，不受后续 layout 的隐式重置影响；
///   removedOnCompletion=false + fillMode 循环驻留
final class DoubaoLoadingCell: UICollectionViewCell {

    static let reuseId = "DoubaoLoadingCell"

    private let dotColor = UIColor.blt.hexColor(0x0E8AFD)

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
    }()

    private var dots: [UIView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(stackView)
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = dotColor
            dot.layer.cornerRadius = 3
            dot.layer.masksToBounds = true
            stackView.addArrangedSubview(dot)
            dots.append(dot)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(44)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
        dots.forEach { $0.snp.makeConstraints { make in make.width.height.equalTo(6) } }
    }

    required init?(coder: NSCoder) { nil }

    /// cell 上屏（含复用后再次上屏）启动动画——window 挂载时机不受复用重布局干扰
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startBouncingIfNeeded()
        }
    }

    /// 三点依次跳动：position.y 弹跳 + 透明度呼吸，相位错开 0.18s，无限循环。
    /// CABasicAnimation 显式动画：removedOnCompletion=false + fillMode=both
    /// 让动画驻留 presentation layer，后续任何 layout 都不会隐式掐掉它
    private func startBouncingIfNeeded() {
        for (index, dot) in dots.enumerated() {
            let layer = dot.layer
            // 幂等：已挂动画的 dot 跳过（didMoveToWindow 可能多次触发）
            guard layer.animation(forKey: "loading.bounce") == nil else { continue }

            let delay = Double(index) * 0.18
            let begin = CACurrentMediaTime() + delay

            // 上跳动画（keyPath 用 position.y 而非 transform：
            // 隐式动画位 transform 会被复用时的布局重置，presentation layer 不受影响）
            let bounce = CABasicAnimation(keyPath: "position.y")
            bounce.fromValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
            bounce.toValue = NSValue(cgPoint: CGPoint(x: 0, y: -4))
            bounce.duration = 0.45
            bounce.autoreverses = true
            bounce.repeatCount = .infinity
            bounce.beginTime = begin
            bounce.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            bounce.isRemovedOnCompletion = false
            layer.add(bounce, forKey: "loading.bounce")

            // 透明度呼吸（同相位）
            let breathe = CABasicAnimation(keyPath: "opacity")
            breathe.fromValue = 1.0
            breathe.toValue = 0.35
            breathe.duration = 0.45
            breathe.autoreverses = true
            breathe.repeatCount = .infinity
            breathe.beginTime = begin
            breathe.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            breathe.isRemovedOnCompletion = false
            layer.add(breathe, forKey: "loading.breathe")
        }
    }
}
