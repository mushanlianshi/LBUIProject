//
//  ChatSessionListViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/3.
//

import UIKit
import SnapKit

/// 聊天会话历史列表（入口：ChatViewController 右上角「历史记录」）
/// 点击会话 → 进入该会话的消息列表继续聊；左滑删除（级联删消息）
class ChatSessionListViewController: UIViewController {

    private var sessions: [ChatSessionModel] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        tableView.separatorStyle = .none
        tableView.rowHeight = 72
        tableView.register(ChatSessionCell.self, forCellReuseIdentifier: NSStringFromClass(ChatSessionCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        navigationItem.title = "历史记录"
        setupSubview()
    }

    /// 从会话页返回时刷新（会话活跃时间/条数可能变化）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSessions()
    }

    private func setupSubview() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func reloadSessions() {
        sessions = ChatDAO.shared.listSessions()
        tableView.reloadData()
        debugPrint("LBLog 会话列表刷新，共 \(sessions.count) 个会话")
    }
}

// MARK: - UITableViewDataSource / Delegate
extension ChatSessionListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sessions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ChatSessionCell.self), for: indexPath) as! ChatSessionCell
        let session = sessions[indexPath.row]
        cell.render(session: session, messageCount: ChatDAO.shared.messageCount(sessionId: session.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /// 进入历史会话继续聊（消息在 ChatViewController.viewDidLoad 恢复）
        let vc = ChatViewController()
        vc.existingSession = sessions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    /// 左滑删除（外键级联删除该会话所有消息）
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "删除") { [weak self] _, indexPath in
            guard let self else { return }
            let session = self.sessions.remove(at: indexPath.row)
            ChatDAO.shared.deleteSession(session.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            debugPrint("LBLog 删除会话 \(session.id)")
        }
        return [deleteAction]
    }
}

// MARK: - Cell（BLTUIKit 约定创建控件）
private class ChatSessionCell: UITableViewCell {

    /// 会话标题：无标题（一次没聊就退）显示「新会话」占位
    private lazy var titleLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor(), numberOfLines: 1)
        return label
    }()

    /// 副标题：N 条对话 · 最后活跃时间
    private lazy var detailLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(13), textColor: .blt.sixsixBlackColor(), numberOfLines: 1)
        return label
    }()

    /// 会话图标
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "bubble.left.and.bubble.right")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
        return imageView
    }()

    private lazy var cardView: UIView = {
        let view = UIView.blt.initWithBackgroundColor(color: .white, cornerRadius: 10)
        return view
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

    func render(session: ChatSessionModel, messageCount: Int) {
        titleLabel.text = session.title.isEmpty ? "新会话" : session.title
        let time = Self.timeFormatter.string(from: Date(timeIntervalSince1970: session.createdAt))
        detailLabel.text = "\(messageCount) 条对话 · \(time)"
    }
}
