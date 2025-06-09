//
//  LBGesturePriorityViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/5/12.
//

import UIKit
import WebKit

/// 测试手势优先级
class LBGesturePriorityViewController: UIViewController {
    
    private lazy var gesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(gestureClicked(_:)))
        return tap
    }()
    
    private lazy var allBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "手势响应", font:.blt.mediumFont(15), color: .blt.threeThreeBlackColor(), target: self, action: #selector(responseAllClicked))
        button.setTitle("同时响应", for: .selected)
        return button
    }()
    
    lazy var webview = {
        let wkwebview = WKWebView()
        if let url = URL.init(string: "https://www.baidu.com") {
            let request = URLRequest(url: url)
            wkwebview.load(request)
        }
        wkwebview.isHidden = true
        return wkwebview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        let allItem = UIBarButtonItem.init(customView: allBtn)
        view.addGestureRecognizer(gesture)
        
        let centerBtn = UIButton.blt.initWithTitle(title: "center button click", font: .blt.mediumFont(18), color: .blt.threeThreeBlackColor(), target: self, action: #selector(centerBtnClicked))
        view.addSubview(centerBtn)
        
        let buttonGesture = UIPanGestureRecognizer(target: self, action: #selector(centerGestureClicked(_:)))
//        buttonGesture.cancelsTouchesInView = false
//        centerBtn.addGestureRecognizer(buttonGesture)
        centerBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let showWeb = UIBarButtonItem.init(title: "显示web", style: .plain, target: self, action: #selector(showWebBtnClicked))
        view.addSubview(webview)
        webview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.navigationItem.rightBarButtonItems = [allItem, showWeb]
    }
    

    @objc func gestureClicked(_ gesture: UITapGestureRecognizer){
        print("LBLog gesture is \(gesture)")
    }

    @objc func responseAllClicked(){
        allBtn.isSelected = !allBtn.isSelected
        if allBtn.isSelected {
            // 同时响应， 不取消touch事件
            gesture.cancelsTouchesInView = false
        }else{
            gesture.cancelsTouchesInView = true
        }
    }
    
    @objc func centerBtnClicked(){
        print("LBLog centerBtnClicked -------")
    }
    
    @objc func centerGestureClicked(_ pan: UIPanGestureRecognizer){
        print("LBLog centerGestureClicked -------")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("LBLog touchesEnded -------")
    }
    
    @objc func showWebBtnClicked(){
        webview.isHidden = !webview.isHidden
    }
    
}
