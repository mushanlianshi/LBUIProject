//
//  LBRxSwiftOperatorsViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/9.
//

import UIKit
import RxSwift

///操作符
class LBRxSwiftOperatorsViewController: UIViewController {
    
    var tapConvertObservable: Observable<String>?
    
    lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "操作符"
        view.backgroundColor = .white
        self.testConcat()
        self.testNotUseConcat()
        self.testFlatMap()
        self.testFlatLatestMap()
        self.testTakeOperator()
        self.testObserverConvert()
        self.testThrottleAndDebounce()
    }
    
    
    ///一个接一个发出元素 当上一个 Observable 元素发送完毕后，下一个 Observable 才能开始发出元素
    ///secondOb 的元素会等firstOb元素发出后  发出onCompleted()事件后才会发出
    func testConcat()  {
        let firstOb = Observable<String>.create { ob in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                sleep(2)
                ob.onNext("1111")
                ob.onCompleted()
            })
            return Disposables.create()
        }
        
        let secondOb = Observable<String>.create { ob in
            ob.onNext("22222")
            return Disposables.create()
        }
        
        firstOb.concat(secondOb).subscribe { value in
            print("LBLog value is \(value) \(Thread.current)")
        }.disposed(by: disposeBag)

        firstOb.concat(secondOb).observe(on: MainScheduler.instance).subscribe{
            value in
            print("LBLog mainScheduler value is \(value) \(Thread.current)")
        }.disposed(by: disposeBag)
    }
    
    ///一个接一个发出元素 当上一个 Observable 元素发送完毕后，下一个 Observable 才能开始发出元素
    func testNotUseConcat()  {
        print("---------------------------------------------------------")
        let firstOb = Observable<String>.create { ob in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: {
                sleep(2)
                ob.onNext("1111")
            })
            return Disposables.create()
        }
        
        let secondOb = Observable<String>.create { ob in
            ob.onNext("22222")
            return Disposables.create()
        }
        
        firstOb.subscribe{
            value in
            print("LBLog subscribe value is --------- \(value) \(Thread.current)")
        }.disposed(by: disposeBag)
        
        secondOb.subscribe{
            value in
            print("LBLog secondOb value is --------- \(value) \(Thread.current)")
        }.disposed(by: disposeBag)
    }
    
    
    
    ///将 Observable 的元素转换成其他的 Observable，然后将这些 Observables 合并后都发出来  所以first的和second发出的元素都能收到
    func testFlatMap(){
        print(" --------------------------------------------- ")
        let first = BehaviorSubject(value: "first 1")
        let second = BehaviorSubject(value: "second 1")
        let subject = BehaviorSubject(value: first)
        
        subject.flatMap { seondBehavior in
            return seondBehavior
        }.subscribe { value in
            print("LBLog testFlatMap value is \(value)")
        }.disposed(by: disposeBag)

        first.onNext("first 2")
        second.onNext("second 2")
        first.onNext("first 3")
        second.onNext("second 3")
        
        subject.onNext(second)
        first.onNext("first 4")
        second.onNext("second 4")
        first.onNext("first 5")
        second.onNext("second 5")
    }

    ///将 Observable 的元素转换成其他的 Observable，然后取这些 Observables 中最新的一个 first后面被second替换掉了 后面就只能收到second的 收不到first的了
    func testFlatLatestMap(){
        print(" --------------------------------------------- ")
        let first = BehaviorSubject(value: "first 1")
        let second = BehaviorSubject(value: "second 1")
        let subject = BehaviorSubject(value: first)
        subject.flatMapLatest { seondBehavior in
            return seondBehavior
        }.subscribe { value in
            print("LBLog flatMapLatest value is \(value)")
        }.disposed(by: disposeBag)

        first.onNext("first 2")
        second.onNext("second 2")
        first.onNext("first 3")
        second.onNext("second 3")
        
        subject.onNext(second)
        first.onNext("first 4")
        second.onNext("second 4")
        first.onNext("first 5")
        second.onNext("second 5")
        
    }

    
    ///take操作符  通过 take 操作符你可以只发出头 n 个元素。并且忽略掉后面的元素，直接结束序列。
    func testTakeOperator(){
        print(" --------------------------------------------------------- ")
        let ob1 = Observable<String>.create { observer in
            observer.onNext("1111")
            observer.onNext("2222")
            observer.onNext("3333")
            observer.onNext("4444")
            return Disposables.create()
        }
    

        
        ob1.take(2).subscribe(onNext: { value in
            print("LBLog testTakeOperator 111 value \(value)")
        }).disposed(by: disposeBag)

        
        let ob2 = BehaviorSubject<String>(value: "1111")
        ob2.onNext("2222")
        ob2.onNext("3333")
        ob2.onNext("4444")
        
        ob2.take(2).subscribe(onNext: { value in
            print("LBLog testTakeOperator 222 value \(value)")
        }).disposed(by: disposeBag)
        ob2.onNext("5555")
        ob2.onNext("6666")
        
    }
    
    
    ///把按钮的点击事件转换成一个string的observable序列
    func testObserverConvert() {
        let button = UIButton.blt.initWithTitle(title: "转换序列", font: .blt.normalFont(16), color: .blt.threeThreeBlackColor())
        button.frame = CGRect(x: 30, y: 100, width: 100, height: 50)
        button.backgroundColor = .blt.f6BackgroundColor()
        view.addSubview(button)
        
        button.rx.tap.flatMapLatest { _ in
            return Observable<String>.create { ob -> Disposable in
                ob.onNext("转换序列了")
                return Disposables.create()
            }
        }.bind(to: self.navigationItem.rx.title).disposed(by: disposeBag)
        
        self.tapConvertObservable = button.rx.tap.flatMapLatest { _ in
            return Observable<String>.create { ob -> Disposable in
                ob.onNext("123")
                return Disposables.create()
            }
        }
        
        self.tapConvertObservable?.subscribe(onNext: { value in
            print("LBLog tapConvertObservable value \(value)")
        }).disposed(by: disposeBag)
        
    }
    
    
    ///throttle 节流 (TextField一直输入时, 每 2 秒触发一次)
    ///debounce 防抖 (TextField一直输入时, 忽略 2 秒内的响应, 停止输入 2 秒后响应一次)
    func testThrottleAndDebounce() {
//        let tt = Observable<String>.create { ob in
//            ob.onNext("123")
//            return Disposables.create()
//        }
//        tt.throttle(<#T##dueTime: RxTimeInterval##RxTimeInterval#>, scheduler: <#T##SchedulerType#>)
//        tt.debounce(<#T##dueTime: RxTimeInterval##RxTimeInterval#>, scheduler: <#T##SchedulerType#>)
        let tf = UITextField()
        tf.backgroundColor = .blt.f6BackgroundColor()
        tf.textColor = .blt.threeThreeBlackColor()
        view.addSubview(tf)
        tf.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.height.equalTo(50)
        }
        
        ///每2秒触发一次
        tf.rx.text.throttle(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext:{
            value in
            print("LBLog throttle is \(value)")
        }).disposed(by: disposeBag)

        
        ///忽略2秒内的变化  停止输入后2秒 触发
        tf.rx.text.debounce(RxTimeInterval.seconds(2), scheduler: MainScheduler.instance).subscribe(onNext:{
            value in
            print("LBLog debounce is \(value)")
        }).disposed(by: disposeBag)
    }
}
