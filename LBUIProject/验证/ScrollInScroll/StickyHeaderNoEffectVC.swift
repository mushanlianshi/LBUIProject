import UIKit
import SnapKit

class StickyHeaderNoEffectVC: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .plain)

    private let maxHeaderHeight: CGFloat = 500
    private let minHeaderHeight: CGFloat = 300
    private var collapseRange: CGFloat { maxHeaderHeight - minHeaderHeight }

    private let placeholderHeader = UIView() // tableHeaderView 占位
    private let stickyHeader = UIView()      // 真正显示的 Header

    private var stickyHeaderHeightConstraint: Constraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupStickyHeader()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView()

        // 给 tableView content 提供初始偏移空间（用占位 header）
        placeholderHeader.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: maxHeaderHeight)
        tableView.tableHeaderView = placeholderHeader
    }

    private func setupStickyHeader() {
        // Sticky header 放在 tableView 上方，并固定在顶部
        view.addSubview(stickyHeader)
        stickyHeader.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            stickyHeaderHeightConstraint = make.height.equalTo(maxHeaderHeight).constraint
        }

        stickyHeader.backgroundColor = .systemBlue

        // ✅ 让 Header 不阻挡滑动手势：触摸穿透
        stickyHeader.isUserInteractionEnabled = false

        view.bringSubviewToFront(stickyHeader)
    }

    private func updateHeaderHeight(_ offsetY: CGFloat) {
        if offsetY >= 0 {
            // 上滑折叠阶段
            let collapse = min(offsetY, collapseRange)
            stickyHeaderHeightConstraint.update(offset: maxHeaderHeight - collapse)
        } else {
            // 下拉阶段（不放大，不变大，保持最大高度）
            stickyHeaderHeightConstraint.update(offset: maxHeaderHeight)
        }

        view.layoutIfNeeded()
    }
}

extension StickyHeaderNoEffectVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 100 }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Cell \(indexPath.row)"
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderHeight(scrollView.contentOffset.y)
    }
}
