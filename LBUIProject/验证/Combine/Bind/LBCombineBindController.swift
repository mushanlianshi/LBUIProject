//
//  LBCombineBindController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/7.
//

import Foundation
import Combine

enum AnError: Error {
    case someError
    case descError(_ desc: String)
}


enum LBInterfaceError: Error {
    case someError
    case descError(_ desc: String)
}


class LBObservableModel {
    var name = ""
    var age = 0
}

class LBCombineBindController: UIViewController{
    
    private lazy var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical)
    
    private lazy var contentView = LBCombineBindView()
    
    private lazy var userInfoView = LBCombineUserInfoView()
    
    private lazy var viewModel = LBCombineBindViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        [contentView, userInfoView].forEach(stackView.addArrangedSubview(_:))
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.viewModel.content = "dwehwfohewofhwe"
            self?.viewModel.userInfo = LBCombineUserInfoModel.init(name: "ddd", age: 22, imageUrl: "")
            self?.changeUserInfoAgain()
        })
        bindUI()
//        testCombineError()
//        testCombineFinished()
//        testCombineModel()
        testSendMoreError()
        testMapThread()
    }
    
    func changeUserInfoAgain()  {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.viewModel.content = "111111"
            self?.viewModel.userInfo = LBCombineUserInfoModel.init(name: "aaaaa", age: 555, imageUrl: "")
        })
    }
    
    func bindUI() {
        viewModel.$content
            .receive(on: RunLoop.main) // 确保在主线程更新 UI
            .assign(to: \.text, on: contentView.contentLab) // 直接绑定到 label.text
            .store(in: &cancellables) // 存储订阅
        
        viewModel.$userInfo.sink { [weak self] model in
            self?.userInfoView.updateInfo(model)
        }.store(in: &cancellables)
        
    }
    
    func testCombineError() {
        let subject = PassthroughSubject<Int, AnError>()
        subject.sink { result in
            print("LBLog result is 第一个订阅 \(result)")
        } receiveValue: { value in
            print("LBLog value is 第一个订阅 \(value)")
        }.store(in: &cancellables)
        // 第二个订阅
        subject.sink { result in
            print("LBLog result is 22 第二个订阅 \(result)")
        } receiveValue: { value in
            print("LBLog value is 22 第二个订阅 \(value)")
        }.store(in: &cancellables)
        // 第三个订阅
        subject.sink { result in
            print("LBLog result is 33 第三个订阅 \(result)")
        } receiveValue: { value in
            print("LBLog value is 33 第三个订阅 \(value)")
        }.store(in: &cancellables)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(completion: .failure(.someError))
    }
    
    func testCombineFinished() {
        let subject = PassthroughSubject<Int, AnError>()
        subject.sink { result in
            print("LBLog testCombineFinished is \(result)")
        } receiveValue: { value in
            print("LBLog testCombineFinished is \(value)")
        }.store(in: &cancellables)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(completion: .finished)
    }
    
    func testCombineModel() {
        let subject = PassthroughSubject<LBObservableModel?, LBInterfaceError>()
        
        subject.sink { result in
            /// 取出error 接口报错，处理逻辑
            switch result {
            case .finished:
                print("LBLog 第一个订阅 received finished")
            case .failure(let error):
                switch error {
                case .someError:
                    print("LBLog 第一个订阅 received failure with error: \(error)")
                case .descError(let desc):
                    print("LBLog 第一个订阅 received failure with desc: \(desc)")
                }
            }
        } receiveValue: { value in
            if let value {
                print("LBLog value is 第一个订阅 \(value.name)")
                print("LBLog value is 第一个订阅 \(value.age)")
            }
            
        }.store(in: &cancellables)
        
        // 第二个订阅
        subject.sink { result in
            print("LBLog value is 22 第二个订阅 \(result)")
        } receiveValue: { value in
            if let value {
                print("LBLog value is 第二个订阅 \(value.name)")
                print("LBLog value is 第二个订阅 \(value.age)")
            }
        }.store(in: &cancellables)
        
        let model = LBObservableModel.init()
        model.age = 10
        model.name = "first"
        subject.send(model)
        model.age = 20
        model.name = "second"
        subject.send(model)
        
        let newModel = LBObservableModel.init()
        newModel.age = 666
        newModel.name = "newModel name"
        subject.send(newModel)
        
        subject.send(completion: .failure(.descError("用户id缺失")))
        subject.send(completion: .failure(.someError))
    }
    
    
    
    
    
    func testSendMoreError() {
        let firstPublisher = fetchData(isFirst: true)
        firstPublisher.sink { result in
            print("LBLog result is 11 \(result)")
        } receiveValue: { value in
            print("LBLog value is 11 \(value)")
        }.store(in: &cancellables)
        
        let secondPublisher = fetchData(isFirst: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            secondPublisher.sink { result in
                print("LBLog result is 22 \(result)")
            } receiveValue: { value in
                print("LBLog value is 22 \(value)")
            }.store(in: &self.cancellables)
        })
    }
    
    
    // 模拟网络请求返回的发布者
    private func fetchData(isFirst: Bool) -> PassthroughSubject<String, LBInterfaceError> {
        let subject = PassthroughSubject<String, LBInterfaceError>()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if isFirst{
                let resultName = "first 请求回来了 name = liubin "
                subject.send(resultName)  // 发送结果
                subject.send(resultName + resultName)
                subject.send(completion: .failure(.descError("first 接口报错了")))  // 发送完成
            }else{
                let resultName = "second 请求回来了 name = liubin "
                subject.send(resultName)  // 发送结果
                subject.send(resultName + resultName)
                subject.send(completion: .failure(.descError("second 接口报错了")))  // 发送完成
            }
        }
        return subject
    }
    
    // 一个具体的Publisher
    func fetchData() -> AnyPublisher<String, Never> {
        // 返回一个 Future 类型的Publisher
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                promise(.success("请求回来的数据"))
            }
        }
        .eraseToAnyPublisher()  // 通过 eraseToAnyPublisher() 隐藏具体类型
    }
    
    deinit {
        print("LBLog LBCombineBindController de init \(self.description)")
    }
    
    @Published var value1: String = ""

    var validatedValue1: AnyPublisher<String?, Never> {
        return $value1.map { value1  in
            print("LBLog currentThread is ------ \(Thread.current) \(value1)")
            guard value1.count > 2 else {
                DispatchQueue.main.async {
                    print("LBlog -------")
                }
                return nil
            }
            DispatchQueue.main.async {
                
            }
            return value1
        }.eraseToAnyPublisher()
    }
    
    func testMapThread() {
        self.validatedValue1.sink { result in
            
        } receiveValue: { value in
            print("LBLog testMapThread value is \(value)")
            print("LBLog testMapThread value is \(Thread.current)")
        }.store(in: &cancellables)
    }
    
}
