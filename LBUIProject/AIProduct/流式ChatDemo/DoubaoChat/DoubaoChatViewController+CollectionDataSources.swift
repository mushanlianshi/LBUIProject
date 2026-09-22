//
//  DoubaoChatViewController+CollectionDataSources.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit

/// UICollectionView 数据源职责分类：
/// - Registration / DiffableDataSource 构造（setupDataSource）——
///   cell 交互回调（折叠/高度回传/赞踩）全部转调流桶 DoubaoChatSessionStream
/// - Compositional Layout per-section 配置（问/答 section + 答区背景 decoration）
/// - snapshot 构建与应用（applySnapshot）：数据源是流桶的 stream.rounds
/// - 流订阅翻译（DoubaoChatStreamDelegate 在主文件）：流通知 → applySnapshot 两层更新
/// - 滚动跟随（scrollToBottom / isNearBottom）+ UICollectionViewDelegate 滚动意图维护
///
/// ⚠️ 存储属性（dataSource / 各 registration / stream 等）在主类里——
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
                cell.onToggleExpand = { [weak self] id in self?.stream.toggleThinkingExpand(modelID: id) }
            }
        }
        markdownRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .markdown(let model) = item {
                cell.configure(model: model)
                // WebView 渲染高度回传（仅流式中触发，终态由 cell 静默处理）。
                // 高度走「数据驱动 reconfigure」链路：写回流桶 model → 桶通知 →
                // reconfigure 该 item（configure 同文本跳过 JS 重渲，仅高度约束生效）。
                // ⚠️ 不要用全局 invalidateLayout：它会无差别失效所有 cell 的缓存高度，
                // 整列表重新 self-size + 位置重排 → 多轮积累后每次高度回传都全列表跳动（闪烁卡顿）
                cell.onHeightChanged = { [weak self] modelID, height in
                    guard let self else { return }
                    self.stream.applyRenderedHeight(modelID: modelID, height: height,
                                                    renderWidth: self.collectionView.frame.width)
                }
                // 终态高度定型/修正：KaTeX 公式、Web 字体是异步加载的——真实高度可能分
                // 两次到达（文本先渲完报一次、公式渲完再报一次）。缓存有变化时必须
                // reconfigure 收敛 layout（否则停在第一次的中间值：公式卡下方空白/被裁）；
                // 与缓存一致（滚动复用同高度回传）才静默——防布局风暴的语义保留在去重判断里
                cell.onHeightSettled = { [weak self] modelID, height in
                    guard let self else { return }
                    self.stream.settleRenderedHeight(modelID: modelID, height: height,
                                                     renderWidth: self.collectionView.frame.width)
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
                cell.onLike = { self?.stream.toggleFeedback(like: true) }
                cell.onDislike = { self?.stream.toggleFeedback(like: false) }
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

    // MARK: - 准备数据源
    /// 统一的 snapshot 构建入口：按流桶 rounds 全量重建（数据量小 diff 成本可忽略）。
    /// 每轮一对 section：.question(id) 装用户气泡、.answer(id) 装答侧卡片序列；
    /// 答侧为空时不加 answer section（避免空背景卡片闪现）
    /// completion：apply 完成（可选滚动后）回调——历史恢复首帧定位的「数据源就绪」信号
    ///
    /// ⚠️ 用户手势进行中（拖拽/减速）挂起 apply：diffable apply 在 contentSize 变化时
    /// 会调整 contentOffset（UIKit 的可见项保持补偿）——流式期间每拍 apply 与手指
    /// 抢 offset → 橡皮筋来回反弹抖动（豆包类产品流式中不动列表框架，无此问题）。
    /// 数据照常写 rounds（内存态不丢），snapshot 攒挂起标记，松手一次性补 apply
    func applySnapshot(reconfiguring: [DoubaoChatItem]?,
                       forceScrollToBottom: Bool,
                       completion: (() -> Void)? = nil) {
        // 手势期间挂起（首帧豁免：dataSource 从未 apply 过时必须放行——
        // setupSession 发生在任何手势之前，此条件只为防御极端时序下的空列表锁死）
        let isInitialApply = collectionView.numberOfSections == 0
        if !isInitialApply,
           collectionView.isDragging || collectionView.isDecelerating || collectionView.isTracking {
            pendingApplyDuringGesture = true
            // completion 不能丢：一次性回调挂起期间直接执行（数据已在 rounds，语义无损）
            completion?()
            return
        }

        var snapshot = UIKit.NSDiffableDataSourceSnapshot<DoubaoChatSection, DoubaoChatItem>()
        for round in stream.rounds {
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
            guard let self else { return }
            if forceScrollToBottom {
                self.scrollToBottom()
            }
            completion?()
        }
    }

    /// 松手补拍：DidEndDragging/DidEndDecelerating 里调用——
    /// 手势期间攒下的所有数据变化（流式文本 N 拍 + 可能的新卡片）一次 apply 完。
    /// （pendingApplyDuringGesture 存储属性在主类——extension 不能加存储属性）
    ///
    /// ⚠️ 必须全量 reconfigure：挂起期间「id 不变、值变了」的内容更新
    /// （流式文本增长、定格去光标、高度写回）在 diff 眼里是零变化——
    /// 若 reconfiguring 传 nil，重建 snapshot 后 item 标识符全部未动，
    /// diff 判定无事发生，可见 cell 永远停在松手前的旧文本；
    /// 而挂起期间结构插入的新卡片能正常出现（insert 算得出来）——
    /// 表现为「后面的泡泡都出了，前面那张流式卡内容不全」的漏洞。
    /// 补拍把当前全部 item 标记 reconfigure：configure 幂等
    /// （markdown 同文本跳过 JS 重渲），且 reconfigureItems 只触达可见 cell，
    /// 一次手势结束只补一次，成本可控
    func flushPendingApplyIfNeeded() {
        guard pendingApplyDuringGesture else { return }
        pendingApplyDuringGesture = false
        var allItems: [DoubaoChatItem] = []
        for round in stream.rounds {
            allItems.append(.user(round.userModel))
            allItems.append(contentsOf: round.answerItems)
        }
        applySnapshot(reconfiguring: allItems, forceScrollToBottom: stickToBottom)
    }

    // MARK: - Scroll
    func scrollToBottom(animated: Bool = false) {
        debugPrint("LBLog scrollToBottom -------------------------")
        // ⚠️ 用户手势进行中不程序滚底：流式期间用户按住列表时，程序滚动会与手指拖拽
        // 互相拉扯（setContentOffset 抢占 pan 手势的 offset → 反弹 → 再滚 → 来回抖动）。
        // 跳过后由「松手判定 + stickToBottom」接管：在底部松手 → 恢复跟随；不在 → 不跟随
        guard !collectionView.isDragging, !collectionView.isDecelerating else { return }
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
        // ⚠️ 橡皮筋（bounces）期间不判定意图：拖到顶/底越界时 offset 是负值/越界值，
        // isNearBottom 的计算被污染（内容增长时相对位置漂移 → 判定翻转 → 恢复跟随 →
        // 程序滚底拽人 → 用户再拖 → 来回抖动）。越界期间冻结意图，松手回弹后再判
        let isBouncing = scrollView.contentOffset.y < -scrollView.contentInset.top
            || scrollView.contentOffset.y > scrollView.contentSize.height
                - scrollView.bounds.height + scrollView.contentInset.bottom
        if !isBouncing, scrollView.isDragging || scrollView.isDecelerating {
            stickToBottom = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stickToBottom = isNearBottom()
        flushPendingApplyIfNeeded()   // 惯性滚动结束：补拍手势期间攒下的 snapshot
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stickToBottom = isNearBottom()
            flushPendingApplyIfNeeded()   // 松手即停（无惯性）：立即补拍
        }
        // 有惯性时由 DidEndDecelerating 兜底补拍
    }
}
