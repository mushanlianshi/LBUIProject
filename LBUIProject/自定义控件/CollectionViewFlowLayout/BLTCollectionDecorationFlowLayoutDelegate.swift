//
//  BLTCollectionDecorationFlowLayoutDelegate.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/25.
//

import SwipeTableView

public class BLTCollectionSectionDecorationStyle: NSObject{
    var backgroundColor: UIColor = .white
    var layerCornerRadius: CGFloat?
    var backgroundColorInset: UIEdgeInsets?
}

@objc public protocol BLTCollectionDecorationFlowLayoutDelegate: STCollectionViewFlowLayoutDelegate{
    @objc optional func collectionViewSectionDecorationStyle(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> BLTCollectionSectionDecorationStyle?
    
    ///悬停某个section Header
    @objc optional func collectionViewPinHeaderAtSection(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> Bool
}

extension BLTCollectionDecorationFlowLayoutDelegate{
    public func collectionViewPinHeaderAtSection(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> Bool{
        return false
    }
}
