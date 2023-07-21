//
//  LBCollectionCompositionLayoutViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/13.
//

import Foundation

enum LBCollectionCompositionLayoutSectionType {
    case banner, group, list
    
}

struct LBCollectionCompositionLayoutViewModel {
    var snapshot = NSDiffableDataSourceSnapshot<LBCollectionCompositionLayoutSectionModel, LBCollectionCompositionLayoutItemModel>()
    var dataSources = [LBCollectionCompositionLayoutSectionModel]()
    
    mutating func processDataSources() {
        let banner = LBCollectionCompositionLayoutSectionModel.init(type: .banner, list: [
            "pageView1", "pageView2", "pageView3", "pageView4","pageView5"
        ].map{LBCollectionCompositionLayoutItemModel.init(imageName: $0)})
        
        let group = LBCollectionCompositionLayoutSectionModel.init(type: .group, list: [
            "11", "22", "33", "44", "55", "66", "77", "88"
        ].map{LBCollectionCompositionLayoutItemModel.init(listText: $0)}, name: "hori group")
        
        let list = LBCollectionCompositionLayoutSectionModel.init(type: .list, list: [
            "6. Xcode has removed the build logs. Edit a file and re-run.",
            "5. The source file is an XCTest that has not been run yet.",
            "4. The modified source file is not in the current project.4. The modified source file is not in the current project.",
            "3. File paths in the simulator are case sensitive.3. File paths in the simulator are case sensitive.3. File paths in the simulator are case sensitive.",
            "2. There are restrictions on characters allowed in paths.",
            "1. Injection does not work with Whole Module Optimization."
        ].map{LBCollectionCompositionLayoutItemModel.init(listText: $0)}, name: "1. Injection does not work with Whole Module Optimization.1. Injection does not work with Whole Module Optimization.1. Injection does not work with Whole Module Optimization.")
        dataSources.append(contentsOf: [banner, group, list])
        
        dataSources.forEach { model in
            snapshot.appendSections([model])
            snapshot.appendItems(model.list ?? [LBCollectionCompositionLayoutItemModel]())
        }
    }
    
}


struct LBCollectionCompositionLayoutSectionModel: Hashable {
    var type: LBCollectionCompositionLayoutSectionType = .list
    var list: [LBCollectionCompositionLayoutItemModel]?
    var name: String?
}


struct LBCollectionCompositionLayoutItemModel: Hashable {
    var listText: String?
    var imageName: String?
}
