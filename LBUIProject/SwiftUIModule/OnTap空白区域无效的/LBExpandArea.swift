//
//  LBExpandArea.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/11.
//

import SwiftUI


///处理onTapGesture 点击空白区域无效的   自定义扩展onTapExpandArea
private struct ExpandAreaTap: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.white)
                .contentShape(Rectangle())
            content
        }
    }
}

extension View {
    public func onTapExpandArea(tap: @escaping () -> ()) -> some View {
        self.modifier(ExpandAreaTap()).onTapGesture(perform: tap)
    }
}
