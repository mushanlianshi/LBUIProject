//
//  UIViewControllerBLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/8.
//

import UIKit
import BLTUIKitProject

extension BLTNameSpace where Base: UICollectionView{
    public func initFlowCollectionView(miniLineSpacing: CGFloat = 0, miniInterItemSpacing: CGFloat = 0, itemSize: CGSize = .zero, scrollDirection: UICollectionView.ScrollDirection = .vertical, delegate: UICollectionViewDelegate?, dataSource: UICollectionViewDataSource?) -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.itemSize = itemSize
        layout.minimumLineSpacing = miniLineSpacing
        layout.minimumInteritemSpacing = miniInterItemSpacing
        let collectionView = Base.init(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        return collectionView
    }
}


