//
//  LBTestMayoNetworkController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/23.
//

import UIKit
import Moya

///Moya网络库使用
class LBTestMayoNetworkController: UIViewController {
    
    lazy var stackView = UIStackView.blt_stackView(withSpacing: 20, distribution: .fillEqually, alignment: .fill, axis: .vertical)!
    
    lazy var provider = MoyaProvider<LBUserInfoService>.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Mayo网络库"
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.top.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(160)
        }
        
        addButtonTitle(title: "退出登录", selector: #selector(logout))
        addButtonTitle(title: "登录", selector: #selector(login))
        addButtonTitle(title: "刷新信息", selector: #selector(refreshUserInfo))
    }

    func addButtonTitle(title:String, selector: Selector){
        let button = UIButton.blt.initWithTitle(title: title, font: .blt.normalFont(16), color: .blt.threeThreeBlackColor(), target: self, action: selector)
        button.backgroundColor = .blt.f6BackgroundColor()
        stackView.addArrangedSubview(button)
    }
    
    
    @objc private func logout(){
        provider.request(.logout) { result in
            let result = LBMoyaProviderResult.convertToBusinessResult(result: result)
            switch result{
                case .success(let res):
                print("LBLog request res is \(res) \(String(describing: res.businessResult))")
            case .failure(let error):
                print("LBLog error res is \(error)")
            }
        }
    }
    
    @objc private func login(){
        provider.request(.login(mobile: "17301600702", code: "111111")) { result in
            let result = LBMoyaProviderResult.convertToBusinessResult(result: result)
            switch result{
                case .success(let res):
                print("LBLog request res is \(res) \(String(describing: res.businessResult))")
            case .failure(let error):
                print("LBLog error res is \(error)")
            }
        }
    }
    
    @objc private func refreshUserInfo(){
        provider.request(.userInfo) { result in
            let result = LBMoyaProviderResult.convertToBusinessResult(result: result)
            switch result{
                case .success(let res):
                print("LBLog request res is \(res) \(String(describing: res.businessResult))")
            case .failure(let error):
                print("LBLog error res is \(error)")
            }
        }
    }
}
