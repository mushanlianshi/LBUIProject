//
//  LBBluetoothListHostingController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/25.
//

import UIKit
import SwiftUI
import SnapKit

// MARK: - 专用宿主控制器（UIKit 导航栏零延迟方案） 解决导航栏标题、按钮在swiftui中展示慢的
/// SwiftUI 的 .navigationBarTitle/.navigationBarItems 要等首次渲染后才写入
/// navigationItem，push 转场先走、内容后到，标题/按钮慢半拍。
/// 这里在 viewDidLoad 直接设置 UIKit 导航栏——push 转场开始时标题和按钮就已就位，
/// 与纯 UIKit 页面（LBBluetoothListViewController）完全一致。
/// 注意：必须用普通 UIViewController 包 UIHostingController（child VC 模式，
/// 对齐项目 LBSwiftUIRefreshListController 的写法），不能继承 UIHostingController——
/// 入口经 UIViewController.Type 元类型 init() 实例化时走 ObjC -init 派发，
/// 而 UIHostingController 的 -init 是 NS_UNAVAILABLE（运行时不可用桩，直接 EXC_BREAKPOINT）。
/// 按钮与 SwiftUI 行实现经 LBBluetoothListViewModel 共享状态联动。
class LBBluetoothListHostingController: UIViewController {

    private let viewModel = LBBluetoothListViewModel()

    /// 右上角切换按钮：选中蓝底白字高亮，未选中蓝字描边（BLT 约定创建，样式对齐 UIKit 版 swiftUICell 按钮）
    private lazy var kitCellButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "UIKitCell", font: .blt.mediumFont(13), color: UIColor.blt.hexColor(0x0E8AFD), target: self, action: #selector(kitCellButtonTapped))
        button.frame = CGRect(x: 0, y: 0, width: 88, height: 30)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blt.hexColor(0x0E8AFD).cgColor
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        /// push 转场开始前导航栏内容就已就位，零延迟
        navigationItem.title = "蓝牙列表"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: kitCellButton)
        setupListView()
    }

    private func setupListView() {
        let hostController = UIHostingController(rootView: LBBluetoothListView(viewModel: viewModel))
        hostController.view.backgroundColor = .clear
        addChild(hostController)
        view.addSubview(hostController.view)
        hostController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hostController.didMove(toParent: self)
    }

    /// 点击切换：改共享状态（SwiftUI 行实现自动刷新）+ 刷新按钮高亮
    @objc private func kitCellButtonTapped() {
        viewModel.useUIKitCell.toggle()
        refreshKitCellButton()
    }

    private func refreshKitCellButton() {
        if viewModel.useUIKitCell {
            kitCellButton.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
            kitCellButton.setTitleColor(.white, for: .normal)
        } else {
            kitCellButton.backgroundColor = .clear
            kitCellButton.setTitleColor(UIColor.blt.hexColor(0x0E8AFD), for: .normal)
        }
    }
}
