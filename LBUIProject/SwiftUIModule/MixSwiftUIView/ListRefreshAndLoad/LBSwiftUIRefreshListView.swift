//
//  LBSwiftUIRefreshListView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/5/9.
//

import SwiftUI
import MJRefresh
//import SwiftUIPullToRefresh

struct LBSwiftUIRefreshListView: View {
    
//     let dataList: [ItemModel]
    @ObservedObject private var viewModel: LBSwiftUIRefreshListViewModel
    
    let refreshBlock: ((_ scrollView: UIScrollView) -> Void)?
    let loadMoreBlock: ((_ scrollView: UIScrollView) -> Void)?
    
    init(viewModel: LBSwiftUIRefreshListViewModel, refreshBlock: ((_ scrollView: UIScrollView) -> Void)?, loadMoreBlock: ((_ scrollView: UIScrollView) -> Void)?) {
        self.viewModel = viewModel
        self.refreshBlock = refreshBlock
        self.loadMoreBlock = loadMoreBlock
    }
    
    var body: some View {
        List {
            ForEach(viewModel.list) { item in
                
                Button(action: {
//                    viewModel.selectItem(item)
//                    viewModel.toggleSelection(at: viewModel.items.firstIndex(where: { $0.id == item.id}) ?? 0)
//                    item.isSelected.toggle()
                }) {
                    Text(item.name + "")
                       .foregroundColor(item.isSelected ? .red : .white)
                       .frame(maxWidth: .infinity, alignment: .leading)
                }
               .listRowBackground(Color.blue)
            }
        }
        .introspect(.list, on: .iOS(.v13, .v14, .v15)) {
            print(type(of: $0)) // UITableView
            addRefreshAndLoadMore($0)
        }
        .introspect(.list, on: .iOS(.v16, .v17, .v18)) {
            print(type(of: $0)) // UICollectionView
            addRefreshAndLoadMore($0)
        }
    }
    
    
    func addRefreshAndLoadMore(_ scrollView: UIScrollView) {
        scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            self.refreshBlock?(scrollView)
        })
        scrollView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: {
            self.loadMoreBlock?(scrollView)
        })
    }
    
}

struct LBSwiftUIRefreshListView22: View {
    
//     let dataList: [ItemModel]
    @ObservedObject private var viewModel: LBSwiftUIRefreshListViewModel
    
    let refreshBlock: ((_ scrollView: UIScrollView) -> Void)?
    let loadMoreBlock: ((_ scrollView: UIScrollView) -> Void)?
    
    init(viewModel: LBSwiftUIRefreshListViewModel, refreshBlock: ((_ scrollView: UIScrollView) -> Void)?, loadMoreBlock: ((_ scrollView: UIScrollView) -> Void)?) {
        self.viewModel = viewModel
        self.refreshBlock = refreshBlock
        self.loadMoreBlock = loadMoreBlock
    }
    
    var body: some View {
        List {
            ForEach(viewModel.list) { item in
                
                Button(action: {
//                    viewModel.selectItem(item)
//                    viewModel.toggleSelection(at: viewModel.items.firstIndex(where: { $0.id == item.id}) ?? 0)
//                    item.isSelected.toggle()
                }) {
                    Text(item.name + "")
                       .foregroundColor(item.isSelected ? .red : .white)
                       .frame(maxWidth: .infinity, alignment: .leading)
                }
               .listRowBackground(Color.blue)
            }
        }
        
    }
    

    
}

//#Preview {
//    LBSwiftUIRefreshListView()
//}
