//
//  LBPageSegmentView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/21.
//

import UIKit

fileprivate extension Int{
    static let subviewStartTag = 1000
}

class LBPageSegmentView: UIView {
    
    var clickBlock: ((_ index: Int) -> Void)?
    
    lazy var stackView = UIStackView.blt_stackView(withSpacing: 10, distribution: .fillEqually, alignment: .fill)!
    private let titleList: [String]
    
    init(titleList: [String]){
        self.titleList = titleList
        super.init(frame: .zero)
//        YOLOv3Tiny.init(model: <#T##MLModel#>)
        self.backgroundColor = .white
        for (index, text) in titleList.enumerated(){
            let button = UIButton.blt.initWithTitle(title: text, font: .blt.normalFont(15), color: .black, target: self, action: #selector(itemButtonClicked(_:)))
            button.tag = .subviewStartTag + index
            stackView.addArrangedSubview(button)
        }
        addSubview(stackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stackView.frame = self.bounds
    }
    
    
    @objc private func itemButtonClicked(_ button: UIButton){
        clickBlock?(button.tag - .subviewStartTag)
    }
}
