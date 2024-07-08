//
//  LBDrawRectController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/9/1.
//

import UIKit
import BLTSwiftUIKit

class LBDrawRectController2: UIViewController {
    var refreshBlock: BLTEmptyBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "LBDrawRectController2"
        view.backgroundColor = .white
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            [weak self] in
            self?.refreshBlock?()
        })
    }
    
}

class LBDrawRectController: UIViewController {
    
    lazy var drawView = LBTestDrawView()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "drawRect调用"
        view.backgroundColor = .white
        drawView.backgroundColor = .red.withAlphaComponent(0.4)
        view.addSubview(drawView)
        drawView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            [weak self] in
            self?.pushSecondVC()
        })
        
    }

    private func pushSecondVC(){
        let vc = LBDrawRectController2()
        vc.refreshBlock = {
            [weak self] in
            ///标记为刷新  等下一次绘制   当vc 返回到这个界面时   会触发drawRect  不是立马触发绘制
            self?.drawView.setNeedsDisplay()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}



class LBTestDrawView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("LBLog LBTestDrawView draw ----------")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        print("LBLog LBTestDrawView layoutSubviews ----------")
    }
}
