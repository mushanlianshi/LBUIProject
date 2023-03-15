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
    }
    
    ///1.可观察序列
    private func testObservable(){
        
        let observableOne: Observable<String> = Observable.create { (observer) -> Disposable in
            let list = [true, false]
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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
        
        
        
       
        
        observableOne.subscribe { result in
            print("LBLog result is \(result)")
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

























