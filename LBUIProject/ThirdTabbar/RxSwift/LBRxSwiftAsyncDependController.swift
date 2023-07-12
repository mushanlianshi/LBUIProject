//
//  LBRxSwiftAsyncDependController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/4.
//

import UIKit
import RxSwift


enum LBRequestError: Int{
    case token = 222
    case userInfo = 333
}

struct LBUserInfo {
    var name = ""
    var age = 0
}

enum LBAPIManager {
    static func requestToken() -> Observable<String>{
        let ob = Observable<String>.create { observer -> Disposable in
            let result: Bool = [true, false].shuffled().first!
            if false{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    print("LBLog emit get name success")
                    observer.onNext("get name success")
                })
            }else{
                let err = NSError.init(domain: "get name failed", code: LBRequestError.token.rawValue, userInfo: nil)
                observer.onError(err)
            }
            
            return Disposables.create {}
        }
        return ob
    }
    
    static func requestUserInfo(_ token: String) -> Observable<LBUserInfo>{
        let ob = Observable<LBUserInfo>.create { observer -> Disposable in
            let result: Bool = [true, false].shuffled().first!
            if true{
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    let userInfo = LBUserInfo.init(name: "liu bin", age: 22)
                    print("LBLog emit get userinfo success")
                    observer.onNext(userInfo)
                })
            }else{
                let err = NSError.init(domain: "get userInfo failed", code: LBRequestError.userInfo.rawValue, userInfo: nil)
                observer.onError(err)
            }
            
            return Disposables.create {}
        }
        return ob
    }
}

//异步任务依赖的的
class LBRxSwiftAsyncDependController: UIViewController {
    
    lazy var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationItem.title = "测试异步依赖"
        self.testAsyncDepend()
        self.testMutiAsyncTask()
    }
    
    
    
    
    ///测试添加依赖的  B任务依赖A任务的结果
    func testAsyncDepend(){
        LBAPIManager.requestToken().flatMapLatest(LBAPIManager.requestUserInfo).subscribe { userInfo in
            print("LBLog userinfo is \(userInfo.name)")
        } onError: { error in
            print("LBLog error is \(error.localizedDescription)")
        } onCompleted: {
            print("LBLog onCompleted is")
        }.disposed(by: disposeBag)
        
        
        
//        LBAPIManager.requestToken().flatMapLatest { token -> Observable<LBUserInfo> in
//            return LBAPIManager.requestUserInfo(token)
//        }.subscribe { userInfo in
//            print("LBLog userinfo is 222 \(userInfo.name)")
//        } onError: { error in
//            print("LBLog error is 222 \(error.localizedDescription)")
//        }.disposed(by: disposeBag)

    }
    
    
    ///测试多个任务并发后返回结果的 类似dispatch_group_t
    func testMutiAsyncTask(){
        Observable.zip(
            LBAPIManager.requestToken(),
            LBAPIManager.requestUserInfo("123")
        ).subscribe { (token, userInfo) in
            print("LBLog 获取token  用户信息成功 \(token) \(userInfo)")
        } onError: { error in
            guard let err = error as? NSError else { return }
            if judgeOptionalEqual(left: err.code, right: LBRequestError.token.rawValue) {
                print("LBLog 获取token失败 \(error.localizedDescription) )")
            }else{
                print("LBLog 获取用户信息失败 \(error.localizedDescription) )")
            }
            
        }.disposed(by: disposeBag)
    }

}


///判断是否相等
func judgeOptionalEqual<T: Equatable>(left: T?, right: T) -> Bool {
    guard let l = left else { return false }
    return l == right
}
