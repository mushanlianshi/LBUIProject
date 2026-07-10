//
//  LBSearchAndRequestBindCombineController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/6.
//

import Foundation
import Combine
import QMUIKit
import Alamofire

// MARK: - flatMapLatest 扩展（iOS 14 兼容，等价于 map + switchToLatest）

extension Publisher {
    func flatMapLatestNeverFailed<T: Publisher>(
            _ transform: @escaping (Output) -> T
    ) -> AnyPublisher<T.Output, T.Failure> where Self.Failure == T.Failure{
        map(transform)
            .switchToLatest()
            .eraseToAnyPublisher()
    }
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> {
        return map(transform).switchToLatest()
    }
}

// MARK: - 搜索服务
class LBSearchService {
    func search(_ query: String) -> AnyPublisher<[String], Error> {
        return AF.request("https://httpbin.org/get", parameters: ["q": query])
            .publishString()
            .value()
            .tryMap { _ in
                (0..<5).map { "搜索结果\($0 + 1): \(query)" }
            }
            .eraseToAnyPublisher()
    }
}

fileprivate extension NSNotification.Name{
    static let notRemoveNotification = Notification.Name.init(rawValue: "notRemoveNotification")
}

class LBSearchAndRequestBindCombineController: UIViewController {

    private lazy var textField: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "输入搜索内容（大于10字可提交）"
        tf.textColor = .blt.threeThreeBlackColor()
        tf.layer.borderColor = UIColor.lightGray.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 8
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blt.threeThreeBlackColor()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.text = "搜索到的结果会在这里展示"
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("确认提交", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.backgroundColor = .lightGray
        return button
    }()

    private let searchService = LBSearchService()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        bindUI()
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(testNotificationNotRemove), name: .notRemoveNotification, object: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            NotificationCenter.default.post(name: .notRemoveNotification, object: nil)
        })
    }

    @objc private func testNotificationNotRemove(){
        debugPrint("LBLog testNotificationNotRemove ------------------- ")
    }
    
    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(contentLabel)
        view.addSubview(confirmButton)

        textField.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(100)
            make.height.equalTo(44)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.top.equalTo(textField.snp.bottom).offset(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.left.right.equalTo(textField)
            make.top.equalTo(contentLabel.snp.bottom).offset(30)
            make.height.equalTo(44)
        }
    }

    private func bindUI() {
        
        /// 2. 输入框内容变化 -> 防抖0.5s -> 去重 -> flatMapLatest 模拟网络请求
        let publihserTest = textField.blt.publisherForTextChanged()
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMapLatest { [searchService] query -> AnyPublisher<(String, [String]), Never> in
                searchService.search(query)
                    .map { (query, $0) }
                    .catch { error in
                            // 这里可以拿到完整错误，做自定义处理
                            print("搜索失败，原始错误：\(error)")
                            // 区分错误类型示例
                            if let netErr = error as? URLError {
                                print("网络异常：\(netErr.code)")
                            }
                            // 返回兜底值的 Just Publisher  注意这里[String]() 不能直接[]，不然编译器推断不出来报错
                            return Just((query, [String]()))
                        }
                    .replaceError(with: (query, []))
                    .eraseToAnyPublisher()
            }
            .map{ (query, results) in
                debugPrint("LBLog query is \(query)")
                debugPrint("LBLog results is \(results)")
                return "搜索到的内容:\(results)"
            }
//            .map { query, results in
//                let resultText = results.isEmpty ? "暂无搜索结果" : results.joined(separator: "\n")
//                return "输入内容: \(query)\n\n搜索结果:\n\(resultText)"
//            }
        
        
        /// 2. 输入框内容变化 -> 防抖0.5s -> 去重 -> flatMapLatest 模拟网络请求
        textField.blt.publisherForTextChanged()
            .compactMap { $0 }
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .flatMapLatest { [searchService] query -> AnyPublisher<(String, [String]), Never> in
                searchService.search(query)
                    .map { (query, $0) }
                    .catch { error in
                            // 这里可以拿到完整错误，做自定义处理
                            print("搜索失败，原始错误：\(error)")
                            // 区分错误类型示例
                            if let netErr = error as? URLError {
                                print("网络异常：\(netErr.code)")
                            }
                            // 返回兜底值的 Just Publisher  注意这里[String]() 不能直接[]，不然编译器推断不出来报错
                            return Just((query, [String]()))
                        }
                    .replaceError(with: (query, []))
                    .eraseToAnyPublisher()
            }
            .map{ (query, results) in
                debugPrint("LBLog query is \(query)")
                debugPrint("LBLog results is \(results)")
                return "搜索到的内容:\(results)"
            }
//            .map { query, results in
//                let resultText = results.isEmpty ? "暂无搜索结果" : results.joined(separator: "\n")
//                return "输入内容: \(query)\n\n搜索结果:\n\(resultText)"
//            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: contentLabel)
            .store(in: &cancellables)

        /// 3. 输入框内容变化 -> 控制按钮是否可点击（>10字可提交）
        textField.blt.publisherForTextChanged()
            .compactMap { $0 }
            .map { $0.count > 10 }
            .assign(to: \.isEnabled, on: confirmButton)
            .store(in: &cancellables)

        /// 4. 按钮 isEnabled 变化驱动背景色切换（灰色 / 蓝色）
        confirmButton.publisher(for: \.isEnabled)
            .sink { [weak self] isEnabled in
                self?.confirmButton.backgroundColor = isEnabled ? .systemBlue : .lightGray
            }
            .store(in: &cancellables)
    }

    @objc private func confirmButtonTapped() {
        print("LBLog 确认提交: \(textField.text ?? "")")
    }
}
