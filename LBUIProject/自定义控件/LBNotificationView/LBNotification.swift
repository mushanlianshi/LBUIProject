//
//  LBNotification.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/15.
//

import Foundation
import UIKit

public protocol LBNotificationViewProtocol {
    var notification: LBNotification?{ get set}
}

open class LBNotification: NSObject{
    
    public typealias NotificationViewType = UIControl & LBNotificationViewProtocol
    
    weak var viewController: LBModelPresentViewController?
    
    private lazy var panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(panGesture:)))
    
    private var view: NotificationViewType?{
        didSet{
            view?.notification = self
            view?.addTarget(self, action: #selector(notificationViewDidClicked), for: .touchUpInside)
        }
    }
    
//    停留时间
    private var stayDuration = 3.0
//    最初的位置 用来判断是否可以往下移  手势结束时是否可以自动消失的
    private var originalViewFrame: CGRect = .zero
    
//    是否会自动隐藏
    public var autoHidden = true{
        didSet{
            stayDuration = 0.0
        }
    }
    
    
    public static func notificationWithViewClass(viewClass: NotificationViewType.Type, configBlock: ((_ view: NotificationViewType?) -> Void)?) -> LBNotification{
        let notification = LBNotification()
        notification.view = viewClass.init()
        configBlock?(notification.view)
        return notification
    }
    
    public override init() {
        super.init()
    }
    
    
//    开始展示
    public func show(){
        if self.viewController == nil && self.view == nil{
            assert(false, "view cannot be nil")
        }
        
        let vc = LBModelPresentViewController()
        vc.backgroundView = nil
        vc.contentView = self.view
        self.viewController = vc
        self.view?.addGestureRecognizer(self.panGesture)
//        vc.view.lb_hitTestBlock = {
//            [weak self] point, event, originView in
//
//            guard let oriView = originView else { return nil }
//            if oriView.isDescendant(of: self?.view ?? UIView()){
//                return originView
//            }
//            return nil
//        }
        
//        let size = self.view?.sizeThatFits(CGSize(width: vc.view.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        self.view?.snp.remakeConstraints({ make in
            make.bottom.equalTo(vc.view.snp_top)
        })
        
        
        UIApplication.shared.windows.last?.rootViewController?.present(vc, animated: false, completion: {
            UIView.animate(withDuration: 0.29, delay: 0, options: .curveEaseOut) {
                self.view?.snp.remakeConstraints({ make in
                    make.left.right.top.equalTo(UIEdgeInsets(top: 15, left: 15, bottom: 10, right: 15))
                })
                vc.view.layoutIfNeeded()
            } completion: { complete in
                self.originalViewFrame = self.view?.frame ?? .zero
            }
        })
        
        if self.stayDuration > 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + stayDuration) {
                [weak self] in
                self?.hidden()
            }
        }
        
    }
    
    public func hidden(){
        UIView.animate(withDuration: 0.29, delay: 0, options: .curveEaseOut) {
            self.view?.frame.origin.y = -(self.view?.bounds.height ?? 0)
        } completion: { complete in
            self.viewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @objc private func notificationViewDidClicked(){
        self.hidden()
    }
    
    @objc private func panGestureRecognized(panGesture: UIPanGestureRecognizer){
        guard let view = panGesture.view else { return }
        let state = panGesture.state
        switch state {
        case .began:
            print("began")
        case .changed:
            let translation = panGesture.translation(in: view.superview)
            if translation.x != 0 {
                break
            }
            if view.frame.minY >= self.originalViewFrame.minY && translation.y > 0{
                break
            }
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        case .ended:
            if self.originalViewFrame.minY - view.frame.minY >= 40{
                self.hidden()
            }else{
                self.view?.frame = self.originalViewFrame
            }
        default:
            print("not recognized ===========")
        }
        
        panGesture.setTranslation(.zero, in: view.superview)
    }
}


open class LBModelPresentViewController: UIViewController{
    public var backgroundView: UIView? = UIView()
    
    var willAppearBlock: (() -> Void)?
    
    open override func loadView() {
        super.loadView()
        self.view = LBModelPresentView()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
        self.view.backgroundColor = .clear
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var contentView: UIView?{
        didSet{
            guard let contentV = contentView else { return }
            view.addSubview(contentV)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        if let bView = backgroundView{
            self.view.addSubview(bView)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willAppearBlock?()
    }
    
    deinit{
        print("LBLog modelpresent controller dealloc=========")
    }
}





class LBModelPresentView: UIView{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        print("LBLog hittest view is \(view)")
        if view == self{
            return nil
        }
        return view
    }
}
