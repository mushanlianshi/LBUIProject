//
//  LBNoneSeparator.swift
//  MobileHotel
//
//  Created by liu bin on 2025/2/10.
//  Copyright © 2025 ethank. All rights reserved.
//

import SwiftUI

// 自定义修饰符去掉分割线
public struct LBNoneSeparator: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .onAppear {
                UITableView.appearance().separatorStyle = .none
            }
            .onDisappear {
                UITableView.appearance().separatorStyle = .singleLine
            }
    }
}
