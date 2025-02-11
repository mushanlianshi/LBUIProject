//
//  LBAlphaAlertController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import Foundation

/// 隐藏系统alert的controler，在present的时候dismiss，导致系统获取当前controller的时候，在想present系统alert时，由于当前controller dismiss了，系统alert弹不出来
class LBDismissSystemAlertController: UIViewController{
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加一个透明背景视图
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.frame = view.bounds
        view.addSubview(backgroundView)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            // 当系统想要调用弹窗时直接 dismiss 掉
        dismiss(animated: false)
    }
    
}
