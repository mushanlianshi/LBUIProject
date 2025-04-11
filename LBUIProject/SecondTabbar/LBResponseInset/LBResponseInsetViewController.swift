//
//  LBResponseInsetViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/3/25.
//

import UIKit

class LBResponseInsetViewController: UIViewController {

    lazy var containerView1 = UIView.blt.initWithBackgroundColor(color: .yellow)
    lazy var button1: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "点击1", font: .blt.normalFont(16), color: .white, target: self, action: #selector(button1BtnClicked))
        button.backgroundColor = .blt.eeColor()
        button.qmui_outsideEdge = .init(top: 0, left: -30, bottom: 0, right: -30)
        return button
    }()
    
    lazy var containerView2 = UIView.blt.initWithBackgroundColor(color: .yellow)
    
    lazy var button2: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "点击2", font: .blt.normalFont(16), color: .white, target: self, action: #selector(button2BtnClicked))
        button.backgroundColor = .blt.eeColor()
        button.qmui_outsideEdge = .init(top: 0, left: -30, bottom: 0, right: -30)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [containerView1, containerView2].forEach(view.addSubview(_:))
        containerView1.addSubview(button1)
        containerView2.addSubview(button2)
        setConstraints()
        let item1 = UIBarButtonItem.init(customView: containerView1)
        let spacerItem = UIBarButtonItem.init(customView: UIView.init(frame: .init(x: 0, y: 0, width: 20, height: 0)))
        let item2 = UIBarButtonItem.init(customView: containerView2)
//        self.navigationItem.rightBarButtonItems = [item1, spacerItem, item2]
        self.navigationItem.rightBarButtonItems = [item1]
    }
    
    private func setConstraints(){
        containerView1.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
        }
        
        containerView2.snp.makeConstraints { make in
            make.top.equalTo(containerView1.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        button1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(44)
        }
        
        button2.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.height.equalTo(44)
        }
    }

    @objc func button1BtnClicked(){
        print("LBLog button1 clicked ----------")
    }

    @objc func button2BtnClicked(){
        print("LBLog button2 clicked ----------")
    }
}
