//
//  BLTAlertAnimator.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/10/25.
//

import Foundation

/// 弹框的样式
public enum BLTAlertAnimatorStyle: Int{
    case fromCenter = 0 //从中间弹出
    case fromBottom = 1 //从底部弹出
}

open class BLTAlertAnimator: NSObject {
    
    public var animatorStyle: BLTAlertAnimatorStyle = .fromBottom
    
    public var animatorDuration: TimeInterval = 0.3
    
    public var animatorBackgroundColor: UIColor = .black.withAlphaComponent(0.3){
        didSet{
            maskView.backgroundColor = animatorBackgroundColor
        }
    }
    
    public lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = animatorBackgroundColor
        return view
    }()
    
    public init(_ style: BLTAlertAnimatorStyle = .fromBottom){
        super.init()
        animatorStyle = style
    }
}


extension BLTAlertAnimator: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning{
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.animatorDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        toVC.view.frame = transitionContext.containerView.frame
        self.maskView.frame = toVC.view.bounds
        
        let containerView = transitionContext.containerView
        UIApplication.shared.windows.first?.bringSubviewToFront(containerView)
        let duration = self.transitionDuration(using: transitionContext)
        
        func animatingPresented(){
            maskView.alpha = 0
            containerView.addSubview(maskView)
            containerView.addSubview(toVC.view)
            if self.animatorStyle == .fromCenter{
                toVC.view.transform = CGAffineTransform.init(scaleX: 1.15, y: 1.15)
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: .autoreverse) {
                    toVC.view.transform = CGAffineTransform.identity
                } completion: { result in
                    transitionContext.completeTransition(result)
                }

            }else if self.animatorStyle == .fromBottom{
                var toVCFrame = toVC.view.frame
                toVCFrame.origin.y = toVCFrame.height
                toVC.view.frame = toVCFrame
                
                UIView.animate(withDuration: duration) {
                    toVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                } completion: { result in
                    transitionContext.completeTransition(result)
                }

            }
        }

        func animatingDismissed(){
            if animatorStyle == .fromCenter{
                UIView.animate(withDuration: duration) {
                    self.maskView.alpha = 0
                    fromVC.view.alpha = 0
                } completion: { result in
                    transitionContext.completeTransition(result)
                }
            }else if animatorStyle == .fromBottom{
                UIView.animate(withDuration: duration) {
                    self.maskView.alpha = 0
                    fromVC.view.alpha = 0
                } completion: { result in
                    transitionContext.completeTransition(result)
                }

            }
        }
        
        if toVC.isBeingPresented{
            animatingPresented()
        }else{
            animatingDismissed()
        }
        
    }
    
    
}
