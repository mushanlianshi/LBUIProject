//
//  DoubaoAnswerBackground.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//


// MARK: - 答侧整段背景卡片（section background decoration）
/// 挂在 .answer section 上：一轮回答（思考块+正文+找人卡片+推荐问）整体包一张白色圆角卡片，
/// 与灰底页面/蓝色问气泡形成「这轮 AI 回答」的视觉边界
final class DoubaoAnswerBackground: UICollectionReusableView {

    static let kind = "DoubaoAnswerBackground"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.blt.hexColor(0xE8EEF5).cgColor
    }

    required init?(coder: NSCoder) { nil }
}
