//
//  LBNavigationBarScrollChangeAnimator.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import UIKit
import BLTSwiftUIKit

//导航栏滑动渐变色的 controller
public protocol LBNavigationBarScrollDataSourcesProtocol: AnyObject{
    func backgroundImageOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIImage?
    func shadowImageOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIImage?
    func tintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?
    func titleViewTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?
    func barTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?
    
}

public extension LBNavigationBarScrollDataSourcesProtocol{
    func backgroundImageOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIImage?{
        return nil
    }
    func shadowImageOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIImage?{
        return nil
    }
    func tintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?{
        return nil
    }
    func titleViewTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?{
        return nil
    }
    func barTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor?{
        return nil
    }
}


public class LBNavigationBarScrollChangeAnimator: NSObject {
//    开始渐变的offsetY 默认0
    private var startAnimatorOffsetY: CGFloat = 50
//    参与渐变的高度   默认64 渐变色从0-1
    private var distanceJoinAnimation: CGFloat = 64
    
    private var reachZoreProgress = false
    private var reachOneProgress = false
//    weak var delegate: LBNavigationBarScrollDataSourcesProtocol?
    
    weak var scrollView: UIScrollView?{
        didSet{ 
            guard let scroll = scrollView else { return }
//            scroll.delegate = self
            
        }
    }
    
    var navigationBar: UINavigationBar?
    
    var dataSources: LBNavigationBarScrollDataSourcesProtocol?
    
    
    
}


extension LBNavigationBarScrollChangeAnimator: UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if navigationBar == nil{
            navigationBar = self.scrollView?.getCurrentVC()?.navigationController?.navigationBar
        }
        guard let naviBar = navigationBar else { return }
        
        let progress = self.progress()
        print("LBLog progress \(progress)")
//        已经达到0 就不在处理了
        if (progress <= 0 && self.reachZoreProgress){
            return
        }
        
        if (progress >= 1 && self.reachOneProgress){
            return
        }
        
        self.reachZoreProgress = progress <= 0
        self.reachOneProgress = progress >= 1
        guard let animatorDelegate = self.dataSources else { return }
        
        
        let backgroundImage = animatorDelegate.backgroundImageOfAnimator(animator: self, progress: progress)
//        naviBar.setBackgroundImage(backgroundImage, for: .default)
        
        let shadowImage = animatorDelegate.shadowImageOfAnimator(animator: self, progress: progress)
//        naviBar.shadowImage = shadowImage
        
        let tintColor = animatorDelegate.tintColorOfAnimator(animator: self, progress: progress)
//        naviBar.tintColor = tintColor
        
        let titleViewTintColor = animatorDelegate.titleViewTintColorOfAnimator(animator: self, progress: progress)
        
        let barTintColor = animatorDelegate.barTintColorOfAnimator(animator: self, progress: progress)
//        naviBar.barTintColor = barTintColor
        naviBar.refreshNaviBarTintColor(itemColor: tintColor!, titleColor: titleViewTintColor!, barTintColor: barTintColor, backgroundImage: backgroundImage, shadowImage: shadowImage)
    }
    
    
    public func progress() -> CGFloat{
        guard let scrollView = self.scrollView else { return 0 }
        let contentOffsetY = scrollView.contentOffset.y
        var startAnimationOffsetY: CGFloat = 0
        if #available(iOS 11.0, *) {
            startAnimationOffsetY = self.startAnimatorOffsetY - scrollView.adjustedContentInset.top
        }
        if contentOffsetY < startAnimationOffsetY {
            return 0
        }
        
        if contentOffsetY > startAnimationOffsetY + self.distanceJoinAnimation {
            return 1
        }
        let progress = (contentOffsetY - startAnimationOffsetY) / self.distanceJoinAnimation
        return progress
    }
}



extension UIView{
    func getCurrentVC() -> UIViewController? {
        var responser: UIResponder? = self
        while (responser != nil){
            if responser is UIViewController{
                return responser as? UIViewController
            }
            responser = responser?.next
        }
        return nil
    }
}
