//
//  LBRxSwiftPractiseViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/24.
//

import UIKit
import RxSwift

///RXSwift练习
class LBRxSwiftPractiseViewController: UIViewController {

    private let rxDisposeBag = DisposeBag()
    
    private var titleObserver: PublishSubject<String> = PublishSubject<String>.init()
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var stackView = UIStackView.blt_stackView(withSpacing: 10, distribution: .fill, alignment: .fill, axis: .vertical)!
    
    lazy var observerLab: UILabel = UILabel.blt.initWithText(text: "observer label", font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    
    lazy var binderLab: UILabel = UILabel.blt.initWithText(text: "binder label", font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        let viewList = [observerLab, binderLab]
        viewList.forEach(stackView.addArrangedSubview(_:))
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        self.testObserver()
        self.testBind()
        self.changeObserver()
    }
    
    
    func changeObserver() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            self?.titleObserver.onNext(" begin change")
        }
    }
    
    ///通过订阅的方式来观察变化刷新的
    func testObserver() {
        self.titleObserver.subscribe(onNext: {
            text in
            self.observerLab.text = text
        }).disposed(by: rxDisposeBag)
    }
    
    func testBind() {
        self.titleObserver.bind(to: self.binderLab.rx.text).disposed(by: rxDisposeBag)
    }

}
