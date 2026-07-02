//
//  LBAIProductAdViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/6/12.
//

import UIKit
import SnapKit

/// AI产品全屏广告页 - 倒计时、跳过、查看广告
@objcMembers
class LBAIProductAdViewController: UIViewController {

    // MARK: - UI Elements
    /// 整体背景渐变
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.32, green: 0.79, blue: 0.77, alpha: 1.0).cgColor,
            UIColor(red: 0.32, green: 0.79, blue: 0.77, alpha: 1.0).cgColor,
            UIColor(red: 0.60, green: 0.84, blue: 0.83, alpha: 1.0).cgColor,
            UIColor(red: 0.32, green: 0.79, blue: 0.77, alpha: 1.0).cgColor,
            UIColor(red: 0.23, green: 0.53, blue: 0.55, alpha: 1.0).cgColor,
            UIColor(red: 0.97, green: 0.98, blue: 0.98, alpha: 1.0).cgColor,
            UIColor.white.cgColor,
        ]
        layer.locations = [0.0, 0.45, 0.55, 0.70, 0.82, 0.88, 1.0]
        return layer
    }()

    /// 右上角倒计时跳过按钮（pill样式）
    private lazy var countdownSkipButton: UIButton = {
        let button = UIButton.blt_button(withTitle: "", font: .systemFont(ofSize: 13), titleColor: .white, target: self, selector: #selector(skipButtonTapped))!
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.blt_layerCornerRaduis = 14
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        return button
    }()

    /// 主标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel.blt_label(withTitle: "AI 智能助手", font: .boldSystemFont(ofSize: 28), textColor: .white)!
        label.textAlignment = .center
        return label
    }()

    /// 副标题/描述
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel.blt_label(withTitle: "让你的工作效率提升 10 倍", font: .systemFont(ofSize: 16), textColor: UIColor.white.withAlphaComponent(0.85))!
        label.textAlignment = .center
        return label
    }()

    /// 中间产品插画
    private lazy var illustrationImageView: UIImageView = {
        let view = UIImageView.blt_imageView(with: .scaleAspectFit)!
        view.image = UIImage(named: "ai_product_illustration")
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.blt_layerCornerRaduis = 20
        return view
    }()

    // MARK: - 底部白色区域
    /// 金色"查看廣告" 文字（可点击）
    private lazy var viewAdLabel: UILabel = {
        let label = UILabel.blt_label(withTitle: "查看廣告", font: .boldSystemFont(ofSize: 18), textColor: UIColor(red: 0.85, green: 0.60, blue: 0.20, alpha: 1.0))!
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()

    /// 提示文字："查看後即可跳過廣告"
    private lazy var hintLabel: UILabel = {
        let label = UILabel.blt_label(withTitle: "查看後即可跳過廣告", font: .systemFont(ofSize: 13), textColor: UIColor(white: 0.45, alpha: 1.0))!
        label.textAlignment = .center
        return label
    }()

    /// 右侧红色装饰元素
    private lazy var redDecorationView: UIImageView = {
        let view = UIImageView.blt_imageView(with: .scaleAspectFit)!
        view.backgroundColor = UIColor(red: 0.87, green: 0.22, blue: 0.28, alpha: 0.12)
        view.blt_layerCornerRaduis = 40
        return view
    }()

    /// 右侧小红色装饰
    private lazy var smallRedDecoration: UIView = {
        let view = UIView.blt_view(withBackgroundColor: UIColor(red: 0.87, green: 0.22, blue: 0.28, alpha: 0.06))!
        view.blt_layerCornerRaduis = 22
        return view
    }()

    /// 金色下划线（装饰）
    private lazy var goldUnderlineView: UIView = {
        let view = UIView.blt_view(withBackgroundColor: UIColor(red: 0.85, green: 0.60, blue: 0.20, alpha: 0.3))!
        view.blt_layerCornerRaduis = 1
        return view
    }()

    // MARK: - Data
    private var countdownSeconds = 5
    private var countdownTimer: Timer?
    private var isAdViewed = false

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startCountdown()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - Setup
    private func setupUI() {
        view.layer.insertSublayer(gradientLayer, at: 0)

        view.addSubview(countdownSkipButton)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(illustrationImageView)
        view.addSubview(viewAdLabel)
        view.addSubview(goldUnderlineView)
        view.addSubview(hintLabel)
        view.addSubview(redDecorationView)
        view.addSubview(smallRedDecoration)

        setupConstraints()
        setupGestures()
        updateCountdownDisplay()
    }

    private func setupConstraints() {
        /// 右上角倒计时跳过按钮
        countdownSkipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(28)
        }

        /// 标题
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(countdownSkipButton.snp.bottom).offset(80)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(40)
            make.right.lessThanOrEqualTo(-40)
        }

        /// 副标题
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.left.greaterThanOrEqualTo(40)
            make.right.lessThanOrEqualTo(-40)
        }

        /// 中间插画
        illustrationImageView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(240)
        }

        /// 金色"查看廣告"文字
        viewAdLabel.snp.makeConstraints { make in
            make.bottom.equalTo(hintLabel.snp.top).offset(-30)
            make.centerX.equalToSuperview()
        }

        /// 金色下划线
        goldUnderlineView.snp.makeConstraints { make in
            make.top.equalTo(viewAdLabel.snp.bottom).offset(4)
            make.centerX.equalTo(viewAdLabel)
            make.width.equalTo(viewAdLabel.snp.width).offset(8)
            make.height.equalTo(2)
        }

        /// 提示文字
        hintLabel.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-60)
            make.centerX.equalToSuperview().offset(-30)
        }

        /// 右侧红色装饰
        redDecorationView.snp.makeConstraints { make in
            make.centerY.equalTo(hintLabel)
            make.left.equalTo(hintLabel.snp.right).offset(30)
            make.width.height.equalTo(80)
        }

        smallRedDecoration.snp.makeConstraints { make in
            make.centerY.equalTo(redDecorationView)
            make.left.equalTo(redDecorationView.snp.right).offset(8)
            make.width.height.equalTo(44)
        }
    }

    private func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewAdLabelTapped))
        viewAdLabel.addGestureRecognizer(tap)
    }

    // MARK: - Countdown
    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.countdownSeconds > 0 {
                self.countdownSeconds -= 1
                self.updateCountdownDisplay()
            } else {
                self.countdownTimer?.invalidate()
                self.countdownTimer = nil
                self.enableSkip()
            }
        }
    }

    private func updateCountdownDisplay() {
        if countdownSeconds > 0 {
            countdownSkipButton.setTitle("\(countdownSeconds)s 跳过", for: .normal)
            countdownSkipButton.isUserInteractionEnabled = false
            countdownSkipButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else {
            enableSkip()
        }
    }

    private func enableSkip() {
        countdownSkipButton.isUserInteractionEnabled = true
        countdownSkipButton.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        countdownSkipButton.setTitle("跳过", for: .normal)
    }

    // MARK: - Actions
    @objc private func skipButtonTapped() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        dismiss(animated: true)
    }

    @objc private func viewAdLabelTapped() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        isAdViewed = true

        let alert = UIAlertController(
            title: "查看广告",
            message: "即将跳转至广告详情页，观看完成后可关闭此页面",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "查看完整广告", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self?.dismiss(animated: true)
            }
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { [weak self] _ in
            self?.startCountdown()
        }))
        present(alert, animated: true)
    }
}
