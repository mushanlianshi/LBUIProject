//
//  LBTestPageViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/5.
//

import UIKit

class LBCustomScaleFlowLayout: UICollectionViewFlowLayout {
    
    var minScale = 0.8
    
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        print("LBLog shouldInvalidateLayout ========== ")
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        
        print("LBLog center index path is \(collectionView.nearCenterIndexPath(.horizontal))")
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        let rows = collectionView.numberOfItems(inSection: 0)
        
        var offsetIndex = collectionView.contentOffset.x / collectionView.bounds.width
        let startX = offsetIndex * collectionView.bounds.width
        
        for index in 0..<rows{
            let originX = collectionView.bounds.width * CGFloat(index)
            let offsetX = startX - originX
            
            var alpha: CGFloat = 1
            var scale = 1 - offsetX / collectionView.bounds.width * 3
            
//            print("LBLog scale is  \(scale) \(offsetX)")
            var transform = CGAffineTransform.identity
            
            switch scale {
            case -CGFloat.greatestFiniteMagnitude ..< -1:
                alpha = minScale
            case -1 ... 1:
                var s = abs(scale)
                s = max(minScale, scale)
                alpha = s
                transform.a = s
                transform.d = s
            case 1 ..< CGFloat.greatestFiniteMagnitude:
                alpha = minScale
            default:
                break
            }

            
            let attribute = UICollectionViewLayoutAttributes.init(forCellWith: IndexPath(row: index, section: 0))
            attribute.frame = CGRect(x: CGFloat(index) * collectionView.bounds.width, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height)
            
            
            attribute.alpha = alpha
            attribute.transform = transform
            
            
            layoutAttributes.append(attribute)
        }
        
        return layoutAttributes
    }
    
}

class LBTestPageViewController: UIViewController {
    
    lazy var imageList = ["pageView1", "pageView2", "pageView3", "pageView4","pageView5","pageView6"]
    
    lazy var collectionView: UICollectionView = {
        let layout = LBCustomScaleFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: view.bounds.size.width, height: 200)
//        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let view = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200), collectionViewLayout: layout)
        view.register(LBTestPageCell.self, forCellWithReuseIdentifier: "LBTestPageCell")
        view.delegate = self
        view.dataSource = self
        view.isPagingEnabled = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "缩放的轮播图"
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }

}

extension LBTestPageViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LBTestPageCell", for: indexPath) as? LBTestPageCell else { return UICollectionViewCell() }
        cell.imageView.image = UIImage(named: imageList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
}


class LBTestPageCell: UICollectionViewCell {
    
    lazy var imageView = UIImageView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
}
