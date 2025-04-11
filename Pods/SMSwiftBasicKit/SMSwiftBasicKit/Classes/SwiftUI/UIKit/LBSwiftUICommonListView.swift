//
//  LBSwiftUICommonListView.swift
//  MobileHotel
//
//  Created by liu bin on 2025/2/10.
//  Copyright © 2025 ethank. All rights reserved.
//

import SwiftUI

/// 封装一个通用的listView来处理iOS13和14分割线 隐藏方式不同的
// 通用 List 组件
public struct LBSwiftUICommonListView<Model: Hashable, Content: View>: View {
    public var items: [Model]
    public var content: (Model) -> Content
    
    public init(items: [Model], @ViewBuilder content: @escaping (Model) -> Content) {
        self.items = items
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 14.0, *) {
            ScrollView {
                LazyVStack(spacing: 0){
                    ForEach(items, id: \.self) { item in
                        content(item)
                    }
                }
            }
        } else {
            List(items, id: \.self) { item in
                content(item)
            }.listRowInsets(EdgeInsets())
            .modifier(LBNoneSeparator()) // 去除分割线
        }
    }
}

#Preview {
    LBSwiftUICommonListView(items: [String]()) { model in
        
    }
}
