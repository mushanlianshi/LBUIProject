//
//  LBCardView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import SwiftUI


struct LBCardView< Content: View>: View {
    var content: () -> Content
    var cornerRaduis: CGFloat = 5
    var backgrounColor = Color.white
    
    init(cornerRaduis: CGFloat = 5, backgroudColor: Color = .white, @ViewBuilder content: @escaping () -> Content) {
        self.cornerRaduis = cornerRaduis
        self.backgrounColor = backgroudColor
        self.content = content
    }
    
    var body: some View {
        content().cornerRadius(cornerRaduis).background(backgrounColor)
    }
}

#Preview {
    LBCardView {
        Text("jajja")
    }
}
