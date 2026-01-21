import UIKit
import SnapKit


class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 返回 nil 代表不拦截触摸，交给下面的视图（tableView）
        return nil
    }
}


class LBStickyCollapsibleHeaderVC: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    // Header config
    private let maxHeaderHeight: CGFloat = 500
    private let minHeaderHeight: CGFloat = 300
    private var collapseRange: CGFloat { maxHeaderHeight - minHeaderHeight }

    // 占位 header（作为 tableHeaderView）和真正可见的悬停 header
    private let spacerHeader = UIView()        // 只作占位，height = maxHeaderHeight
    private let stickyHeader = PassthroughView()        // 可变化的悬停 header
    private var stickyHeaderHeightConstraint: Constraint!

    // header 内部内容 (示例)
    private let headerContentView = UIView()
    private let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupHeaders()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .singleLine

        // spacerHeader 只做占位，给 content 提供初始 offset
        spacerHeader.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: maxHeaderHeight)
        tableView.tableHeaderView = spacerHeader
        
        enableHeaderPan()
    }
    
    private lazy var headerPan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPan(_:)))
        return pan
    }()

    private func enableHeaderPan() {
        stickyHeader.addGestureRecognizer(headerPan)
    }

    @objc private func handleHeaderPan(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view).y
        pan.setTranslation(.zero, in: view)

        let newOffset = tableView.contentOffset.y - translation
        tableView.setContentOffset(CGPoint(x: 0, y: newOffset), animated: false)
    }

    private func setupHeaders() {
        // stickyHeader 放到 tableView 之上（或 view 上），并固定在 safeArea 顶部/导航下方
        view.addSubview(stickyHeader)
        stickyHeader.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            // 顶部贴到 safeArea (若有导航栏，根据需求可用 view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            // 初始高度为 maxHeaderHeight
            stickyHeaderHeightConstraint = make.height.equalTo(maxHeaderHeight).constraint
        }

        // header 内容示例（放在 stickyHeader 内）
        stickyHeader.addSubview(headerContentView)
        headerContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headerContentView.backgroundColor = .systemOrange

        // 标题示例
        titleLabel.text = "HEADER"
        titleLabel.font = .boldSystemFont(ofSize: 36)
        titleLabel.textColor = .white
        headerContentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 使 stickyHeader 在 tableView 之上显示（避免被 cell 覆盖）
        view.bringSubviewToFront(stickyHeader)
    }

    // update header height based on tableView offset
    private func updateHeader(for scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        // 当 offsetY 从 0 开始向上增大：先消耗 collapseRange（让 header 从 max -> min），
        // 超出 collapseRange 的 offset 由 tableView 的 cell 消耗（stickyHeader 保持 minHeight）
        if offsetY >= 0 {
            // collapse = clamp(offsetY, 0, collapseRange)
            let collapse = min(max(0, offsetY), collapseRange)
            let newHeight = maxHeaderHeight - collapse
            stickyHeaderHeightConstraint.update(offset: newHeight)
            // 进度用于渐隐等视觉效果（0 = fully open, 1 = fully collapsed）
            let progress = collapse / collapseRange
            applyVisualEffects(progress: progress)
        } else {
            
            /// 不需要放大效果
//            return
            
            // 下拉：offsetY < 0 -> header 放大 (可以放大到任意值，限制到 maxHeaderHeight * 1.5 可选)
            // newHeight = min(maxHeaderHeight * 1.5, maxHeaderHeight - offsetY)
            let expanded = maxHeaderHeight - offsetY // offsetY negative => minus negative = plus
            var capped = min(expanded, maxHeaderHeight * 1.5)
            
            /// 不需要变大效果
            capped = maxHeaderHeight
            
            stickyHeaderHeightConstraint.update(offset: capped)
            let progress = (maxHeaderHeight - capped) / collapseRange
            applyVisualEffects(progress: max(0, min(1, progress)))
        }

        // 必须让 layout 立即生效
        view.layoutIfNeeded()
    }

    private func applyVisualEffects(progress: CGFloat) {
        // progress 0..1 (0 open, 1 collapsed)
        // 这里实现一个简单的渐隐或缩放效果
        headerContentView.alpha = 1.0 - progress * 0.6
        // 也可以对 titleLabel 缩放：
        let scale = 1.0 - 0.1 * progress
        titleLabel.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension LBStickyCollapsibleHeaderVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 100 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeader(for: scrollView)
    }

    // 可选：滑动结束时做自动展开/收起补间动画
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            settleHeaderIfNeeded()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        settleHeaderIfNeeded()
    }

    private func settleHeaderIfNeeded() {
        // 自动补间：如果 header 折叠进度 > 0.5 自动收起，否则展开
        // 计算当前高度并触发动画
        let currentHeight = stickyHeader.frame.height
        let progress = (maxHeaderHeight - currentHeight) / collapseRange
        let shouldCollapse = progress > 0.5

        let targetHeight: CGFloat = shouldCollapse ? minHeaderHeight : maxHeaderHeight

        // 动画补间
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.stickyHeaderHeightConstraint.update(offset: targetHeight)
            self.applyVisualEffects(progress: shouldCollapse ? 1 : 0)
            self.view.layoutIfNeeded()
        }
    }
}
