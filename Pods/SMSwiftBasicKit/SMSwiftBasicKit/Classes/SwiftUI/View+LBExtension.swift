//
//  View+LBExtension.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/3/17.
//

import Foundation
import SwiftUI


extension View{
    public func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment, content: {
            if shouldShow {
                placeholder()
            }
            self
        }).padding(.horizontal, 0)
    }
}
