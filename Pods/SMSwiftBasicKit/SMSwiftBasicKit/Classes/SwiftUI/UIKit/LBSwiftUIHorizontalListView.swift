//
//  LBSwiftUIHorizontalListView.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/3/17.
//

import SwiftUI

/// 横线滚动的view
public struct LBSwiftUIHorizontalListView<Model: Hashable, Content: View>: View {
    public let spacing: CGFloat?
    public var items: [Model]
    public var content: (Model) -> Content
    
    public init(spacing: CGFloat? = nil,items: [Model], @ViewBuilder content: @escaping (Model) -> Content) {
        self.items = items
        self.content = content
        self.spacing = spacing
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            if #available(iOS 14.0, *) {
                LazyHStack(spacing:spacing, content: {
                    ForEach(items, id: \.self) { model in
                        content(model)
                    }
                })
            } else {
                HStack(spacing:spacing, content: {
                    ForEach(items, id: \.self) { model in
                        content(model)
                    }
                })
            }
        }
    }
}

#Preview {
    LBSwiftUIHorizontalListView(spacing: 10, items: ["123", "321", "ewfwe", "wefwef"]) { text in
        Text(text).foregroundColor(.white).fixedSize(horizontal: true, vertical: false).background(Color.blue)
    }
}
