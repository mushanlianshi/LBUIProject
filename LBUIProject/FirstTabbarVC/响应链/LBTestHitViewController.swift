//
//  LBTestHitViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/2/1.
//

import UIKit

class LBTestHitViewController: UIViewController {

    
    ///点击在不是AsubView和AsubView2上   AView就是最佳响应者  输出LBLog AViewClicked =================
    lazy var AView: UIControl = {
        let view = UIControl()
        view.backgroundColor = .blue.withAlphaComponent(0.8)
        view.addTarget(self, action: #selector(AViewClicked), for: .touchUpInside)
        return view
    }()
    
    ///点击在AsubView上 最佳响应者就是AsubView  但是由于没有点击事件  所以没有输出
    lazy var AsubView: UIView = {
        let view = UIView()
        view.backgroundColor = .red.withAlphaComponent(0.8)
        return view
    }()
    
    ///点击在AsubView2上 最佳响应者就是AsubView2 会输出 LBLog ASubView2Clicked =================
    lazy var AsubView2: UIControl = {
        let view = UIControl()
        view.backgroundColor = .yellow.withAlphaComponent(0.8)
        view.addTarget(self, action: #selector(ASubView2Clicked), for: .touchUpInside)
        return view
    }()
    
    
    
    lazy var BView: UIControl = {
        let view = UIControl()
        view.backgroundColor = .yellow.withAlphaComponent(0.8)
        view.addTarget(self, action: #selector(BViewClicked), for: .touchUpInside)
        return view
    }()
    
    lazy var BsubView: UIView = {
        let view = UIView()
        view.backgroundColor = .red.withAlphaComponent(0.8)
        return view
    }()
    
    lazy var BsubView2: UIControl = {
        let view = UIControl()
        view.backgroundColor = .blue.withAlphaComponent(0.8)
        view.addTarget(self, action: #selector(BSubView2Clicked), for: .touchUpInside)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.view.addSubview(AView)
        self.view.addSubview(BView)
        AView.addSubview(AsubView)
        AView.addSubview(AsubView2)
        
        BView.addSubview(BsubView)
        BView.addSubview(BsubView2)
        
        AView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 200))
            make.top.equalTo(120)
            make.centerX.equalToSuperview()
        }
        
        AsubView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        AsubView2.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        BView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 200, height: 200))
            make.top.equalTo(AView.snp_bottom).offset(60)
            make.centerX.equalToSuperview()
        }
        
        BsubView.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        BsubView2.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
    }
    

    @objc private func AViewClicked(){
        print("LBLog AViewClicked =================")
    }
    
    @objc private func ASubView2Clicked(){
        print("LBLog ASubView2Clicked =================")
    }
    
    @objc private func BViewClicked(){
        print("LBLog BViewClicked =================")
    }
    
    @objc private func BSubView2Clicked(){
        print("LBLog BSubView2Clicked =================")
    }

}
