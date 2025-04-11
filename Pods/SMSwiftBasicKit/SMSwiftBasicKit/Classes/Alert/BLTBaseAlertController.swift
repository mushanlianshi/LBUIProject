//
//  BLTBaseAlertController.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/10/25.
//

import UIKit

open class BLTBaseAlertController: UIViewController {
    
    var dismissBlock: (() -> Void)?
    
    public lazy var transitionAnimator = BLTAlertAnimator.init()
    
    public lazy var backgroundView: UIControl = {
        let view = UIControl.init(frame: UIScreen.main.bounds)
        view.backgroundColor = .blt.threeThreeBlackColor().withAlphaComponent(0.5)
        view.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        return view
    }()
    
    
    public lazy var containerView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    public lazy var titleLab: UILabel = {
        let label = UILabel.blt.initWithText(text: nil, font: .blt.mediumFont(17), textColor: .blt.threeThreeBlackColor())
        label.textAlignment = .center
        return label
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = transitionAnimator
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backgroundView)
        backgroundView.addSubview(containerView)
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundView.frame = view.bounds
    }
    
    
    
    @objc public func dismissAlert(){
        self.dismiss(animated: true) {
            self.dismissBlock?()
        }
    }
}
