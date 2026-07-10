//
//  LBCombineSampleListViewModel.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/4/2.
//

import Foundation

class LBCombineSampleListViewModel: ObservableObject {
    // 注册一个发布者
    @Published var dataSources: [LBListItemModel] = []
    
    func loadData() {
        dataSources.append(contentsOf: [
            LBListItemModel.init(title: "登录页面combine", vcClass: LBLoginCombineController.self),
            LBListItemModel.init(title: "搜索发出粒子的间隔", vcClass: LBSearchCombineController.self),
            LBListItemModel.init(title: "绑定UI", vcClass: LBCombineBindController.self),
            LBListItemModel.init(title: "自定义模型属性绑定", vcClass: LBCustomPropertyCombineController.self),
            LBListItemModel.init(title: "输入框联动按钮、请求等", vcClass: LBSearchAndRequestBindCombineController.self)
        ])
    }
}
