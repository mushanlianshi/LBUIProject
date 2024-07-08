//
//  BLTImageSquareColumnView.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/5/23.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import BLTUIKitProject

@objc public enum BLTImageSquareColumnAutoSizeType: Int{
    case none
    case autoLayout
    case autoFrame
}

//九宫格展示图片的view
@objc open class BLTImageSquareColumnView: UIView {
    
    private static let shared = BLTImageSquareColumnView()
    
    open override class func appearance() -> Self {
        return shared as! Self
    }
    
    @objc public var customSensorDataBlock:((_ collectionView: UICollectionView) -> Void)?
    
//    展示图片的block
    public var configSquareImageCellBlock: ((_ imageCell: BLTImageCollectionViewCell, _ indexPath: IndexPath, _ imageArray: [Any]?) -> Void)?
//    预览图片的block
    public var previewImageBlock: ((_ index: Int, _ imageArray: [Any]?) -> Void)?
    
    var placeHolderImage: UIImage?
    
    public var col = 4{
        didSet{
            refreshImageCellSize()
        }
    }
    
    public var cellItemSize: CGSize = .zero{
        didSet{
            flowLayout.itemSize = cellItemSize
            collectionView.reloadData()
        }
    }
    
    public var imageArray: [Any]? {
        didSet{
            refreshHeightOfCollectionView()
            collectionView.reloadData()
        }
    }
    
//    预览高清大图的
    public var previewHighQualityImageArray: [String]?
    
    private var autoSizeType: BLTImageSquareColumnAutoSizeType = .autoLayout
    
    public lazy var flowLayout: UICollectionViewFlowLayout = {
       let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        return layout
    }()
    
    public lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: self.bounds, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.register(BLTImageCollectionViewCell.self, forCellWithReuseIdentifier: BLTImageCollectionViewCell.blt_className)
        return collectionView
    }()
    
    public convenience init(frame: CGRect = .zero, col: Int = 4, inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), autoSizeType: BLTImageSquareColumnAutoSizeType = .autoLayout) {
        self.init(frame: frame)
        self.col = col
        self.collectionView.contentInset = inset
        self.autoSizeType = autoSizeType
        refreshImageCellSize()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        refreshImageCellSize()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func refreshImageCellSize(){
        let collectionW = self.bounds.width > 0 ? self.bounds.width : UIScreen.main.bounds.size.width
        let contentW = collectionW - self.collectionView.contentInset.left - self.collectionView.contentInset.right
        let itemW = (contentW - flowLayout.minimumInteritemSpacing * (CGFloat(col) - 1.0)) / CGFloat(col)
        cellItemSize = CGSize(width: itemW, height: itemW)
    }
    
    private func refreshHeightOfCollectionView(){
        guard let array = imageArray else { return }
        let row = (array.count - 1) / col + 1
        let totalH = CGFloat(row) * cellItemSize.height + CGFloat(row) * (flowLayout.minimumInteritemSpacing - 1) + self.collectionView.contentInset.top + self.collectionView.contentInset.bottom
        if autoSizeType == .autoLayout{
            collectionView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(totalH)
            }
        }else if autoSizeType == .autoFrame{
            collectionView.snp.removeConstraints()
            collectionView.frame = CGRect(origin: .zero, size: CGSize(width: collectionView.frame.width, height: totalH))
            self.frame = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: totalH))
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let _ = newSuperview else { return }
        if self.customSensorDataBlock == nil{
            self.customSensorDataBlock = BLTImageSquareColumnView.appearance().customSensorDataBlock
        }
        self.customSensorDataBlock?(collectionView)
    }
    
}

extension BLTImageSquareColumnView: UICollectionViewDelegate, UICollectionViewDataSource{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let array = imageArray else { return 0 }
        return array.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BLTImageCollectionViewCell.blt_className, for: indexPath) as? BLTImageCollectionViewCell else { return UICollectionViewCell() }
        if let configBlock = configSquareImageCellBlock{
            configBlock(cell, indexPath, imageArray)
        }else if let array = imageArray as? [UIImage]{
            cell.imageView.image = array[indexPath.row]
        }else if let array = imageArray as? [String]{
            cell.imageView.kf.setImage(with: URL.init(string: array[indexPath.row]), placeholder: placeHolderImage)
        }
        configSquareImageCellBlock?(cell, indexPath, imageArray)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previewBlock = previewImageBlock{
            previewBlock(indexPath.row, imageArray)
            return
        }
        
        guard let vc = self.blt.currentViewController() else { return }
        
        var array: [Any]?
        if let highQualityImageArray = previewHighQualityImageArray{
            array = highQualityImageArray
        }else{
            array = imageArray
        }
        guard let imageList = array else { return }
        vc.blt_previewImage(imageList, currentIndex: indexPath.row)
//        vc.blt.previewImage(currentIndex: indexPath.row, imageArray: imageList)
    }
    
}
