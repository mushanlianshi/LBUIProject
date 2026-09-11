//
//  DoubaoChatSessionListViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

/// 豆包对话历史会话列表（入口：DoubaoChatViewController 右上角「历史记录」）
/// 交互对齐旧版 ChatSessionListViewController：点击进入该会话继续聊、左滑删除（级联删轮次）
class DoubaoChatSessionListViewController: UIViewController {

    private var sessions: [DoubaoChatSessionModel] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        tableView.separatorStyle = .none
        tableView.rowHeight = 72
        tableView.register(DoubaoSessionCell.self, forCellReuseIdentifier: NSStringFromClass(DoubaoSessionCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        navigationItem.title = "豆包对话历史"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 从会话页返回时刷新（新增轮次/删除会话后列表要更新）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSessions()
    }

    private func reloadSessions() {
        sessions = DoubaoChatDAO.shared.listSessions()
        tableView.reloadData()
        debugPrint("LBLog 豆包会话列表刷新，共 \(sessions.count) 个会话")
    }
}

// MARK: - UITableViewDataSource / Delegate
extension DoubaoChatSessionListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DoubaoSessionCell.self), for: indexPath) as! DoubaoSessionCell
        let session = sessions[indexPath.row]
        cell.render(session: session, roundCount: DoubaoChatDAO.shared.roundCount(sessionId: session.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /// 进入历史会话继续聊（轮次在 DoubaoChatViewController.viewDidLoad 恢复）
        let vc = DoubaoChatViewController()
        vc.existingSession = sessions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 左滑删除（外键级联删除该会话所有轮次）
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { [weak self] _, indexPath in
            guard let self else { return }
            let session = self.sessions.remove(at: indexPath.row)
            DoubaoChatDAO.shared.deleteSession(session.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            debugPrint("LBLog 删除豆包会话 \(session.id)")
        }
        return [deleteAction]
    }
}

// MARK: - Cell（BLTUIKit 约定创建控件）
private class DoubaoSessionCell: UITableViewCell {

    /// 会话标题：无标题（一次没聊就退）显示「新会话」占位
    private lazy var titleLabel: UILabel = {
        UILabel.blt.initWithFont(font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor(), numberOfLines: 1)
    }()

    /// 副标题：N 轮对话 · 创建时间
    private lazy var detailLabel: UILabel = {
        UILabel.blt.initWithFont(font: .blt.normalFont(13), textColor: .blt.sixsixBlackColor(), numberOfLines: 1)
    }()

    private lazy var iconView: UIImageView = {
        UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "sparkles.rectangle.stack")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
    }()

    private lazy var cardView: UIView = {
        UIView.blt.initWithBackgroundColor(color: .white, cornerRadius: 10)
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd HH:mm"
        return formatter
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.addSubview(cardView)
        cardView.addSubview(iconView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(detailLabel)

        cardView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
        }
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
        }
    }

    func render(session: DoubaoChatSessionModel, roundCount: Int) {
        titleLabel.text = session.title.isEmpty ? "新会话" : session.title
        let time = Self.timeFormatter.string(from: Date(timeIntervalSince1970: session.createdAt))
        detailLabel.text = "\(roundCount) 轮对话 · \(time)"
    }
}
