//
//  BLTColumnItemView.swift
//  chugefang
//
//  Created by liu bin on 2023/8/22.
//  Copyright © 2023 baletu123. All rights reserved.
//

import Foundation

/**
 使用示例：
 private lazy var noteView: BLTColumnItemView = {
     let view = BLTColumnItemView(title: "跟进记录", content: "企微跟进租客，准时到场", spacing: 2, distribution: .fill)
     view.axis = .vertical
     view.refreshAlignment(firstAlignment: .left, secondAlignment: .left)
     view.refreshFontAndColor(firstFont: .blt.normalFont(12), firstColor: .blt.ninenineBlackColor(), secondFont: .blt.mediumFont(15), secondColor: .blt.threeThreeBlackColor())
     return view
 }()
 */
///一个左右 或则上下两部分的view 默认横向排列 左边的空间 压缩抗压缩等级高
///左边默认居左   右边默认居右
///上下排列时，默认居中展示
open class BLTColumnItemView: UIView {
    
    public var axis: NSLayoutConstraint.Axis?{
        didSet{
            guard let a = axis, a == .vertical else { return }
            changeAxisToVertical()
        }
    }
    
    public lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .equalSpacing
        view.alignment = .fill
        view.axis = .horizontal
        return view
    }()
    
    public lazy var firstLab = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: .blt.sixsixBlackColor())
    public lazy var secondLab: UILabel = {
       let label = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: .blt.threeThreeBlackColor())
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    public var customFirstView: UIView?{
        didSet{
            guard let view = customFirstView, let firstView = stackView.subviews.first else { return }
            stackView.removeArrangedSubview(firstView)
            stackView.insertArrangedSubview(view, at: 0)
        }
    }
    
    public var customSecondView: UIView?{
        didSet{
            guard let view = customSecondView, stackView.subviews.count > 1, stackView.subviews[1].superview == stackView else { return }
            stackView.removeArrangedSubview(stackView.subviews[1])
            stackView.addArrangedSubview(view)
        }
    }
    
    
    public convenience init(title: String, content: String? = nil, spacing: CGFloat = 10, distribution: UIStackView.Distribution = .equalSpacing) {
        self.init(title: title, spacing: spacing, contentInsets: .zero)
        secondLab.text = content
        stackView.distribution = distribution
    }
    
    public init(title:String, spacing: CGFloat = 10, contentInsets: UIEdgeInsets = .zero){
        super.init(frame: .zero)
        [NSLayoutConstraint.Axis.horizontal].forEach { axis in
            firstLab.setContentHuggingPriority(.required, for: axis)
            firstLab.setContentCompressionResistancePriority(.required, for: axis)
            secondLab.setContentHuggingPriority(.defaultHigh, for: axis)
            secondLab.setContentCompressionResistancePriority(.defaultHigh, for: axis)
        }
        firstLab.text = title
        stackView.spacing = spacing
        addSubview(stackView)
        stackView.addArrangedSubview(firstLab)
        stackView.addArrangedSubview(secondLab)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(contentInsets)
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshFontAndColor(firstFont: UIFont? = nil, firstColor: UIColor = .blt.threeThreeBlackColor(), secondFont: UIFont? = nil, secondColor: UIColor = .blt.threeThreeBlackColor()){
        if let font = firstFont{
            firstLab.font = font
        }
        firstLab.textColor = firstColor
        
        if let font = secondFont{
            secondLab.font = font
        }
        secondLab.textColor = secondColor
    }
    
    
    public func refreshAlignment(firstAlignment: NSTextAlignment, secondAlignment: NSTextAlignment){
        firstLab.textAlignment = firstAlignment
        secondLab.textAlignment = secondAlignment
    }
    
    public func changeAxisToVertical(_ autoAlignCenter: Bool = true){
        stackView.axis = .vertical
        guard autoAlignCenter else {
            return
        }
        firstLab.textAlignment = .center
        secondLab.textAlignment = .center
        firstLab.setContentHuggingPriority(.required, for: .vertical)
        firstLab.setContentCompressionResistancePriority(.required, for: .vertical)
        secondLab.setContentHuggingPriority(.defaultHigh, for: .vertical)
        secondLab.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    }
    
}
