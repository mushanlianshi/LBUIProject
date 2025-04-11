//
//  LBGridView.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/2/11.
//

import SwiftUI

/// 自定义gridView, 支持iOS 13
public struct LBGridView<Model: Hashable, Content: View>: View {
    public var items:[Model]
    /// 一个block，根据传的item返回一个view
    public var content: (Model) -> Content
    public var column = 3
    public var columnSpacing: Double = 10
    public var rowSpacing: Double = 10
    
    public init(items: [Model], column: Int = 3, columnSpacing: Double = 10, rowSpacing : Double = 10, content: @escaping (Model) -> Content) {
        self.items = items
        self.column = column
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        self.content = content
        
    }
    public var body: some View {
        return gridView13()
//        if #available(iOS 14.0, *) {
//            gridView14()
//        } else {
//            gridView13()
//        }
    }
    
    /// iOS14实现
    @available(iOS 14.0, *)
    func gridView14() -> some View{
        GeometryReader(content: { geometry in
            let width = geometry.size.width
            let itemWidth = caculateItemWidth(width)
            let list = 1...column
            let gridList = list.map({_ in GridItem(.fixed(itemWidth), spacing: columnSpacing)})
            
            ScrollView {
                LazyVGrid(columns: gridList, alignment: .leading, spacing: rowSpacing, content: {
                    ForEach(items, id: \.self) { item in
                        self.content(item)
                    }
                }).padding(0)
            }.frame(maxHeight: .infinity)
        })
        
    }
    
    @available(iOS 14.0, *)
    var gridList:[GridItem]{
        let list = 1...column
        return list.map({_ in GridItem(.flexible(), spacing: columnSpacing)})
    }
    
    /// iOS13上实现
    func gridView13() -> some View{
        let rowCount = (items.count - 1) / column + 1
        return VStack(spacing: 10) {
            ForEach(Array(0..<rowCount), id: \.self) { row in
                HStack(spacing: columnSpacing) {
                    ForEach(Array(0..<column), id: \.self) { col in
                        let index = row * column + col
                        if index < items.count {
                            self.content(items[index])
                        }
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.padding(0)
    }
        
        func caculateItemWidth(_ superWidth: Double) -> Double {
            let contentW = superWidth - columnSpacing * (Double(column) - 1.0)
            return contentW / Double(column)
        }
        
    }
    
    #Preview {
        LBGridView(items: (1...10).map({index in NSString(format: "index \(index)" as NSString)})) { item in
            Text("item bbackding \(item)").background(Color.red)
        }
    }
