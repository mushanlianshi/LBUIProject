//
//  LBPageViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/2.
//

import Foundation

class LBBookPageViewController: UIViewController{
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let content: String
    let pageIndex: Int
    let totalPage: Int
    
    private lazy var textLab = UILabel.blt.initWithText(text: self.content, font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor(), textAlignment: .center, numberOfLines: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemYellow
        view.addSubview(self.textLab)
        self.textLab.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    init(index: Int, totalPage: Int, content: String){
        self.pageIndex = index
        self.totalPage = totalPage
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
}


class LBBookReaderViewController: UIViewController {

    // 模拟书籍数据
    private let bookPages = [
        "第一章：Swift 的起源\n\nSwift 是一种由 Apple 开发的强大且直观的编程语言...",
        "第二章：UIKit 基础\n\nUIKit 提供了构建 iOS 应用程序所需的关键对象...",
        "第三章：动画艺术\n\n核心动画 (Core Animation) 是 iOS 界面流畅的关键...",
        "第四章：高级翻页\n\nUIPageViewController 是实现仿真翻页的神器...",
        "终章：未来展望\n\n随着 SwiftUI 的普及，声明式 UI 正在改变世界..."
    ]

    private var pageViewController: UIPageViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
    }

    private func setupPageViewController() {
        // 关键设置：transitionStyle = .pageCurl (仿真翻页效果)
        // navigationOrientation = .horizontal (水平翻页)
        pageViewController = UIPageViewController(transitionStyle: .pageCurl,
                                                  navigationOrientation: .horizontal,
                                                  options: nil)

        pageViewController.dataSource = self
        pageViewController.delegate = self

        // 设置初始页面
//        if let firstPage = getViewController(at: 0) {
//            pageViewController.setViewControllers([firstPage], direction: .forward, animated: false, completion: nil)
//        }
        pageViewController.setViewControllers([dataSource.first!], direction: .forward, animated: false, completion: nil)

        // 将 PageVC 添加到当前 VC
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.frame = view.bounds
        pageViewController.didMove(toParent: self)

        // 解决仿真翻页背面颜色问题 (让背面也是纸张色，而不是默认的半透明或白色)
        // 注意：这是一个比较 Hack 的方法，更完美的做法是自定义背面的 Layer
        pageViewController.view.backgroundColor = UIColor(red: 248/255, green: 241/255, blue: 227/255, alpha: 1.0)
    }

    // 辅助方法：根据索引获取 VC
//    private func getViewController(at index: Int) -> LBBookPageViewController? {
//        guard index >= 0 && index < bookPages.count else { return nil }
//        return LBBookPageViewController(index: index, totalPage: bookPages.count, content: bookPages[index])
//    }
    
    lazy var dataSource: [LBBookPageViewController] = {
        var list = [LBBookPageViewController]()
        bookPages.enumerated().forEach { index, content in
            let subVC = LBBookPageViewController.init(index: index, totalPage: bookPages.count, content: content)
            list.append(subVC)
        }
        return list;
    }()
}

// MARK: - 3. DataSource 实现 (核心逻辑)
extension LBBookReaderViewController: UIPageViewControllerDataSource {
    
    // 获取"上一页"
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? LBBookPageViewController else { return nil }
        debugPrint("LBLOg viewControllerBefore viewController index \(currentVC.pageIndex)")
        let previousIndex = currentVC.pageIndex - 1
        if previousIndex < 0{
            return nil
        }
        return dataSource[previousIndex]
//        return getViewController(at: previousIndex)
    }

    // 获取"下一页"
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? LBBookPageViewController else { return nil }
        debugPrint("LBLOg viewControllerAfter viewController index \(currentVC.pageIndex)")
        guard let index = dataSource.firstIndex(of: currentVC) else {
            return nil
        }
        let nextIndex = currentVC.pageIndex + 1
        let next = index + 1
        guard next < dataSource.count else {
            return nil
        }
        return dataSource[nextIndex]
    }
}

// MARK: - 4. Delegate (可选，用于处理翻页后的状态)
extension LBBookReaderViewController: UIPageViewControllerDelegate {
    // 这里可以处理 spineLocation，例如横屏时显示双页
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        // 手机竖屏通常是单页 (.min)
        return .min
    }
}

