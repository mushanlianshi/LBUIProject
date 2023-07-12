//
//  LBRxSwiftSchedulersViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/9.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

///测试Schedulers的
class LBRxSwiftSchedulersViewController: UIViewController {

    lazy var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RxSwift Schedulers"
        view.backgroundColor = .white
        self.testSchedulers()
        self.testSchedulers2()
    }

    func testSchedulers()  {
        
        
        let ob = PublishSubject<String>.create { observer in
            print("LBLog 1111 \(Thread.current)")
            observer.onNext("123")
            return Disposables.create {}
        }
        
        
        ob.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).subscribe(on: MainScheduler.instance).subscribe { value in
            print("LBLog 1111 subscribe \(Thread.current)")
        }.disposed(by: disposeBag)
        
    }
    
    
    
    ///我们用 subscribeOn 来决定数据序列的构建函数在哪个 Scheduler 上运行  决定在子线程来准本数据
    ///我们用 observeOn 来决定在哪个 Scheduler 监听这个数据序列 在主线程监听序列
    func testSchedulers2() {
        let ob = Observable<String>.create { element in
            print("LBLog 2222 \(Thread.current)")
            element.onNext("123")
            return Disposables.create()
        }
        
        ob.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).subscribe { value in
            print("LBLog 2222 subscribe \(Thread.current)")
        }.disposed(by: disposeBag)

    }
}
