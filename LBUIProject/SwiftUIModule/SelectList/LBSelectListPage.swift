//
//  LBSelectListPage.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/14.
//

import SwiftUI
//import SwiftUIIntrospect

// 定义数据模型类 这里要观察list里面这个模型的isSelected 这里只能用struct 不能用class
struct ItemModel: Identifiable {
    let id = UUID()
    var name: String
    var isSelected: Bool
    
    init(name: String, isSelected: Bool) {
        self.name = name
        self.isSelected = isSelected
    }
    
    mutating func changeName(_ newName: String) {
        self.name = newName
    }
}

// 定义 ViewModel
class ItemViewModel: ObservableObject {
    @Published var items: [ItemModel] = []
    
    init() {
        // 初始化 10 个模型
        for i in 0..<30 {
            items.append(ItemModel(name: "Item \(i)", isSelected: false))
        }
    }
    
    func selectItem(_ item: ItemModel) {
            for index in items.indices {
                items[index].isSelected = (items[index].id == item.id)
//                items[index].changeName(items[index].name + "\(index)")
            }
        }
    
    func toggleSelection(at index: Int) {
        items[index].isSelected.toggle()
        items[index].changeName(items[index].name + "\(index)")
    }
}

// 定义主视图
struct LBSelectListPage: View {
    @State var mobile = ""
    @ObservedObject var viewModel = ItemViewModel()
    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                Button(action: {
                    viewModel.selectItem(item)
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
    
    
    func testView() -> some View {
        ScrollView {
            Text("Item 1")
        }
//        .introspect(.scrollView, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { scrollView in
//            // do something with UIScrollView
//        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LBSelectListPage()
    }
}

