//
//  LBNavigationBarScrollHiddenAnimator.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

import Foundation
import UIKit

//滚动 隐藏naviBard动画
public class LBNavigationBarScrollHiddenAnimator: NSObject{
    @objc public weak var navigationBar: UINavigationBar?
    @objc public weak var scrollView: UIScrollView?
//    默认多少才开始执行动画
    @objc public var offsetYToStartAnimation: CGFloat = 44;
    
    private var hasScrollHiddenNavibarAnimation = false
    private var hasScrollShowNavibarAnimation = false
    
    @objc var animationBlock: ((_ animator: LBNavigationBarScrollHiddenAnimator, _ hiddenNaviBar: Bool) -> Void)?
    
    @objc public func scrollViewDidScroll(scrollView: UIScrollView){
        if self.scrollView == nil{
            self.scrollView = scrollView
        }
        
        var naviBar = navigationBar
        if naviBar == nil{
            naviBar = self.scrollView?.getCurrentVC()?.navigationController?.navigationBar
        }
        
        if self.offsetYReach(){
            if hasScrollHiddenNavibarAnimation == false{
                self.animationBlock?(self, true)
                self.hasScrollHiddenNavibarAnimation = true
                self.hasScrollShowNavibarAnimation = false
            }
        }else{
            if hasScrollShowNavibarAnimation == false{
                self.animationBlock?(self, false)
                self.hasScrollShowNavibarAnimation = true
                self.hasScrollHiddenNavibarAnimation = false
            }
        }
        

        
    }
    
    public func offsetYReach() -> Bool{
        guard let scrollV = scrollView else { return false }
        return scrollV.contentOffset.y > self.offsetYToStartAnimation
    }
}


