//
//  LBSecondViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/15.
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
    var vcClass: AnyClass
    
    mutating func changeTitle(title: String)  {
        self.title = title
    }
}

class LBSecondViewController: UIViewController{
    lazy var collectionView: UICollectionView = {
        let width = view.bounds.width / 3
        let size = CGSize(width: width, height: width * 0.65)
        let collectionV = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 0, miniInterItemSpacing: 0, itemSize: size, scrollDirection: .vertical, delegate: self, dataSource: self)
        collectionV.register(LBSecondColumnListCell.self, forCellWithReuseIdentifier: LBSecondColumnListCell.blt_className)
        return collectionV
    }()
    
    lazy var dataSources = [
        LBListItemModel.init(title: "notificationView", vcClass: LBNotificationViewController.self),
    ]
    
    var changeModel = LBListItemModel.init(title: "111", vcClass: NSString.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        var model2 = changeModel
        changeModel.changeTitle(title: "22222")
        print("LBLog changeModel \(changeModel.title)")
        print("LBLog changeModel \(model2.title)")
        
//        let one = LBListItemModel.init(title: "notificationView", vcClass: LBNotificationViewController.self)
//        let two = LBListItemModel.init(title: "notificationView", vcClass: LBNotificationViewController.self)
//        let three = LBListItemModel.init(title: "notificationView1", vcClass: LBNotificationViewController.self)
//        if one == two{
//            print("LBLog struct is equal 1111")
//        }
//        if one == three{
//            print("LBLog struct is equal 2222")
//        }
        var a = 10
        var b = 20
        BLTSwapElement(a: &a, b: &b)
        print("LBLog swap a \(a) \(b)")
        testSwap(a: &a, b: &b)
        print("LBLog swap a \(a) \(b)")
        testSort()
    }
    
    func testSwap(a: inout Int, b: inout Int){
        a = 200
        b = 400
    }
    
    func testSort(){
        let model1 = sortSuperModel.init(model: SortModel.init(age: 1))
        let model2 = sortSuperModel.init(model: SortModel.init(age: 3))
        let model3 = sortSuperModel.init(model: SortModel.init(age: 2))
        let model4 = sortSuperModel.init(model: SortModel.init(age: 5))
        let model5 = sortSuperModel.init(model: SortModel.init(age: 4))
        let list = [model1, model2, model3, model4, model5]
        
        let sortList = list.sorted { sort1, sort2 in
            guard let m1 = sort1.model, let m2 = sort2.model else { return false }
            if m1.age < m2.age{
                return true
            }
            return false
        }
        
        print("LBLog sort list\(sortList)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}




extension LBSecondViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBSecondColumnListCell.blt_className, for: indexPath) as? LBSecondColumnListCell else { return UICollectionViewCell() }
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



class LBSecondColumnListCell: UICollectionViewCell{
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


struct sortSuperModel {
    var model: SortModel?
}

struct SortModel{
    var age = 2
}
