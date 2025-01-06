//
//  LBCollectionDecorationStickViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/25.
//

import UIKit
import SwipeTableView
import BLTSwiftUIKit
import BLTUIKitProject

///自定义UICollectionLayout  装饰视图的  悬停的
///UICollectionView sectionInset区域是header和footer之间的 item所在区域的inset  是内间距  不是外间距
class LBCollectionDecorationStickViewController: UIViewController {

    lazy var decorationStyle: BLTCollectionSectionDecorationStyle = {
       let style = BLTCollectionSectionDecorationStyle()
        style.layerCornerRadius = 10
        style.backgroundColorInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        return style
    }()
    
    lazy var columnCollectionView: STCollectionView = {
        let layout = BLTCollectionDecorationFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        layout.supportSectionHeaderSticky = true
        
        let collectionView = STCollectionView()
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.stDelegate = self
        collectionView.stDataSource = self
        collectionView.backgroundColor = .blt.f6BackgroundColor()
        collectionView.register(LLMoreOptionColumnCell.self, forCellWithReuseIdentifier: LLMoreOptionColumnCell.blt_className)
        collectionView.register(BLTCollectionSectionHeaderTextView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BLTCollectionSectionHeaderTextView.blt_className)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "UICollectionLayout  装饰视图的  悬停"
        self.view.backgroundColor = .white
        view.addSubview(columnCollectionView)
        columnCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LBCollectionDecorationStickViewController: STCollectionViewDelegate, STCollectionViewDataSource{
    func stCollectionView(_ collectionView: STCollectionView!, cellForItemAt indexPath: IndexPath!) -> UICollectionViewCell! {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LLMoreOptionColumnCell.blt_className, for: indexPath) as? LLMoreOptionColumnCell else { return UICollectionViewCell() }
        cell.titleLab.text = "\(indexPath.row)"
        return cell
    }
    
    func stCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10 * section + 5
    }
    
    func numberOfSections(inStCollectionView collectionView: UICollectionView) -> Int {
        return 6
    }
    
    func stCollectionView(_ collectionView: UICollectionView!, viewForSupplementaryElementOfKind kind: String!, at indexPath: IndexPath!) -> UICollectionReusableView! {
        if kind == UICollectionView.elementKindSectionHeader{
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BLTCollectionSectionHeaderTextView.blt_className, for: indexPath) as? BLTCollectionSectionHeaderTextView else {
                return nil
            }
            headerView.titleLab.text = "IndexPath section \(indexPath.section)"
            headerView.backgroundColor = .white
            return headerView
        }
        return nil
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width - 30, height: 52)
    }
    
}


extension LBCollectionDecorationStickViewController: BLTCollectionDecorationFlowLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView!, layout: STCollectionViewFlowLayout!, numberOfColumnsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionViewPinHeaderAtSection(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> Bool {
        if section == 1 || section == 2{
            return true
        }
        return false
    }
    
    func collectionViewSectionDecorationStyle(collectionView: UICollectionView, layout: UICollectionViewLayout, section: Int) -> BLTCollectionSectionDecorationStyle? {
        return decorationStyle
    }
}

class LLMoreOptionColumnCell: UICollectionViewCell {
    lazy var titleLab = UILabel.blt.initWithFont(font: UIFontPFFontSize(13), textColor: .blt.sixsixBlackColor())
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLab.textAlignment = .center
        titleLab.backgroundColor = UIColor.blt.randomColor()
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
