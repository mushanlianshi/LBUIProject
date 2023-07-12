//
//  UIViewControllerBLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/8.
//

import UIKit
import BLTUIKitProject

extension BLTNameSpace where Base: UICollectionView{
    
    public static func initFlowCollectionView(miniLineSpacing: CGFloat = 0, miniInterItemSpacing: CGFloat = 0, itemSize: CGSize = .zero, scrollDirection: UICollectionView.ScrollDirection = .vertical, delegate: UICollectionViewDelegate?, dataSource: UICollectionViewDataSource?) -> UICollectionView{
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.itemSize = itemSize
        layout.minimumLineSpacing = miniLineSpacing
        layout.minimumInteritemSpacing = miniInterItemSpacing
        let collectionView = Base.init(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = delegate
        collectionView.dataSource = dataSource
        return collectionView
    }
    
    public func registerReusableCell<T: UICollectionViewCell>(cell: T.Type){
        base.register(T.self, forCellWithReuseIdentifier: T.blt_className)
    }
    
    public func dequeueReusableCell<T: UICollectionViewCell>(_ type: T.Type, indexPath: IndexPath) -> T{
        guard let cell = base.dequeueReusableCell(withReuseIdentifier: T.blt_className, for: indexPath) as? T else {
            fatalError(.dequeueCellFailedMsg)
        }
        return cell
    }
    
    public func registerReusableHeaderFooter<T: UICollectionReusableView>(header: T.Type, kind: String){
        base.register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: T.blt_className)
    }
    
    public func dequeueReusableHeaderFooter<T: UICollectionReusableView>(_ type: T.Type ,indexPath: IndexPath, kind: String) -> T{
        guard let view = base.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.blt_className, for: indexPath) as? T else {
            fatalError(.dequeueHeaderFooterFailedMsg)
        }
        return view
    }
    
    
    ///获取collectionView可视范围内最中间的cell对应的indexPath
    public func nearCenterIndexPath(_ direction: UICollectionView.ScrollDirection = .vertical) -> IndexPath?{
        var tmpIndexPath: IndexPath?
        var offsetCenter = direction == .vertical ? base.bounds.size.height : base.bounds.size.width
        ///也可以用collectionView 的bounds来获取中间点
//        base.bounds.midX midY
        
        for indexPath in base.indexPathsForVisibleItems{
            guard let cell = base.cellForItem(at: indexPath), let collectionSuperView = base.superview else { return nil }
            ///把坐标系都转换到collectionView的父view上  对比center的距离 最小的  就是最靠近中心的indexPath
            let cellFrame = collectionSuperView.convert(cell.frame, from: cell.superview)
            var offset: CGFloat = 0
            if direction == .vertical{
                offset = abs(base.center.y - (cellFrame.origin.y / 2 + cellFrame.size.height / 2))
                
            }else{
                offset = abs(base.center.x - (cellFrame.origin.x / 2 + cellFrame.size.width / 2))
            }
            if offset < offsetCenter{
                offsetCenter = offset
                tmpIndexPath = indexPath
            }
        }
        
        return tmpIndexPath
    }
}


