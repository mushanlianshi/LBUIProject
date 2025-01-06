//
//  LBCollectionViewExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/5.
//

import Foundation

extension UICollectionView{
    
    ///获取collectionView可视范围内最中间的cell对应的indexPath
    func nearCenterIndexPath(_ direction: UICollectionView.ScrollDirection = .vertical) -> IndexPath?{
        
        var tmpIndexPath: IndexPath?
        var offsetCenter = direction == .vertical ? self.bounds.size.height : self.bounds.size.width
        
        for indexPath in self.indexPathsForVisibleItems{
            guard let cell = self.cellForItem(at: indexPath), let collectionSuperView = self.superview else { return nil }
            ///把坐标系都转换到collectionView的父view上  对比center的距离 最小的  就是最靠近中心的indexPath
            let cellFrame = collectionSuperView.convert(cell.frame, from: cell.superview)
            var offset: CGFloat = 0
            if direction == .vertical{
                offset = abs(self.center.y - (cellFrame.origin.y / 2 + cellFrame.size.height / 2))
                
            }else{
                offset = abs(self.center.x - (cellFrame.origin.x / 2 + cellFrame.size.width / 2))
            }
            if offset < offsetCenter{
                offsetCenter = offset
                tmpIndexPath = indexPath
            }
        }
        
        return tmpIndexPath
    }
}
