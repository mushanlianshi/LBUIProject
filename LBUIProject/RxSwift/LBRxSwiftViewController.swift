//
//  LBRxSwiftViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/1/28.
//

import UIKit
import RxSwift
import RxCocoa

///联系RxSwift
class LBRxSwiftViewController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var button: UIButton = {
        let b = UIButton()
        b.backgroundColor = .blue
        b.frame = CGRect(x: 100, y: 200, width: 70, height: 70)
        return b
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(button)
        testObservable()
        testObservableAndObserver()
        let ob = Observable<String>.create { ob in
            print("LBLog ob ========")
            ob.onNext("")
            return Disposables.create {
            }
        }.share(replay: 1)
        let t = self.navigationItem.rx.title
        let tt = UITextView().rx.text
        
        let o = ob.bind(to: tt).disposed(by: disposeBag)
        let oo = ob.bind(to: t).disposed(by: disposeBag)
    }
    
    ///1.可观察序列
    private func testObservable(){
        
        let observableOne: Observable<String> = Observable.create { (observer) -> Disposable in
            ///这个block执行的次数   跟订阅的次数一致
            let list = [true, false]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                print("LBLog async execute ===========")
                if (list.shuffled().first ?? true)  == true{
                    observer.onNext("first element")
                    observer.onCompleted()
                }else{
                    let err = NSError.init(domain: "error domain", code: -999, userInfo: nil)
                    observer.onError(err)
                }
            }
            
            return Disposables.create()
        }
        
        
        
//       订阅几次 订阅block就会执行几次
        observableOne.subscribe { event in
            print("LBLog event subscribe is 1111 \(String(describing: event.element))")
        }.disposed(by: disposeBag)
        
        
        observableOne.subscribe { event in
            print("LBLog event subscribe is 2222 \(String(describing: event.element))")
        }.disposed(by: disposeBag)
        
        observableOne.subscribe { result in
            print("LBLog result is 3333 \(result)")
        } onError: { error in
            print("LBlog error is \(error)")
        } onCompleted: {
            print("LBlog observable is complete")
        } onDisposed: {
            
        }.disposed(by: disposeBag)

    }
    
    ///观察者
    private func testObserver(){
        let observable = Observable<Bool>.create({ observer -> Disposable in
            observer.onNext(true)
            return Disposables.create()
        })
        
        let text: Single<Bool> = Single.create { single in
            single(.success(false))
            return Disposables.create()
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            let isHidd = self.button.rx.isHidden
            observable.bind(to: self.button.rx.isHidden).disposed(by: self.disposeBag)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                text.asObservable().bind(to: self.button.rx.isHidden).disposed(by: self.disposeBag)
            }
        }
        
        
        observable.subscribe { res in
            
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }

        
    }
    
    private func testObservableAndObserver(){
        print("LBLog testObservableAndObserver -----------------")
        let observer: PublishSubject<Bool> = PublishSubject<Bool>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            observer.onNext(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                observer.onNext(false)
            }
        }
        let tt = button.rx.isHidden;
        
        observer.bind(to: button.rx.isHidden).disposed(by: disposeBag)
        
        observer.subscribe { result in
            
        } onError: { error in
            
        } onCompleted: {
            
        } onDisposed: {
            
        }

    }

}

























