//
//  LBAddUIKitViewPage.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/14.
//

import SwiftUI

// SwiftUI和UIKit桥梁搭建  SwiftUI包装器
struct LBAddUIKitViewPage: View {
    @State private var text: String = "123"
    
    @State private var textList = ["111", "222" , "333", "444"]
    
    var body: some View{
        VStack(content: {
            Text(text)
            /// 自定义UIKit空间中的加载
            LBUIKitGridView(selectText: $text, textList: textList) { text in
                print("LBLog print dd text \(text)")
                textList.append(text)
                print("LBLog print dd text \(textList)")
            }.frame(height: 200)
        }).frame(alignment: .top).background(Color.yellow)
    }
}


#Preview {
    LBAddUIKitViewPage()
}
