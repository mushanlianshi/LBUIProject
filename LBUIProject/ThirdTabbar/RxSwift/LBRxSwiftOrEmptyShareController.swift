//
//  LBRxSwiftOrEmptyShareController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/4.
//

import UIKit
import RxSwift
import RxCocoa

class LBRxSwiftOrEmptyShareController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var changeNameObserver = PublishSubject<String?>.init()
    
    lazy var textView: UITextView = {
       let view = UITextView()
        view.backgroundColor = .gray.withAlphaComponent(0.5)
        view.textColor = .blue
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "OrEmpty And Share"
        view.backgroundColor = .white
        self.view.addSubview(self.textView)
        self.textView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(120)
        }
//        self.testOrEmpty()
//        self.testShare()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
//            self.textView.text = nil
//        })
        
        
        self.textView.rx.text.asObserver().onNext("123")
        self.textView.rx.text.asObserver().onNext("321")
        self.textView.rx.text.asObserver().onNext("1")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.testOrEmpty()
            self.testShare()
            self.testDrive()
        })
    }
    
    ///orEmpty过去掉optional的值
    func testOrEmpty() {
        self.textView.rx.text.orEmpty.subscribe { value in
//            print("LBLog value is \(value)")
        } onError: { error in
            print("LBLog error is \(error)")
        }.disposed(by: disposeBag)

        
        self.textView.rx.text.subscribe { value in
//            print("LBLog value is  22222 \(String(describing: value))")
        } onError: { error in
            print("LBLog error is 22222 \(error)")
        }.disposed(by: disposeBag)
        
    }
    
    
    ///共享附加价值 例如一个网络请求可监听序列，如果有两个订阅者，不是共享附加作用的序列，会导致发起两次网络请求，如果是共享附加作用，就不会再次发起请求，
    ///也可以使用share 来共享
    ///共享附加价值的可监听序列有： Drive Signal(Signal相对于Drive不会回放上个事件) ControlEvent（专门用来描述UI控件所产生的事件）
    ///一般情况下状态序列（文本一类的）我们会选用 Driver 这个类型，事件序列（点击事件一类的）我们会选用 Signal 这个类型。
    func testShare() {
        let ob = Observable<String>.create { observer in
            print("LBLog test share observer emit =======")
            observer.onNext("2222")
            return Disposables.create {}
        }.share(replay: 1)
            ///.share(replay: 1)  如果不是共享附加价值的序列   会出发两次LBLog test share observer emit =======  加了share就只出发一次了   就相当于共享附加价值序列了
        
        
        ob.subscribe { value in
            print("LBLog test share value is \(value)")
        }.disposed(by: disposeBag)
        
        ob.subscribe { value2 in
            print("LBLog test share value2 is \(value2)")
        }.disposed(by: disposeBag)
        
    }
    
    ///共享附加价值的序列
    func testDrive() {
        
        let ob = Observable<String>.create { observer in
            print("LBLog test drive emit =======")
            observer.onNext("2222")
            return Disposables.create {}
        }.asDriver(onErrorJustReturn: "")
            ///.share(replay: 1)  如果不是共享附加价值的序列   会出发两次LBLog test share observer emit =======  加了share就只出发一次了   就相当于共享附加价值序列了
        
        


        ob.drive { value in
            print("LBLog test drive 1 value is \(value)")
        }.disposed(by: disposeBag)

        ob.drive { value in
            print("LBLog test drive 2 value is \(value)")
        }.disposed(by: disposeBag)
        
        ob.drive(self.navigationItem.rx.title).disposed(by: disposeBag)
    }

}
