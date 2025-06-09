//
//  LBAwaitAsyncViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/21.
//

import UIKit

@MainActor
class MyIsolatedClass {
    nonisolated func nonIsolatedMethod() {
        // 没有隔离
    }

    nonisolated static let someConstantSTring = "线程安全"
}

class LBAwaitAsyncViewController: UIViewController {
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView.blt_imageView(with: UIImage(named: "convert_to_async"), mode: .scaleAspectFill)!
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Await Async关键字"
        
        ///用Task来包裹 消除必须使用Async修饰方法
        Task{
            await testAwait()
        }
        
        Task {
            do {
                print("LBLog task \(Thread.current)")
                let result = try await readFileContents(at: "/path/to/file.txt")
                print("文件内容：\(result)")
            } catch {
                print("读取失败：\(error)")
            }
        }
            
        self.view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualTo(300)
        }
    }
    
    
    func testAwait() async  {
        let value = await testAsync22()
        print("LBLog testAwait \(value) \(Thread.current)")
    }
    
    
    ///选中方法  Refactor -> Convert Function to Async  系统自动转换
    func testAsync22() async -> String {
        // withCheckedContinuation 不会主动切换线程，需要自己处理
        return await withCheckedContinuation { continuation in
            //主动切换到子线程中去
            DispatchQueue.global().async {
                print("LBLog withCheckedContinuation thread \(Thread.current)")
                sleep(2)
                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    continuation.resume(returning: "exec testAsync22 function complete ======   -------------")
                })
            }
//            imageView.image = nil
        }
    }
    
    func readFileContents(at path: String) async throws -> String {
//        Task.detached 不会继承当前的actor，
        return try await Task.detached(priority: .background) {
            print("LBLog readFileContents \(Thread.current)")
//            let tid = pthread_mach_thread_np(pthread_self())
            let url = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: url)
            return String(data: data, encoding: .utf8) ?? ""
        }.value
    }

}
