//
//  LBFlipCardViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/5.
//

import UIKit

class LBFlipCardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var collectionView: UICollectionView!
    var items: [String] = ["pageView1", "pageView2", "pageView3", "pageView4", "pageView5"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初始化collectionview
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.itemSize = view.bounds.size
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        // 设置CollectionView的代理
        collectionView.delegate = self
        collectionView.dataSource = self
        // 注册单元格
        collectionView.register(CardCollectionViewCell.self, forCellWithReuseIdentifier: "CardCollectionViewCell")
        // 添加到视图中
        view.addSubview(collectionView)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        
        // 设置卡片内容
        let cardContent = UIView(frame: cell.bounds)
        cardContent.backgroundColor = .gray
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: cell.bounds.width - 40, height: 50))
        label.text = items[indexPath.row]
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        cardContent.addSubview(label)
        cell.cardView.addSubview(cardContent)
        
        return cell
    }

}


extension LBFlipCardViewController {

    // 当CollectionView滚动时
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 所有可见的单元格的IndexPath
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems
        
        for indexPath in visibleIndexPaths {
            // 获取单元格
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
                // 计算单元格在CollectionView中的中心点坐标
                let cellCenter = self.collectionView.layoutAttributesForItem(at: indexPath)!.center
                
                // 根据单元格在屏幕上的位置和偏移量计算卡片旋转的角度
                let angle = atan2(cellCenter.y - scrollView.contentOffset.y - scrollView.bounds.height / 2, cellCenter.x - scrollView.contentOffset.x - scrollView.bounds.width / 2)
                
                // 应用旋转变换
                cell.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }

}


class CardCollectionViewCell: UICollectionViewCell {
    
    lazy var cardView: UIView = {
        let cardView = UIView(frame: bounds)
        cardView.layer.cornerRadius = 10
        cardView.clipsToBounds = true
        cardView.backgroundColor = .white
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cardView.addGestureRecognizer(tapGesture)
        
        return cardView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardView.transform = .identity
    }
    
    @objc func handleTap() {
        // 更新数据模型或触发其他UI操作
        // ...
    }
}
