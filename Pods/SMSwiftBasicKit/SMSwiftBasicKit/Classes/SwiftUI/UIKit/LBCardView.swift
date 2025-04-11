//
//  LBCardView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import SwiftUI

/// 一个有圆角、 背景色、卡片样式的View
public struct LBCardView< Content: View>: View {
    public var content: () -> Content
    public var cornerRaduis: CGFloat = 5
    public var backgrounColor = Color.white
    
    public init(cornerRaduis: CGFloat = 5, backgroudColor: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRaduis = cornerRaduis
        self.backgrounColor = backgroudColor
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            content()
        }).background(RoundedRectangle(cornerRadius: cornerRaduis)
            .foregroundColor(backgrounColor))
    }
}

#Preview {
    LBCardView(cornerRaduis: 5, backgroudColor: .red) {
        Text("jajjadd").padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
    }
}
