//
//  DoubaoChatViewController+CollectionDataSources.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit

/// UICollectionView 数据源职责分类：
/// - Registration / DiffableDataSource 构造（setupDataSource）
/// - Compositional Layout per-section 配置（问/答 section + 答区背景 decoration）
/// - snapshot 构建与应用（applySnapshot）+ 两层更新（结构 append / 内容 reconfigure）
/// - WebView 高度回传的数据驱动链路（applyRenderedHeight / updateRenderedHeight）
/// - 滚动跟随（scrollToBottom / isNearBottom）+ UICollectionViewDelegate 滚动意图维护
///
/// ⚠️ 存储属性（dataSource / 各 registration / rounds 等）在主类里——
/// Swift extension 不能加存储属性，主类相关属性已去 private 供本分类访问
extension DoubaoChatViewController {

    // MARK: - DataSource 构造
    func setupDataSource() {
        // 1. 先创建全部 Registration（必须早于任何 cell provider 调用，见主类属性注释）
        userRegistration = UICollectionView.CellRegistration { cell, _, item in
            if case .user(let model) = item {
                cell.configure(text: model.text)
            }
        }
        thinkingRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .thinking(let model) = item {
                cell.configure(model: model)
                // 只回传 id：闭包捕获的 model 是 configure 时的快照，
                // reconfigure 未落地前连点会基于同一个旧值算，表现为「点了不动」
                cell.onToggleExpand = { [weak self] id in self?.toggleThinkingExpand(modelID: id) }
            }
        }
        markdownRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .markdown(let model) = item {
                cell.configure(model: model)
                // WebView 渲染高度回传（仅流式中触发，终态由 cell 静默处理）。
                // 高度走「数据驱动 reconfigure」：写回 model 后 reconfigure 该 item——
                // diffable 只更新这一个 cell（configure 同文本跳过 JS 重渲，仅高度约束生效）。
                // ⚠️ 不要用全局 invalidateLayout：它会无差别失效所有 cell 的缓存高度，
                // 整列表重新 self-size + 位置重排 → 多轮积累后每次高度回传都全列表跳动（闪烁卡顿）
                cell.onHeightChanged = { [weak self] modelID, height in
                    guard let self else { return }
                    self.applyRenderedHeight(modelID: modelID, height: height,
                                             followScroll: self.stickToBottom)
                }
                // 终态高度定型/修正：KaTeX 公式、Web 字体是异步加载的——真实高度可能分
                // 两次到达（文本先渲完报一次、公式渲完再报一次）。缓存有变化时必须
                // reconfigure 收敛 layout（否则停在第一次的中间值：公式卡下方空白/被裁）；
                // 与缓存一致（滚动复用同高度回传）才静默——防布局风暴的语义保留在去重判断里
                cell.onHeightSettled = { [weak self] modelID, height in
                    self?.settleRenderedHeight(modelID: modelID, height: height)
                }
            }
        }
        contactRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .contact(let model) = item {
                cell.configure(model: model)
                cell.onChatTapped = { name in
                    self?.sendQuestion("@\(name) 你好，想深入请教下这个问题")
                }
            }
        }
        recommendRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .recommend(let model) = item {
                cell.configure(model: model)
                cell.onQuestionTapped = { question in
                    self?.sendQuestion(question)
                }
            }
        }
        unsupportedRegistration = UICollectionView.CellRegistration { cell, _, item in
            if case .unsupported(let model) = item {
                cell.configure(model: model)
            }
        }
        actionsRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .actions(let model) = item {
                cell.configure(model: model)
                cell.onSpeech = { self?.speechCurrentRound() }
                cell.onCopy = {
                    self?.copyCurrentRound()
                    cell.showCopyFeedback()
                }
                cell.onLike = { self?.toggleFeedback(like: true) }
                cell.onDislike = { self?.toggleFeedback(like: false) }
            }
        }
        loadingRegistration = UICollectionView.CellRegistration { _, _, _ in
            // loading 无数据可配：纯动画占位卡
        }

        // 2. 再构造 dataSource（cell provider 闭包里只 dequeue，不创建任何东西）
        dataSource = UIKit.UICollectionViewDiffableDataSource<DoubaoChatSection, DoubaoChatItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .user:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.userRegistration, for: indexPath, item: item)
            case .thinking:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.thinkingRegistration, for: indexPath, item: item)
            case .markdown:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.markdownRegistration, for: indexPath, item: item)
            case .contact:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.contactRegistration, for: indexPath, item: item)
            case .recommend:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.recommendRegistration, for: indexPath, item: item)
            case .unsupported:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.unsupportedRegistration, for: indexPath, item: item)
            case .actions:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.actionsRegistration, for: indexPath, item: item)
            case .loading:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.loadingRegistration, for: indexPath, item: item)
            }
        }
    }

    // MARK: - Layout
    /// 单列 estimated 高度基础 section：卡片自撑（autodimension），流式增长自动重排
    static func makeBaseSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    /// per-section 布局分发：问 section 无背景，答 section 整段挂背景卡片 decoration
    func layoutSection(at index: Int) -> NSCollectionLayoutSection {
        guard let identifier = dataSource?.sectionIdentifier(for: index) else {
            return Self.makeBaseSection()
        }
        let section = Self.makeBaseSection()
        switch identifier {
        case .question:
            // 问（用户气泡）：蓝气泡自带背景，仅控制与答 section 的间距
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0)
        case .answer:
            // 答：整段一张白色圆角卡片（背景 decoration）。
            // section.contentInsets 缩进的是 cell/group；背景 decoration 铺满 section 外框——
            // 两者独立。要背景卡四周留 10pt 间距（与 cell 内容区对齐），用 decoration 自己的
            // contentInsets 缩进背景自身（正值即内缩），不动 section inset
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
            let background = NSCollectionLayoutDecorationItem.background(elementKind: DoubaoAnswerBackground.kind)
            background.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            section.decorationItems = [background]
        }
        return section
    }

    // MARK: - Diffable 两层更新
    /// 结构变化：往当前流式轮次的 answerItems 追加卡片（snapshot 全量重建，diff 自动算 insert）。
    /// 滚动策略：按 stickToBottom 意图跟随——用户上滑看历史时新卡片插入不打扰（对齐微信/Telegram），
    /// 拖回底部才恢复跟随；无条件滚底会导致「上滑被周期性弹回」（每次新卡片插入都拽人）
    func appendAnswerItem(_ item: DoubaoChatItem) {
        guard let roundID = currentRoundID,
              let index = rounds.firstIndex(where: { $0.id == roundID }) else { return }
        rounds[index].answerItems.append(item)
        applySnapshot(reconfiguring: nil, forceScrollToBottom: stickToBottom)
    }

    /// 内容变化（id 不变）：替换数据源后必须带新值重建 snapshot 并 reconfigure。
    /// ⚠️ 关键：snapshot 存的是 apply 时的值拷贝——只改数据源再 reconfigureItems，
    /// cell provider 收到的仍是 snapshot 里的旧值（流式表现为内容不增长，
    /// 直到下次结构性 append 重建 snapshot 才「一下子」出现全部文本）。
    /// 正确姿势：把最新数据重新 append 进 snapshot + reconfigure 标记变化项
    func updateItem(_ newItem: DoubaoChatItem) {
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: { $0 == newItem }) {
                rounds[r].answerItems[i] = newItem
                applySnapshot(reconfiguring: [newItem], forceScrollToBottom: stickToBottom)
                return
            }
        }
    }

    // MARK: - 准备数据源
    /// 统一的 snapshot 构建入口：按 rounds 全量重建（数据量小 diff 成本可忽略）。
    /// 每轮一对 section：.question(id) 装用户气泡、.answer(id) 装答侧卡片序列；
    /// 答侧为空时不加 answer section（避免空背景卡片闪现）
    func applySnapshot(reconfiguring: [DoubaoChatItem]?, forceScrollToBottom: Bool) {
        var snapshot = UIKit.NSDiffableDataSourceSnapshot<DoubaoChatSection, DoubaoChatItem>()
        for round in rounds {
            /// 添加问题的section 和 items
            snapshot.appendSections([.question(round.id)])
            snapshot.appendItems([.user(round.userModel)], toSection: .question(round.id))

            /// 添加回答的section 和items
            if !round.answerItems.isEmpty {
                snapshot.appendSections([.answer(round.id)])
                snapshot.appendItems(round.answerItems, toSection: .answer(round.id))
            }
        }
        if let reconfiguring, !reconfiguring.isEmpty {
            if #available(iOS 15.0, *) {
                snapshot.reconfigureItems(reconfiguring)
            } else {
                // iOS 14 无 reconfigure：reload 重建 cell（会闪光标，demo 可接受）
                snapshot.reloadItems(reconfiguring)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            if forceScrollToBottom {
                self?.scrollToBottom()
            }
        }
    }

    // MARK: - WebView 高度回传（数据驱动 reconfigure 增量更新）
    /// 流式中的高度回传：写回 model + reconfigure 对应 item（唯一增量更新路径）。
    /// 去重：高度与 model 缓存相同则跳过（JS 对同一文本可能反复报同高度）
    func applyRenderedHeight(modelID: UUID, height: CGFloat, followScroll: Bool) {
        guard !updateRenderedHeight(modelID: modelID, height: height) else { return }
        // 从 rounds 构造最新 item 走 reconfigure（文本没变，cell 只更新高度约束）
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(let m) = rounds[r].answerItems[i] {
                applySnapshot(reconfiguring: [.markdown(m)], forceScrollToBottom: followScroll)
                return
            }
        }
    }

    /// 终态高度修正（onHeightSettled 入口）：缓存有变化 → reconfigure 收敛（不滚动）。
    /// 与 applyRenderedHeight 的区别：不跟随滚动意图（终态修正不该拽人），只做布局收敛
    func settleRenderedHeight(modelID: UUID, height: CGFloat) {
        guard !updateRenderedHeight(modelID: modelID, height: height) else { return }
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(let m) = rounds[r].answerItems[i] {
                applySnapshot(reconfiguring: [.markdown(m)], forceScrollToBottom: false)
                return
            }
        }
    }

    /// 高度写回 model：更新 rounds 源（供复用/终态 configure 采用）+ 活跃引用
    /// （下一拍 updateItem 构造新 model 时带上，不被旧副本覆盖）。
    /// 同时写入宽度指纹（renderedWidth）：多端同步来的「别的宽度下的高度」恢复时据此作废。
    /// 返回 true = 高度未变化（重复回传，调用方据此跳过 invalidate）
    @discardableResult
    func updateRenderedHeight(modelID: UUID, height: CGFloat) -> Bool {
        let renderWidth = collectionView.frame.width
        var duplicated = true
        if markdownModel?.id == modelID, markdownModel?.renderedHeight != height {
            markdownModel?.renderedHeight = height
            markdownModel?.renderedWidth = renderWidth
            duplicated = false
        }
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(var m) = rounds[r].answerItems[i], m.renderedHeight != height {
                m.renderedHeight = height
                m.renderedWidth = renderWidth
                rounds[r].answerItems[i] = .markdown(m)
                duplicated = false
            }
        }
        return duplicated
    }

    // MARK: - 思考块折叠/展开
    /// 内容变化（id 不变），同样走 reconfigure。
    /// - 按 id 回查最新 model：cell 回调只带 id，避免基于 configure 时的旧状态反复切换
    /// - forceScrollToBottom 传 false：展开/收起是原地变化，若跟着 stickToBottom 滚到底，
    ///   会把块顶走、手指下的内容换掉，表现成「点不中 / 点了没反应」
    func toggleThinkingExpand(modelID: UUID) {
        for r in rounds.indices {
            guard let i = rounds[r].answerItems.firstIndex(where: { item in
                if case .thinking(let m) = item { return m.id == modelID }
                return false
            }), case .thinking(var model) = rounds[r].answerItems[i] else { continue }
            guard !model.isStreaming else { return }  // 流式中禁止收起
            model.isExpanded.toggle()
            rounds[r].answerItems[i] = .thinking(model)
            applySnapshot(reconfiguring: [.thinking(model)], forceScrollToBottom: false)
            return
        }
    }

    // MARK: - Scroll
    func scrollToBottom(animated: Bool = false) {
        debugPrint("LBLog scrollToBottom -------------------------")
        let lastSection = collectionView.numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: lastItem, section: lastSection),
                                    at: .bottom, animated: animated)
    }

    func isNearBottom() -> Bool {
        let contentH = collectionView.contentSize.height
        let offsetY = collectionView.contentOffset.y
        let visibleH = collectionView.bounds.height
        return contentH - offsetY - visibleH < 80
    }
}

// MARK: - 滚动意图维护（同旧版：用户上滑看历史则停止跟随，拖回底部恢复）
extension DoubaoChatViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            stickToBottom = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stickToBottom = isNearBottom()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stickToBottom = isNearBottom()
        }
    }
}
