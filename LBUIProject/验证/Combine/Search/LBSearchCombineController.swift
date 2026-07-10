//
//  LBSearchCombineController.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/4/2.
//


import Foundation
import QMUIKit
import Combine

// throttle 用来限制频率， 防止按钮过快点击等。 在给定的时间段内触发第一个事件
// debounce 防止快速连续的事件过早触发，例如输入框的实时搜索， 在时间间隔内没有新的事件才触发最后一次

class LBSearchCombineController: UIViewController {

    private lazy var textField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "输入搜索的内容"
        tf.textColor = .blt.threeThreeBlackColor()
        tf.layer.borderColor = UIColor.red.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 22
        return tf
    }()
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.height.equalTo(44)
        }
        
        let mainThread = UIBarButtonItem.init(title: "主队列", style: .done, target: self, action: #selector(addTextChangeBind))
        let globalThread = UIBarButtonItem.init(title: "全局队列", style: .done, target: self, action: #selector(addTextChangeBindGlobal))
        self.navigationItem.rightBarButtonItems = [mainThread, globalThread]
        addTextChangeBind()
    }
    
    @objc func addTextChangeBind()  {
        textField.blt.publisherForTextChanged()
            .compactMap{ $0 }  // 过滤掉nil
            .throttle(for: .seconds(0.5), scheduler: RunLoop.main, latest: true) // 设置间隔0.5秒触发一次， 避免一直点
            .sink { text in
                print("LBLog text changed ----- \(text) \(Thread.current)")
            }.store(in: &cancellables)
//        textField.publisher(for: \.text)  // textField 的text不支持kvo所以检测不到text变化
//            .compactMap{ $0 }  // 过滤掉nil
//            .throttle(for: .seconds(0.5), scheduler: RunLoop.main, latest: true) // 设置间隔0.5秒触发一次， 避免一直点
//            .sink { text in
//                print("LBLog text changed ----- \(text) \(Thread.current)")
//            }.store(in: &cancellables)
    }
    
    
    @objc func addTextChangeBindGlobal()  {
        textField.blt.publisherForTextChanged()
            .compactMap{ $0 }  // 过滤掉nil
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)// 设置间隔0.5秒没有新元素触发一次， 避免一直点
            .sink { text in
                print("LBLog text changed global queue ----- \(text) \(Thread.current)")
            }.store(in: &cancellables)
//        textField.publisher(for: \.text)
//            .compactMap{ $0 }  // 过滤掉nil
//            .throttle(for: .seconds(0.5), scheduler: DispatchQueue.global(), latest: true) // 设置间隔0.5秒触发一次， 避免一直点
//            .sink { text in
//                print("LBLog text changed ----- \(text) \(Thread.current)")
//            }.store(in: &cancellables)
    }
    
}
