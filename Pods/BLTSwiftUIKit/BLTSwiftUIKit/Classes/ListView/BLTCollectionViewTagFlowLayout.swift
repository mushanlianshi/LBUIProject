//
//  BLTCollectionViewTagFlowLayout.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/3/13.
//

import UIKit

///自定义标签流  collectionView的delegate必须遵守UICollectionViewDelegateFlowLayout 协议  实现返回itemsize headersize等可选方法
///如果要获取标签的总高度 设置好约束 reloadData 后layoutIfNeed获取contentSize即总高度
open class BLTCollectionViewTagFlowLayout: UICollectionViewFlowLayout {
    
    public lazy var allItemAttributeList = [UICollectionViewLayoutAttributes]()
    public lazy var itemAttributeList = [[UICollectionViewLayoutAttributes]]()
    public lazy var sectionHeaderAttributeList = [UICollectionViewLayoutAttributes]()
    public lazy var sectionFooterAttributeList = [UICollectionViewLayoutAttributes]()
    
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = self.collectionView else { return }
        self.allItemAttributeList.removeAll()
        self.itemAttributeList.removeAll()
        self.sectionHeaderAttributeList.removeAll()
        self.sectionFooterAttributeList.removeAll()
        
        let numberOfSections = collectionView.numberOfSections
        guard numberOfSections > 0 else {
            return
        }
        
        
        guard let collectionViewDelegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout else {
            return
        }
        
        
        var lastSectionFrame = CGRect.zero
        
        var contentW = collectionView.bounds.width - collectionView.contentInset.blt.contentWidth() - self.sectionInset.blt.contentWidth()
        
        guard contentW > 0 else {
            return
        }
        
        for index in 0..<numberOfSections {
            
            var headerSize = CGSize.zero
        
            if let size = collectionViewDelegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: index){
                headerSize = size
            }else if self.headerReferenceSize != .zero{
                headerSize = self.headerReferenceSize
            }
            
            //1.section header attribute
            if headerSize != .zero {
                let sectionHeaderAttribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath.init(row: 0, section: index))
                sectionHeaderAttribute.frame = CGRect(x: 0, y: lastSectionFrame.maxY, width: headerSize.width, height: headerSize.height)
                sectionHeaderAttributeList.append(sectionHeaderAttribute)
                allItemAttributeList.append(sectionHeaderAttribute)
    //            BLTSwiftLog("LBlog section header frame \(sectionHeaderAttribute.frame)")
            }
            
            
            //2.item attributeText
            let rowsInSection = collectionView.numberOfItems(inSection: index)
            
            var cellX = 0.0
            var cellY = 0.0
            if sectionHeaderAttributeList.isEmpty == false {
                cellY = self.sectionHeaderAttributeList.last!.frame.maxY
            }
            
            
            var tmpCellList = [UICollectionViewLayoutAttributes]()
            var itemSpacing = self.minimumInteritemSpacing
            var lineSpacing = self.minimumLineSpacing
            
            print("LBLog  item spacing is \(itemSpacing) \(lineSpacing)")
            
            var sectionInset = UIEdgeInsets.zero
            //处理cell是否设置了sectionInset
            if let inset = collectionViewDelegate.collectionView?(collectionView, layout: self, insetForSectionAt: index) {
                contentW = collectionView.bounds.width - collectionView.contentInset.blt.contentWidth() - inset.blt.contentWidth()
                sectionInset = inset
                cellY += inset.top
                cellX += inset.left
            }
            
            var lastFrame = CGRect(origin: CGPoint(x: cellX, y: cellY), size: .zero)
            for rowIndex in 0..<rowsInSection {
                var cellSize = CGSize.zero
                let indexPath = IndexPath.init(row: rowIndex, section: index)
                if let size = collectionViewDelegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) {
                    cellSize = size
                }
                if let spacing = collectionViewDelegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: index) {
                    itemSpacing = spacing
                }
                
                if let spacing = collectionViewDelegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: index) {
                    lineSpacing = spacing
                }
                
                let itemAttribute = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                if cellSize != .zero {
                    //判断rowIndex = 0  是不是第一个 不是第一个才加itemSpacing 考虑换行
                    if rowIndex != 0 {
                        cellX = lastFrame.maxX + itemSpacing
                        cellY = lastFrame.minY
                        //换行
                        if cellX + cellSize.width > contentW {
                            cellX = sectionInset.left
                            cellY += cellSize.height + lineSpacing
                        }
                    }
                    
                    lastFrame = CGRect(x: cellX, y: cellY, width: cellSize.width, height: cellSize.height)
                }
                itemAttribute.frame = lastFrame
                tmpCellList.append(itemAttribute)
                allItemAttributeList.append(itemAttribute)
            }
            itemAttributeList.append(tmpCellList)
            
            //3.section footer
            var footerSize = CGSize.zero
            if let size = collectionViewDelegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: index){
                footerSize = size
            }else if self.footerReferenceSize != .zero{
                footerSize = self.footerReferenceSize
            }
            
            
            let footerFrame = CGRect(x: 0, y: lastFrame.maxY + sectionInset.bottom, width: footerSize.width, height: footerSize.height)
            lastSectionFrame = footerFrame
            
            if footerSize != .zero {
                let sectionFooterAttribute = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath.init(row: 0, section: index))
                sectionFooterAttribute.frame = footerFrame
    //            BLTSwiftLog("LBlog section footer frame \(footerFrame)")
                sectionFooterAttributeList.append(sectionFooterAttribute)
                allItemAttributeList.append(sectionFooterAttribute)
            }
        }
        
//        BLTSwiftLog("LBLog all item attributes is \(allItemAttributeList)")
    }
    
    
    ///必须实现的方法
    public override var collectionViewContentSize: CGSize{
        guard let collectionView = self.collectionView, self.allItemAttributeList.isNotEmpty() else { return .zero }
        let height = self.allItemAttributeList.last!.frame.maxY + collectionView.contentInset.blt.contentHeight()
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.allItemAttributeList
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard indexPath.section < itemAttributeList.count else { return nil }
        
        guard indexPath.row < itemAttributeList[indexPath.section].count else { return nil }
        return self.itemAttributeList[indexPath.section][indexPath.row]
    }
    
    
    
    
    
    
    ///处理布局无效  当宽度变化了才无效掉布局  不然按原来计算的处理
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = self.collectionView else { return false }
        if collectionView.bounds.width != newBounds.width {
            return true
        }
        return false
    }
}















