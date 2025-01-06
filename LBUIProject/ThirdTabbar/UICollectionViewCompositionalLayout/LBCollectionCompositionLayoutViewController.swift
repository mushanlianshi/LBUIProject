//
//  LBCollectionCompositionLayoutViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/13.
//

import UIKit
import BLTSwiftUIKit

class LBCollectionCompositionLayoutViewController: UIViewController {

    ///Section类型的模型
    enum SectionKind: Int {
        case paging, groupPagingCentered, none, continuous,continuousGroupLeadingBoundary, groupPaging
        ///滚动的类型 none是竖直滚动的  别的都是横向滚动的 效果有paging  有groupPagingCentered等
        func scrollBehavior() -> UICollectionLayoutSectionOrthogonalScrollingBehavior {
            switch self {
            case .continuous:
                return .continuous
            case .continuousGroupLeadingBoundary:
                return .continuousGroupLeadingBoundary
            case .paging:
                return .paging
            case .groupPaging:
                return .groupPaging
            case .groupPagingCentered:
                return .groupPagingCentered
            case .none:
                return .none
            }
        }
    }
    
    ///！隐式解包  用之前会确保已经创建了  避免使用optional来每次判断 或则解包的
    private var dataSources: UICollectionViewDiffableDataSource<LBCollectionCompositionLayoutSectionModel, LBCollectionCompositionLayoutItemModel>! = nil
    private var collectionView: UICollectionView! = nil
    
    private lazy var viewModel = LBCollectionCompositionLayoutViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "UICollectionViewCompositionalLayout布局"
        view.backgroundColor = .white
        createCollectionView()
        bindCollectionViewDataSources()
    }

    private func createCollectionView(){
        let layout = createCollectionViewLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        collectionView.register(LBCollectionCompositionLayoutBannerCell.self, forCellWithReuseIdentifier: LBCollectionCompositionLayoutBannerCell.blt_className)
        collectionView.register(LBCollectionCompositionLayoutTextCell.self, forCellWithReuseIdentifier: LBCollectionCompositionLayoutTextCell.blt_className)
        collectionView.register(LBCollectionCompositionLayoutListCell.self, forCellWithReuseIdentifier: LBCollectionCompositionLayoutListCell.blt_className)
        collectionView.register(BLTCollectionSectionHeaderTextView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BLTCollectionSectionHeaderTextView.blt_className)
        collectionView.delegate = self
        view.addSubview(collectionView)
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout{
        ///设置section间距
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 15
        
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: { (sectionIndex, environment) -> NSCollectionLayoutSection? in
//            guard let sectionKind = SectionKind(rawValue: sectionIndex) else {
//                print("LBLog unknow section")
//                return nil
//            }
            var section: NSCollectionLayoutSection!
            let model = self.viewModel.dataSources[sectionIndex]
            ///section = 0 是轮播图样式的
            if model.type == .banner{
                ///fractionalWidth 屏幕的宽度比
                let bannerItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let bannerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3)), subitems: [bannerItem])
                section = NSCollectionLayoutSection(group: bannerGroup)
                section.orthogonalScrollingBehavior = .paging
            }
            ///横向group的布局
            else if(model.type == .group){
                let leftLargeItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.7), heightDimension: .fractionalHeight(1)))
                leftLargeItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                
                ///宽度是rightGroup的1 高度是rightGroup的0.3倍
                let rightLittleItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3)))
                rightLittleItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
                ///右边两个设置成一组 竖直布局 高度是containerGroup的比例1  宽度是containerGroup的0.3
                let rightGroup = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1)), subitem: rightLittleItem, count: 2)
                ///在把左边largeItem和右边的group组成一个组  宽度是屏幕的0.8  高度是屏幕的0.4
                let containerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(0.4)), subitems: [leftLargeItem, rightGroup])
                containerGroup.contentInsets = .init(top: 15, leading: 0, bottom: 0, trailing: 0)
                section = NSCollectionLayoutSection(group: containerGroup)
                section.boundarySupplementaryItems = [self.sectionHeaderSupplementaryItem()]
                section.orthogonalScrollingBehavior = .groupPaging
            }
            ///竖直list列表的布局
            else{
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)))
                item.contentInsets = .init(top: 10, leading: 15, bottom: 10, trailing: 15)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)), subitems: [item])
                group.contentInsets = .init(top: 55, leading: 0, bottom: 0, trailing: 0)
                section = NSCollectionLayoutSection(group: group)
                
                section.boundarySupplementaryItems = [self.sectionHeaderSupplementaryItem()]
                section.orthogonalScrollingBehavior = .none
            }
            ///设置是左右滚动还是上线滚
//            section.orthogonalScrollingBehavior = sectionKind.scrollBehavior()
            return section
        }, configuration: config)
        
        return layout
    }
    
    private func sectionHeaderSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem{
        ////estimated 自动估高
         let item = NSCollectionLayoutBoundarySupplementaryItem.init(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        ///如果用的estimated  contentInsets就无效了 ontentInsets are ignored for any axis with an .estimated dimension
//        item.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        return item
    }
    
    
    private func bindCollectionViewDataSources(){
        viewModel.processDataSources()
        dataSources = UICollectionViewDiffableDataSource<LBCollectionCompositionLayoutSectionModel, LBCollectionCompositionLayoutItemModel>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            let model = self.viewModel.dataSources[indexPath.section]
            switch model.type{
            case .banner:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBCollectionCompositionLayoutBannerCell.blt_className, for: indexPath) as? LBCollectionCompositionLayoutBannerCell else { return UICollectionViewCell() }
                    cell.imageView.image = UIImage(named: model.list?[indexPath.row].imageName ?? "")
                    return cell
            case .group:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBCollectionCompositionLayoutTextCell.blt_className, for: indexPath) as? LBCollectionCompositionLayoutTextCell else{
                    return UICollectionViewCell()
                }
                cell.contentView.backgroundColor = UIColor(red: 100.0 / 255.0, green: 149.0 / 255.0, blue: 237.0 / 255.0, alpha: 1.0)
                cell.contentView.layer.borderColor = UIColor.black.cgColor
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.cornerRadius = 8
                cell.titleLab.textAlignment = .center
                cell.titleLab.text = model.list?[indexPath.row].listText
                return cell
            case .list:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBCollectionCompositionLayoutListCell.blt_className, for: indexPath) as? LBCollectionCompositionLayoutListCell else{
                    return UICollectionViewCell()
                }
                cell.titleLab.text = model.list?[indexPath.row].listText
                return cell
            }
        })
        
        dataSources.supplementaryViewProvider = {
            (collectionView, kind, indexPath) -> UICollectionReusableView? in
//            guard kind == UICollectionView.elementKindSectionHeader else {
//                return nil
//            }
            print("LBLog supplementaryViewProvider \(indexPath.section) \(kind)");
            let model = self.viewModel.dataSources[indexPath.section]
            print("LBLog model name \(model.name) \(model.type)");
            if bltCheckStringIsEmpty(model.name) == false , let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BLTCollectionSectionHeaderTextView.blt_className, for: indexPath) as? BLTCollectionSectionHeaderTextView{
                header.titleLab.text = model.name
                return header
            }
            return nil
        }
        
        dataSources.apply(viewModel.snapshot)
    }
}


extension LBCollectionCompositionLayoutViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("LBLog collection view did clicked \(indexPath)")
    }
}
