//
//  DoubaoMarkdownCell.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import WebKit
import SnapKit

/// AI 正文 cell —— 左侧 AI 头像 + ChatWebView 渲染 Markdown（表格/代码高亮/KaTeX 公式）
///
/// 渲染策略对齐旧版 AssistantMarkdownCell（UITableView 版）：
/// - cell 内常驻一个 ChatWebView（marked + highlight.js + KaTeX，离线可用），随复用不重建
/// - configure/reconfigure 都把「当前完整累积文本」全量交给 WebView 重渲——
///   流式增量到达时 reconfigureItems 触发本方法，滚动复用后也永远不空白
/// - 渲染高度由 WebView 异步回传：先更新 cell 内高度约束，再（死区防抖后）通知 VC
///   invalidateLayout 让 compositional layout 重新 self-size
final class DoubaoMarkdownCell: UICollectionViewCell {

    static let reuseId = "DoubaoMarkdownCell"

    /// 高度变化回调（仅流式输出中触发；死区防抖后）。
    /// 终态 cell（isStreaming == false 且有缓存高度）不走此回调：滚动复用时高度静默就位，
    /// 不打扰 VC 布局——这是防「滚动时布局风暴」的关键一环
    var onHeightChanged: ((UUID, CGFloat) -> Void)?

    /// 终态高度定型回调（JS 渲染完最终全文后触发一次）：
    /// VC 只把它写回 model 缓存（供下次复用 configure 直接采用），不 invalidate 不滚动
    var onHeightSettled: ((UUID, CGFloat) -> Void)?

    /// 当前渲染的 model id（高度回传时标识归属）
    private var currentModelID: UUID?
    /// 当前 model 是否流式输出中（onHeight 分支判断用）
    private var isStreamingState = true
    /// configure 时带入的缓存高度（历史/终态复用；onHeight 防回缩用）
    private var configuredHeight: CGFloat = 0

    /// 当前 model 的缓存高度（无则 nil）
    private func cachedHeight(for id: UUID) -> CGFloat? {
        guard id == currentModelID, configuredHeight > 0 else { return nil }
        return configuredHeight
    }

    /// 上次交给 WebView 渲染的文本（同文本跳过重渲：
    /// 高度回传触发的 reconfigure 只改高度字段，不重跑几百 ms 的 JS 渲染）
    private var lastRenderedText: String?

    /// Markdown 渲染内核（与旧版 AssistantMarkdownCell 同款，可复用不重建）
    private let webView: ChatWebView = ChatWebView()

    /// WebView 高度约束（onHeight 回调实时更新）
    private var heightConstraint: Constraint!

    /// 上次上报高度（8pt 死区：KaTeX 字体落定等 ±几 pt 抖动被挡掉，防逐帧重排）
    private var lastReportedHeight: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(3)
            make.trailing.equalToSuperview().offset(-3)
            make.bottom.equalToSuperview().offset(-6)
            heightConstraint = make.height.equalTo(1).constraint
        }

        webView.onHeight = { [weak self] height in
            guard let self else { return }
            // 历史记录防回缩（同旧版 AssistantMarkdownCell）：缓存高度大于新报值时保持缓存，
            // 挡掉 JS 重渲先报中间值导致的跳变
            if let id = self.currentModelID,
               let cached = self.cachedHeight(for: id), cached > height {
                self.heightConstraint.update(offset: cached)
                return
            }
            self.heightConstraint.update(offset: height)
            guard self.isStreamingState else {
                // 终态：高度静默就位（滚动复用/历史加载场景），不打扰 VC 布局；
                // 仅把最终定型高度写回 model 缓存（下轮复用 configure 直接采用）
                self.lastReportedHeight = height
                if let id = self.currentModelID {
                    self.onHeightSettled?(id, height)
                }
                return
            }
            // 死区防抖：增长超 8pt 或任何收缩才上报（同旧版 handleAssistantHeight 思想）
            if abs(height - self.lastReportedHeight) > 8 || height < self.lastReportedHeight {
                self.lastReportedHeight = height
                if let id = self.currentModelID {
                    self.onHeightChanged?(id, height)
                }
            }
        }
    }

    required init?(coder: NSCoder) { nil }

    /// 配置/流式更新统一入口。
    /// - 终态且有缓存高度（终态定格/滚动复用/历史加载）：约束直接采用缓存高度
    /// - 复用到「不同 item」：高度约束重置为 1，新内容渲染期间不占旧 item 的巨大高度
    /// - ⚠️ 同文本跳过 WebView 重渲：高度回传后 VC 会 reconfigure 本 cell（只更新高度字段），
    ///   若不跳过，每次高度变化都会触发几百 ms 的 JS 全文重渲 + 新一轮高度回传 → 死循环
    func configure(model: DoubaoMarkdownModel) {
        let isReuseToOtherItem = (currentModelID != model.id)
        currentModelID = model.id
        isStreamingState = model.isStreaming
        configuredHeight = model.renderedHeight
        if model.renderedHeight > 0 {
            // 有缓存高度（高度回传触发的 reconfigure / 终态定格 / 复用终态卡）：直接采用。
            // 流式中此处约束=上一拍高度，本拍渲染完报更高再走一轮回传，链路闭环
            heightConstraint.update(offset: model.renderedHeight)
            lastReportedHeight = model.renderedHeight
        } else if isReuseToOtherItem {
            heightConstraint.update(offset: 1)
            lastReportedHeight = 0
        } else {
            lastReportedHeight = 0
        }
        if lastRenderedText != model.text {
            lastRenderedText = model.text
            webView.renderMarkdown(model.text)
        }
    }
}
