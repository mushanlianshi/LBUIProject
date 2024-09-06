//
//  LBTabbarController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/27.
//

import UIKit
import BLTUIKitProject
import Dollar
import BLTSwiftUIKit


struct LBTestStructProperty {
    var name = ""
}

extension LBTestStructProperty{
//    var testName = ""
    var testProperty: String{
        get{
            return ""
        }
        set{}
    }
}

public protocol LBTestNameSpaceProtocol {
    associatedtype CompatibleType
    var lb: CompatibleType { get }
}

public extension LBTestNameSpaceProtocol {
    var lb: Self {
        return self
    }
}

/// 不借助一个结构体  就要每个分类都实现下lb属性
extension LBTabbarController: LBTestNameSpaceProtocol{
    typealias ItemType = UIViewController
    
    var lb: UIViewController {
        return self
    }
}



enum LBTabbarAnimatingState {
    case up
    case down
}


class LBTabbarController: UITabBarController {
    
    private var animatingState: LBTabbarAnimatingState = .up
    var randomIndex = 1;
    
    var timer: DispatchSourceTimer?
    
    lazy var homeAnimatingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImageNamed("tabbar_rabbit")
        return imageView
    }()
    

    
    var lastSelectTabBarItem: UITabBarItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSubControllers()
        addAnimateImageView()
        startAnimating()
        var string = "巴乐兔业务员正在准备为您建租【金蝶测试小区6635室】，当前租金调整为500.00元/月（原价为1199.00元/月）,戳https://m.baletu.com/tui/fd/index.html?action_type=contract_order_confirm反馈是否同意该价格"
        print("LBLog string count \(string.count)")
//        self.view.addSubview(testView)
//        testView.frame = CGRect(x: 100, y: 200, width: 200, height: 100)
//        testView.lbWith()
        
        let queue = DispatchQueue.init(label: "concurrent", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent)
        queue.async {
            print("LBLog queue is ====== \(queue.qos) \(queue.qos.relativePriority)")
        }
        
        let serialQueue = DispatchQueue.init(label: "concurrent")
        serialQueue.async {
            print("LBLog queue is ====== \( serialQueue.qos) \(serialQueue.qos.relativePriority)")
        }
        testLineParams()
    }
    
    func testLineParams() {
        var mutableArray = [1,2,3]
        for _ in mutableArray {
            print(getValueObjAddress(obj: &mutableArray))
            mutableArray.removeLast()
        }
        print("LBLog file is \(#file), line is \(#line), function is \(#function), column is \(#column)")
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
            controller.tabBarItem.image = UIImageNamed(imageList[index])
            controller.tabBarItem.selectedImage = UIImageNamed(imageList[index] + "_selected")
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor : UIColor.black], for: .normal)
            controller.tabBarItem.setTitleTextAttributes([.foregroundColor : UIColor.blue], for: .selected)
            let naviController = LBBaseNavigationController.init(rootViewController: controller)
            list.append(naviController)
        }
        self.viewControllers = list
        print("LBlog different \(Dollar.difference([3, 2, 1, 4, 5], [5, 2, 10], inOrder: true) )")
        print("LBlog different \(Dollar.difference([3, 2, 1, 4, 5], [5, 2, 10], inOrder: false) )")
    }
    
    private func addAnimateImageView(){
        let imageSize = homeAnimatingImageView.image?.size ?? .zero
        let itemWidth = self.view.bounds.size.width / 3
        homeAnimatingImageView.frame = CGRect(x: (itemWidth - imageSize.width) / 2, y: (49.0 - imageSize.height) / 2, width: imageSize.width, height: imageSize.height)
        self.tabBar.addSubview(homeAnimatingImageView)
        self.tabBar.bringSubviewToFront(homeAnimatingImageView)
    }
    
    
    private func startAnimating(){
        
        func animate(){
            if randomIndex % 2 == 1{
                animateHomeImageView(state: .down)
            }else{
                animateHomeImageView(state: .up)
            }
            randomIndex += 1;
        }
        
        timer = DispatchSource.makeTimerSource( queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: .seconds(3))
        timer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                animate()
            }
        })
        timer?.resume()
        
    }
    
    
    override func tabBar(_ tabBar: UITabBar, willBeginCustomizing items: [UITabBarItem]) {
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didEndCustomizing items: [UITabBarItem], changed: Bool) {
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    

    private func animateHomeImageView(state: LBTabbarAnimatingState){
        
        if animatingState == state {
            return
        }
        
        let animation = CATransition()
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        animation.type = .push
        if state == .up{
            homeAnimatingImageView.image = UIImageNamed("tabbar_rocket")
            animation.subtype = .fromTop
            self.animatingState = .up
        }else{
            homeAnimatingImageView.image = UIImageNamed("tabbar_rabbit")
            animation.subtype = .fromBottom
            self.animatingState = .down
        }
        homeAnimatingImageView.layer.add(animation, forKey: nil)
    }
    
    
    
    /// 处理push支持子controller 横竖屏的
    override var shouldAutorotate: Bool{
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation{
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
}

