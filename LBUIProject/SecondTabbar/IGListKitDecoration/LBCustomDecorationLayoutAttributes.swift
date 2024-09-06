//
//  LBCustomDecorationLayoutAttributes.swift
//  LBUIProject
//
//  Created by liu bin on 2024/9/6.
//

import Foundation

/// 组背景装饰的配置模型
struct LBCustomSectionBackgroundDecorationConfig{
    var backgroundColor: UIColor = .white
    var layerCornerRadius: CGFloat?
    var backgroundColorInset: UIEdgeInsets?
}

/// 自定义组装饰背景属性
class LBCustomSectionBackgroundDecorationLayoutAttributes: UICollectionViewLayoutAttributes{
    var sectionDecorationConfig: LBCustomSectionBackgroundDecorationConfig?
}


/// 自定制组背景装饰的view
class LBCustomSectionBackgroundDecorationView: UICollectionReusableView{
    
    static var kind: String = "LBCustomSectionBackgroundDecorationView"
    
    lazy var backgroundView: UIView = {
       let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(backgroundView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as?  LBCustomSectionBackgroundDecorationLayoutAttributes, let style = attributes.sectionDecorationConfig  else { return }
        backgroundView.backgroundColor = style.backgroundColor
        if let cornerRadius = style.layerCornerRadius {
            backgroundView.blt_layerCornerRaduis = cornerRadius
        }
        if let inset = style.backgroundColorInset{
            backgroundView.frame = CGRect(x: inset.left, y: inset.top, width: attributes.frame.width - inset.left - inset.right, height: attributes.frame.height - inset.top - inset.bottom)
        }else{
            backgroundView.frame = CGRect(x: 0, y: 0, width: attributes.frame.width, height: attributes.frame.height)
        }
    }
}
