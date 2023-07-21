//
//  LBAwaitAsyncViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/21.
//

import UIKit

class LBAwaitAsyncViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView.blt_imageView(with: UIImage(named: "convert_to_async"), mode: .scaleAspectFill)!
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Await Async关键字"
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualTo(300)
        }
        ///用Task来包裹 消除必须使用Async修饰方法
        Task{
            await testAwait()
        }
    }
    
    
    func testAwait() async  {
        let value = await testAsync22()
        print("LBLog testAwait \(value)")
    }
    
    
    ///选中方法  Refactor -> Convert Function to Async  系统自动转换
    func testAsync22() async -> String {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                continuation.resume(returning: "exec testAsync22 function complete ======   -------------")
            })
        }
    }

}
