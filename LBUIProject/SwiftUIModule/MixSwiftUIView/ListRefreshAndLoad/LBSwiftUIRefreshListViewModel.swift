//
//  LBSwiftUIRefreshListViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2025/5/9.
//

import SwiftUI

class LBSwiftUIRefreshListViewModel: ObservableObject{
    
    @Published var list = [ItemModel]()
    
    
    func refreshData(successBlock: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            [weak self] in
            self?.list.removeAll()
            self?.addTenData()
            successBlock?()
        })
    }
    
    func loadMoreData(successBlock: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            [weak self] in
            self?.addTenData()
            successBlock?()
        })
    }
    
    func addTenData() {
        let count = list.count
        for index in count..<count + 10{
            let item = ItemModel.init(name: "title \(index)", isSelected: false)
            list.append(item)
        }
        print("LBLog list is \(list)")
    }
}
