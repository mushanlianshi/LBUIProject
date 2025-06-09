//
//  LBCustomTabbarController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/5/12.
//

import Foundation

import UIKit

class TransparentTabBarController: UITabBarController, UITabBarControllerDelegate {

    fileprivate lazy var menuWidth: CGFloat = UIScreen.main.bounds.width
    fileprivate var menuView: UIView!
    fileprivate var isMenuVisible = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubControllers()
        delegate = self
        
        // 默认白色背景
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
        setupMenuView()
        setupEdgePanGesture()
    }
    
    // 监听 Tab 切换
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if selectedIndex == 2 {
            // 第3个 tab：透明背景
            makeTabBarTransparent()
        } else {
            // 其他 tab：白色背景
            restoreTabBarStyle()
        }
    }
    
    private func initSubControllers(){
        let titleList = ["首页", "控件", "三方库", "验证", "SwiftUI"]
        let imageList = ["", "third_sdk", "mine", "mine", "mine"]
        let controllerList:[UIViewController] = [LBHomeViewController(), LBSecondViewController(), LBThirdSDKController(), LBVerifyViewController(), LBSwiftUIHomeController()]
        var list = [UIViewController]()
        for (index, title) in titleList.enumerated() {
            let controller = controllerList[index]
            controller.title = title
            controller.tabBarItem.title = title
            controller.tabBarItem.image = UIImage(named: imageList[index])
            controller.tabBarItem.selectedImage = UIImage(named: imageList[index] + "_selected")
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .normal)
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .selected)
            let naviController = LBBaseNavigationController.init(rootViewController: controller)
            list.append(naviController)
        }
        self.viewControllers = list
    }

    func makeTabBarTransparent() {
        let appearance = tabBar.standardAppearance
        appearance.configureWithTransparentBackground()
        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    func restoreTabBarStyle() {
        let appearance = tabBar.standardAppearance
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance

        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    func createVC(title: String, color: UIColor) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = color
        vc.tabBarItem.title = title
        return vc
    }
}



extension TransparentTabBarController{
    private func setupMenuView() {
        menuView = UIView(frame: CGRect(x: -menuWidth, y: 0, width: menuWidth, height: UIScreen.main.bounds.height))
            menuView.backgroundColor = .systemPink
            let label = UILabel(frame: CGRect(x: 20, y: 100, width: 200, height: 40))
            label.text = "我是菜单"
            menuView.addSubview(label)

            view.addSubview(menuView)
        }

        private func setupEdgePanGesture() {
            let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            edgePan.edges = .left
            view.addGestureRecognizer(edgePan)
        }

        @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
            let translation = gesture.translation(in: view)
            let progress = min(max(translation.x / menuWidth, 0), 1)

            switch gesture.state {
            case .changed:
                if !isMenuVisible {
                    // 跟随手势滑出菜单
                    menuView.frame.origin.x = -menuWidth + (menuWidth * progress)
                }
            case .ended, .cancelled:
                if progress > 0.3 {
                    showMenu()
                } else {
                    hideMenu()
                }
            default:
                break
            }
        }

        private func showMenu() {
            UIView.animate(withDuration: 0.25) {
                self.menuView.frame.origin.x = 0
            }
            isMenuVisible = true
            addTapToDismissMenu()
        }

        private func hideMenu() {
            UIView.animate(withDuration: 0.25) {
                self.menuView.frame.origin.x = -self.menuWidth
            }
            isMenuVisible = false
        }

        private func addTapToDismissMenu() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
            view.addGestureRecognizer(tap)
            tap.name = "menuDismissTap"
        }

        @objc private func dismissMenu(_ gesture: UITapGestureRecognizer) {
            hideMenu()
            // 移除手势
            view.gestureRecognizers?.removeAll(where: { $0.name == "menuDismissTap" })
        }
}



class SideMenuViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // 添加一个关闭按钮
        let button = UIButton(type: .system)
        button.setTitle("关闭菜单", for: .normal)
        button.addTarget(self, action: #selector(closeMenu), for: .touchUpInside)
        button.center = view.center
        button.frame = CGRect(x: 100, y: 100, width: 120, height: 50)
        view.addSubview(button)
    }

    @objc func closeMenu() {
        dismiss(animated: true, completion: nil)
    }
}
