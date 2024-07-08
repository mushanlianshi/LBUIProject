//
//  LBFoldCardViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/16.
//

import UIKit

let colorList: [UIColor] = {
    var list = [UIColor]()
    for index in 0...9{
        let color = UIColor.blt.randomColorWithNum(index)
        list.append(color)
    }
    return list
}()

class LBFoldCardCell: UICollectionViewCell {
    
    lazy var titleButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: nil, font: .blt.normalFont(16), color: .blt.threeThreeBlackColor())
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleButton)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleButton.frame = contentView.bounds
    }
    
}


///折叠式卡片collectionView
class LBFoldCardViewController: UIViewController {
    
    lazy var titleList = ["1", "2", "3", "4", "5", "6", "7", "8"]
    
    
    lazy var collectionView: UICollectionView = {
        let layout = CarouselFlowLayout.init()
//        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: view.bounds.width - 40, height: 300)
        layout.scrollDirection = .horizontal
        
        let colView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300), collectionViewLayout: layout)
        let padding = 10.0
        
//        layout.itemSize = CGSize(
//            width: (collectionView.frame.size.width - padding) / 1.21,
//            height: (collectionView.frame.size.width - padding) / 0.76
//        )
        layout.spacingMode = CarouselFlowLayoutSpacingMode.overlap(visibleOffset: 100)
        layout.sideItemScale = 0.8
        colView.backgroundColor = .white
        colView.register(LBFoldCardCell.self, forCellWithReuseIdentifier: LBFoldCardCell.blt_className)
        colView.delegate = self
        colView.dataSource = self
        colView.isPagingEnabled = false
        
        return colView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "折叠CardView"
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        collectionView.frame = view.bounds
    }

}

extension LBFoldCardViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBFoldCardCell.blt_className, for: indexPath) as? LBFoldCardCell else { return LBFoldCardCell() }
        cell.titleButton.setTitle(titleList[indexPath.row], for: .normal)
        cell.contentView.backgroundColor = colorList[indexPath.row]
//        print("LBLog color is \(colorList[indexPath.row])")
//        cell.contentView.backgroundColor = colorList[indexPath.row]
        return cell
    }
    
    
}
