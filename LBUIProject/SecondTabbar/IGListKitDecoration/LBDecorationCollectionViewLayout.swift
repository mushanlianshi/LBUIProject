//
//  LBDecorationCollectionViewLayout.swift
//  LBUIProject
//
//  Created by liu bin on 2024/9/6.
//

import UIKit

protocol LBDecorationSectionBackgroundLayoutDelegate: AnyObject{
    
    func customBackgroundDecorationConfig(_ section: Int) -> LBCustomSectionBackgroundDecorationConfig?
    
}

class LBDecorationSectionBackgroundLayout: UICollectionViewFlowLayout {
    // MARK: Properties
    
    /// 遵守背景装饰协议
    weak var decorationDelegate: LBDecorationSectionBackgroundLayoutDelegate?
    
    var decorationAttributes: [NSIndexPath: UICollectionViewLayoutAttributes]
    var sectionsWidthOrHeight: [NSIndexPath: CGFloat]
    
    lazy var layoutItemAttributes = [Int : [UICollectionViewLayoutAttributes]]()
    
    // MARK: Initialization
    
    override init() {
        self.decorationAttributes = [:]
        self.sectionsWidthOrHeight = [:]
        
        super.init()
        
        self.register(LBCustomSectionBackgroundDecorationView.self, forDecorationViewOfKind: LBCustomSectionBackgroundDecorationView.kind)
    }

    required init?(coder aDecoder: NSCoder) {
        self.decorationAttributes = [:]
        self.sectionsWidthOrHeight = [:]
        
        super.init(coder: aDecoder)
        
        self.register(LBCustomSectionBackgroundDecorationView.self, forDecorationViewOfKind: LBCustomSectionBackgroundDecorationView.kind)
    }
    
    // MARK: Providing Layout Attributes
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.decorationAttributes[indexPath as NSIndexPath]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBound = self.collectionView?.bounds ?? .zero
        if oldBound != newBounds {
            return true
        }
        return false
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        let numberOfSections = self.collectionView!.numberOfSections
        var xOrYOffset = 0 as CGFloat
        
        for sectionNumber in 0 ..< numberOfSections {
            let indexPath = IndexPath(row: 0, section: sectionNumber)
            
            let sectionWidthOrHeight = self.sectionsWidthOrHeight[indexPath as NSIndexPath]!
            let decorationAttribute = LBCustomSectionBackgroundDecorationLayoutAttributes(forDecorationViewOfKind: LBCustomSectionBackgroundDecorationView.kind, with: indexPath)
            
            if let decoration = self.decorationDelegate, let config = decoration.customBackgroundDecorationConfig(sectionNumber) {
                decorationAttribute.sectionDecorationConfig = config
            }
            
            decorationAttribute.zIndex = -1
            
            if self.scrollDirection == .vertical {
                decorationAttribute.frame = CGRect(x: 0, y: xOrYOffset, width: self.collectionViewContentSize.width, height: sectionWidthOrHeight)
            } else {
                decorationAttribute.frame = CGRect(x: xOrYOffset, y: 0, width: sectionWidthOrHeight, height: self.collectionViewContentSize.height)
            }
            
            xOrYOffset += sectionWidthOrHeight
            
            attributes?.append(decorationAttribute)
            self.decorationAttributes[indexPath as NSIndexPath] = decorationAttribute
        }
        
        return attributes
    }
    
    override func prepare() {
        super.prepare()
        
        guard self.collectionView != nil else { return }
        
        if self.scrollDirection == .vertical {
            let collectionViewWidthAvailableForCells = self.collectionViewContentSize.width - self.sectionInset.left - self.sectionInset.right
            let numberMaxOfCellsPerRow = floorf(Float((collectionViewWidthAvailableForCells + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing)))
            let numberOfSections = self.collectionView!.numberOfSections
            
            for sectionNumber in 0 ..< numberOfSections {
                let numberOfCells = Float(self.collectionView!.numberOfItems(inSection: sectionNumber))
                let numberOfRows = CGFloat(ceilf(numberOfCells / numberMaxOfCellsPerRow))
//                self.collectionView?.delegate.sizeForItem(at: <#T##Int#>)
//                if let delegate = self.collectionView?.delegate as? UICollectionViewDelegateFlowLayout {
//                    let itemsInSection = collectionView!.numberOfItems(inSection: sectionNumber)
//                    for index in 0...itemsInSection{
//                        let size = delegate.collectionView?(self.collectionView!, layout: self, sizeForItemAt: IndexPath.init(row: index, section: sectionNumber))
//                        print("LBLog size is \(size)")
//                    }
//                    
//                    let sectionHeight = delegate.collectionView!(self.collectionView!, layout: self, sizeForItemAt: IndexPath.init(row: itemsInSection - 1, section: sectionNumber)).height
//                    
//                    self.sectionsWidthOrHeight[NSIndexPath(row: 0, section: sectionNumber)] = sectionHeight
//                    return
//                }
                
                let sectionHeight = (numberOfRows * self.itemSize.height) + ((numberOfRows - 1) * self.minimumLineSpacing) + self.headerReferenceSize.height + self.footerReferenceSize.height + self.sectionInset.bottom + self.sectionInset.top
                
                self.sectionsWidthOrHeight[NSIndexPath(row: 0, section: sectionNumber)] = sectionHeight
            }
        } else {
            let collectionViewHeightAvailableForCells = self.collectionViewContentSize.height - self.sectionInset.top - self.sectionInset.bottom
            let numberMaxOfCellsPerColumn = floorf(Float((collectionViewHeightAvailableForCells + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing)))
            let numberOfSections = self.collectionView!.numberOfSections
            
            for sectionNumber in 0 ..< numberOfSections {
                let numberOfCells = Float(self.collectionView!.numberOfItems(inSection: sectionNumber))
                let numberOfColumns = CGFloat(ceilf(numberOfCells / numberMaxOfCellsPerColumn))
                let sectionWidth = (numberOfColumns * self.itemSize.width) + ((numberOfColumns - 1) * self.minimumLineSpacing) + self.headerReferenceSize.width + self.footerReferenceSize.width + self.sectionInset.left + self.sectionInset.right
                
                self.sectionsWidthOrHeight[NSIndexPath(row: 0, section: sectionNumber)] = sectionWidth
            }
        }
    }
    
    func prepareLayoutInSection(section: Int, rows: Int) {
        
    }
}
