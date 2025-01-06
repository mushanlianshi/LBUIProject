//
//  LBIGListKitDecorationViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/9/6.
//

import UIKit
import IGListKit


final class LBIGListKitDecorationViewController: UIViewController, ListAdapterDataSource, UITableViewDelegate {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = LBDecorationSectionBackgroundLayout()
//        let layout = UICollectionViewFlowLayout()
        layout.decorationDelegate = self
        /// 装饰图的要指定高，不能autolayout的
//        layout.itemSize = .init(width: BLT_SCREEN_WIDTH, height: 50)
        layout.estimatedItemSize = CGSize(width: 100, height: 40)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(red: 0.831_372_549, green: 0.945_098_039, blue: 0.964_705_882, alpha: 1)
        
        return collectionView
    }()

    let data = [
        SelectionModel(options: ["Leverage agile", "frameworks", "robust synopsis", "high level", "overviews",
                                 "Iterative approaches", "corporate strategy", "foster collaborative",
                                 "overall value", "proposition", "Organically grow", "holistic world view",
                                 "disruptive", "innovation", "workplace diversity", "empowerment"]),
        SelectionModel(options: ["Bring to the table", "win-win", "survival", "strategies", "proactive domination",
                                 "At the end of the day", "going forward", "a new normal", "evolved", "generation X",
                                 "runway heading", "streamlined", "cloud solution", "User generated", "content",
                                 "in real-time", "multiple touchpoints", "offshoring"], type: .nib),
        SelectionModel(options: ["Aenean lacinia bibendum nulla sed consectetur. Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras mattis consectetur purus sit amet fermentum.",
                                 "Donec sed odio dui. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed posuere consectetur est at lobortis. Cras justo odio, dapibus ac facilisis in, egestas eget quam.",
                                 "Sed posuere consectetur est at lobortis. Nullam quis risus eget urna mollis ornare vel eu leo. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum."], type: .fullWidth)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        adapter.collectionView = collectionView
        adapter.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

    // MARK: ListAdapterDataSource

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return data as [ListDiffable]
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return SelfSizingSectionController()
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? { return nil }

}


extension LBIGListKitDecorationViewController: LBDecorationSectionBackgroundLayoutDelegate{
    
    func customBackgroundDecorationConfig(_ section: Int) -> LBCustomSectionBackgroundDecorationConfig? {
        let color: UIColor = section == 1 ? UIColor.red.withAlphaComponent(0.4) : UIColor.blue.withAlphaComponent(0.4)
        let cornerRadius = section == 1 ? 15.0 : 8.0
        return LBCustomSectionBackgroundDecorationConfig.init(backgroundColor: color, layerCornerRadius: cornerRadius, backgroundColorInset: .zero)
    }
    
}
