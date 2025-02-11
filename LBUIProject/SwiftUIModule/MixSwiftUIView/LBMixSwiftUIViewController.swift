//
//  LBMixSwiftUIViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import UIKit
import SwiftUI

struct LBTestSwiftUIModel {
    var imageUrl: String?
    var name = ""
    var desc = ""
}

class LBMixSwiftUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "内嵌swift view"
        view.backgroundColor = .white
        addSwiftUIView()
    }
    
    func addSwiftUIView() {
        var mixView = LBMixSwiftUIView()
        mixView.model = LBTestSwiftUIModel(imageUrl: "", name: "这次是title", desc: "玩恶化哦我和佛文化哦额佛我和佛我佛我饿回复我和佛我我饿会哦我好烦哦哦豁哇哦哦更好晚饭")
        let swiftVC = UIHostingController(rootView: mixView)
        view.addSubview(swiftVC.view)
        swiftVC.view.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
    }

}
