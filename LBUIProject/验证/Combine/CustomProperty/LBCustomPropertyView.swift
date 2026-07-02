//
//  LBCustomPropertyView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation
import Combine
import SMSwiftBasicKit

// 扩展 UIButton，添加绑定函数
extension BLTNameSpace where Base: UIButton {
    
    func bindValidSelectResult<P: Publisher>(_ publisher: P) -> AnyCancellable where P.Output == LBButtonValidState, P.Failure == Never {
        return publisher
            .receive(on: DispatchQueue.main)
            .sink { result in
//                guard let self = self else { return }
                switch result {
                case .ok(let message, let color):
                    self.base.setTitle(message, for: .normal)
                    self.base.setTitleColor(color ?? .red, for: .normal)
                case .empty(let message, let color):
                    self.base.setTitle(message, for: .normal)
                    self.base.setTitleColor(color ?? .black, for: .normal)
                }
            }
    }
    
    
    func validResult<P: Publisher>(_ publisher: P) -> AnyCancellable where P.Output == String, P.Failure == Never {
        var cancelable = Set<AnyCancellable>()
        let p = PassthroughSubject<String, Error>().eraseToAnyPublisher()
        p.sink { result in
            switch result{
            case .finished:
                print("LBLog finished ----")
            case .failure(let err):
                print("LBLOg error is \(err.localizedDescription)")
            }
        } receiveValue: { value in
            
        }.store(in: &cancelable)


        return publisher.sink { value in
            self.base.titleLabel?.text = value
        }
    }
    
}

extension BLTNameSpace where Base: LBCustomPropertyView{
    
    func bindCustomModel<P: Publisher>(_ publisher: P) -> AnyCancellable where P.Output == LBCombinePropertyModel?, P.Failure == Never{
        return publisher
            .receive(on: DispatchQueue.main)
            .sink { model in
                guard let model else{
                    return
                }
                self.base.nameLab.text = model.name
                self.base.ageLab.text = "\(model.age)"
            }
    }
    
}


class LBCustomPropertyView: LBBaseView{
    
    private lazy var stackView = UIStackView.blt.initStackView(spacing: 10, axis: .vertical)
    
    fileprivate lazy var nameLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    
    fileprivate lazy var ageLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    
    lazy var button: UIButton = {
       let button = UIButton()
        button.setTitle("button", for: .normal)
        return button
    }()
    
    override func initSubView() {
        addSubview(stackView)
        [nameLab, ageLab, button].forEach(stackView.addArrangedSubview(_:))
        setConstraints()
    }
    
    private func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
