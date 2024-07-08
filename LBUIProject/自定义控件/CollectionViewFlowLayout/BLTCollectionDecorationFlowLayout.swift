//
//  BLTCollectionDecorationFlowLayout.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/5/30.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import UIKit
import BLTBasicUIKit
import SwipeTableView

fileprivate class BLTCollectionSectionDecorationLayoutAttributes: UICollectionViewLayoutAttributes{
    var sectionDecorationStyle: BLTCollectionSectionDecorationStyle?
}


public class BLTCollectionDecorationFlowLayout: STCollectionViewFlowLayout {
    
    ///是否支持悬停section的  不需要就不必改变shouldInvalidateLayout
    public var supportSectionHeaderSticky = false
    
    private lazy var decorationViewAttrs = [BLTCollectionSectionDecorationLayoutAttributes]()
    private lazy var pinHeaderAttrs = [BLTCollectionSectionDecorationLayoutAttributes]()
    
    override init() {
        super.init()
        self.register(BLTCollectionSectionDecorationView.self, forDecorationViewOfKind: .sectionDecorationKey)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public override func prepare() {
        super.prepare()
        decorationViewAttrs.removeAll()
        let sections = collectionView?.numberOfSections
        guard let numberOfSections = sections, numberOfSections != 0, numberOfSections <= self.sectionRects.count else { return }
        
        guard let delegate = collectionView?.delegate as? BLTCollectionDecorationFlowLayoutDelegate else { return }
    
        for index in 0...(numberOfSections - 1){
            //1.添加装饰视图的属性
            let decorationAttr = BLTCollectionSectionDecorationLayoutAttributes.init(forDecorationViewOfKind: .sectionDecorationKey, with: IndexPath(row: 0, section: index))
            if let value = self.sectionRects[index] as? NSValue{
                decorationAttr.frame = value.cgRectValue
            }
            decorationAttr.zIndex = -1
            decorationAttr.sectionDecorationStyle = delegate.collectionViewSectionDecorationStyle?(collectionView: collectionView!, layout: self, section: index)
            decorationViewAttrs.append(decorationAttr)
            
            ///2.添加悬停属性
            if(supportSectionHeaderSticky){
                self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: index))
            }
//            processPinHeaderIfNeeded(index)
        }
    }
    
    
    ///如果需要悬停  修改父layout例的sectionHeader attributes
    private func processPinHeaderIfNeeded(_ section: Int) {
        print("LBLog processPinHeaderIfNeeded ======")
        guard let collectionV = collectionView, let delegate = collectionView?.delegate as? BLTCollectionDecorationFlowLayoutDelegate else { return }
        guard let shouldPin = delegate.collectionViewPinHeaderAtSection?(collectionView: collectionV, layout: self, section: section), shouldPin else { return }
        ///调用这个方法去 修改位置悬停的
        self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: section))
        
    }
    
    
//   2. 返回装饰视图的属性  在prepare()自己计算了 不需要这个了
//    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        guard let _ = collectionView?.delegate as? BLTCollectionDecorationFlowLayoutDelegate else { return nil}
//        if elementKind == .sectionDecorationKey, indexPath.section < self.decorationViewAttrs.count{
//            return decorationViewAttrs[indexPath.section]
//        }
//        return super.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
//    }
    
    
    ///重写header footer方法 悬停某个header的
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath), let collectionV = collectionView else {
            return nil
        }
        
        guard let delegate = collectionV.delegate as? BLTCollectionDecorationFlowLayoutDelegate else { return attributes}
        
        
        guard let canPin = delegate.collectionViewPinHeaderAtSection?(collectionView: collectionV, layout: self, section: indexPath.section), canPin, elementKind == UICollectionView.elementKindSectionHeader  else {
            return attributes
        }
        
        let lastSectionRect = self.rectForSection(at: indexPath.section - 1)
        let maxLastY = CGRectGetMaxY(lastSectionRect)
        ///设置悬停
        attributes.frame.origin.y = max(collectionV.contentOffset.y , maxLastY)
        attributes.zIndex = 1024
        print("LBLog pin section \(indexPath.section) \(collectionV.contentOffset.y) \(maxLastY)")
        
        return attributes
    }

    
//重写视图attributes  返回添加装饰视图的信息
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var array = super.layoutAttributesForElements(in: rect)
        array?.append(contentsOf: decorationViewAttrs)
        return array
    }
    
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds ?? .zero
        if oldBounds != newBounds{
            return true
        }
        
        guard supportSectionHeaderSticky else {
            return false
        }
        return true
    }
    
}

fileprivate extension String{
    static let sectionDecorationKey = "BLTCollectionSectionDecorationLayoutAttributes"
}


class BLTCollectionSectionDecorationView: UICollectionReusableView{
    
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
        guard let attributes = layoutAttributes as?  BLTCollectionSectionDecorationLayoutAttributes, let style = attributes.sectionDecorationStyle  else { return }
        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.blt_layerCornerRaduis = style.layerCornerRadius ?? 0
        if let inset = style.backgroundColorInset{
            backgroundView.frame = CGRect(x: inset.left, y: inset.top, width: attributes.frame.width - inset.left - inset.right, height: attributes.frame.height - inset.top - inset.bottom)
        }else{
            backgroundView.frame = CGRect(x: 0, y: 0, width: attributes.frame.width, height: attributes.frame.height)
        }
    }
}
