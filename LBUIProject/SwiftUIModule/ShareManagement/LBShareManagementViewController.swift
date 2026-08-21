//
//  LBShareManagementViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/21.
//

import UIKit
import SnapKit

// MARK: - 数据模型
class LBShareItem: NSObject {
    let deviceName: String
    let shareTime: String
    let shareTo: String
    /// true：分享中；false：已取消
    var isSharing: Bool

    init(deviceName: String, shareTime: String, shareTo: String, isSharing: Bool) {
        self.deviceName = deviceName
        self.shareTime = shareTime
        self.shareTo = shareTo
        self.isSharing = isSharing
        super.init()
    }
}

/// 分享管理页（UIKit 版）
/// 还原 lanhu 设计稿：https://lanhuapp.com/web/#/item/project/stage?tid=f1bbb63a-34bb-454a-bf44-3ac667b4cd7b&pid=dd61d1c1-a450-47ac-a8fb-c36df2f75c2d
/// 设计稿关键信息：背景 #F4F6F9 / 白色卡片圆角 12 / 图标 66x80 / 设备名 14 #333 / 时间·被分享人 12 #868686
/// 「分享中」浅蓝底 #F3FAFF 蓝字 #0E8AFD /「取消分享」浅橙底 #FFF5F3 橙字 #FD890E /「取消」蓝底白字 68x28
class LBShareManagementViewController: UIViewController {

    private var items: [LBShareItem] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 122
        tableView.showsVerticalScrollIndicator = false
        tableView.register(LBShareManagementCell.self, forCellReuseIdentifier: NSStringFromClass(LBShareManagementCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "分享管理"
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        setupItems()
        setupSubview()
    }

    private func setupItems() {
        items = [
            LBShareItem(deviceName: "客厅摄像头", shareTime: "分享时间：2026-08-18 10:20", shareTo: "被分享人：张阿姨", isSharing: true),
            LBShareItem(deviceName: "阳台摄像头", shareTime: "分享时间：2026-08-01 09:30", shareTo: "被分享人：李叔叔", isSharing: true),
            LBShareItem(deviceName: "门口摄像头", shareTime: "分享时间：2026-07-20 15:40", shareTo: "被分享人：王奶奶", isSharing: false),
        ]
    }

    private func setupSubview() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func cancelShare(item: LBShareItem) {
        item.isSharing = false
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource / Delegate
extension LBShareManagementViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LBShareManagementCell.self), for: indexPath) as! LBShareManagementCell
        let item = items[indexPath.row]
        cell.cancelBlock = { [weak self] in
            self?.cancelShare(item: item)
        }
        cell.render(item: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Cell
private class LBShareManagementCell: UITableViewCell {

    var cancelBlock: (() -> Void)?

    /// 白底卡片，圆角 12（BLT 快捷创建，一步搞定背景 + 圆角）
    private lazy var cardView: UIView = {
        let view = UIView.blt.initWithBackgroundColor(color: .white, cornerRadius: 12)
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(named: "share_camera"))
        return imageView
    }()

    private lazy var deviceNameLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(14), textColor: .blt.threeThreeBlackColor())
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(12), textColor: UIColor.blt.hexColor(0x868686))
        return label
    }()

    private lazy var shareToLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(12), textColor: UIColor.blt.hexColor(0x868686))
        return label
    }()

    /// 状态标签：分享中（浅蓝底蓝字）/ 取消分享（浅橙底橙字）
    /// 圆角用系统 layer（随宽度自适应），blt_showLayerCorner 的 mask 不随 size 变化
    private lazy var statusLabel: UILabel = {
        let label = UILabel.blt.initWithText(text: nil, font: .blt.normalFont(11), textColor: UIColor.blt.hexColor(0x0E8AFD), textAlignment: .center)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "取消", font: .blt.normalFont(12), color: .white, target: self, action: #selector(cancelButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
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
        cardView.addSubview(iconImageView)
        cardView.addSubview(deviceNameLabel)
        cardView.addSubview(timeLabel)
        cardView.addSubview(shareToLabel)
        cardView.addSubview(statusLabel)
        cardView.addSubview(cancelButton)

        cardView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(66)
            make.height.equalTo(80)
        }
        deviceNameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.top.equalToSuperview().offset(16)
        }
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(deviceNameLabel)
            make.top.equalTo(deviceNameLabel.snp.bottom).offset(5)
        }
        shareToLabel.snp.makeConstraints { make in
            make.left.equalTo(deviceNameLabel)
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
        statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(deviceNameLabel)
            make.width.greaterThanOrEqualTo(52)
            make.height.equalTo(22)
        }
        cancelButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.top.equalTo(statusLabel.snp.bottom).offset(8)
            make.width.equalTo(68)
            make.height.equalTo(28)
        }
    }

    func render(item: LBShareItem) {
        deviceNameLabel.text = item.deviceName
        timeLabel.text = item.shareTime
        shareToLabel.text = item.shareTo
        if item.isSharing {
            statusLabel.text = "分享中"
            statusLabel.textColor = UIColor.blt.hexColor(0x0E8AFD)
            statusLabel.backgroundColor = UIColor.blt.hexColor(0xF3FAFF)
            cancelButton.isHidden = false
        } else {
            statusLabel.text = "取消分享"
            statusLabel.textColor = UIColor.blt.hexColor(0xFD890E)
            statusLabel.backgroundColor = UIColor.blt.hexColor(0xFFF5F3)
            cancelButton.isHidden = true
        }
    }

    @objc private func cancelButtonTapped() {
        cancelBlock?()
    }
}
