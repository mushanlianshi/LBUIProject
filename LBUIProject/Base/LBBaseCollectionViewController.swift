//
//  LBBaseCollectionViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/16.
//

import Foundation
import BLTUIKitProject
import UIKit
import BLTSwiftUIKit

struct LBListItemModel: Equatable {
    static func == (lhs: LBListItemModel, rhs: LBListItemModel) -> Bool {
        return lhs.title == rhs.title && lhs.vcClass == rhs.vcClass
    }
    
    var title: String
    var vcClass: AnyClass?
    
    mutating func changeTitle(title: String)  {
        self.title = title
    }
}

class LBBaseCollectionViewController: UIViewController{
    lazy var collectionView: UICollectionView = {
        let width = view.bounds.width / 3
        let size = CGSize(width: width, height: width * 0.65)
        let collectionV = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 0, miniInterItemSpacing: 0, itemSize: size, scrollDirection: .vertical, delegate: self, dataSource: self)
        collectionV.register(LBBaseColumnListCell.self, forCellWithReuseIdentifier: LBBaseColumnListCell.blt_className)
        return collectionV
    }()
    
    lazy var dataSources = [LBListItemModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}




extension LBBaseCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBBaseColumnListCell.blt_className, for: indexPath) as? LBBaseColumnListCell else { return UICollectionViewCell() }
        cell.title = dataSources[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataSources[indexPath.row]
        if let vc = model.vcClass as? UIViewController.Type{
            self.navigationController?.pushViewController(vc.init(), animated: true)
        }
    }
}



class LBBaseColumnListCell: UICollectionViewCell{
    lazy var label = UILabel.blt.initWithFont(font: UIFontPFFontSize(15), textColor: UIColor.blt.hexColor(0x333333), numberOfLines: 0)
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.layer.addSublayer(lineLayer)
        label.textAlignment = .center
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
    }
    
    lazy var lineLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.blt.hexColor(0xDDDDDD).cgColor
        layer.lineWidth = 1.0 / UIScreen.main.scale
        return layer
    }()
    
    var title: String?{
        didSet{
            label.text = title
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if lineLayer.bounds != self.bounds{
            lineLayer.frame = self.bounds
            drawLine()
        }
    }
    
    private func drawLine(){
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: self.bounds.width, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        lineLayer.path = path.cgPath
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

