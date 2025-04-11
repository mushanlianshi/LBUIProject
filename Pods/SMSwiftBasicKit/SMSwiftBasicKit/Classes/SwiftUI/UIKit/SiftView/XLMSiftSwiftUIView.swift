//
//  XLMSiftSwiftUIView.swift
//  MobileHotel
//
//  Created by liu bin on 2025/2/10.
//  Copyright © 2025 ethank. All rights reserved.
//

import SwiftUI

/// 筛选控件
public struct XLMSiftSwiftUIView: View {
    
    public let list: [XLMSiftItemModel]
    
    public let selectBlock: ((_ itemModel: XLMSiftItemModel, _ index: Int) -> Void)
    
    let itemH: CGFloat
    
    public let dismissBlock: (() -> Void)?
    
    
    
    public init(list: [XLMSiftItemModel], itemH: CGFloat = 40.0, selectBlock: @escaping ((_ itemModel: XLMSiftItemModel, _ index: Int) -> Void), dismissBlock: (() -> Void)?) {
        self.list = list
        self.itemH = itemH
        self.selectBlock = selectBlock
        self.dismissBlock = dismissBlock
    }
    
    public var body: some View {
        // 使用GeometryReader来读取父控件的高度
        GeometryReader(content: { geometry in
            return ZStack(alignment:.top){
                Color(UIColor.black.withAlphaComponent(0.35)).onTapGesture {
                    dismissBlock?()
                }
                listView().background(Color(UIColor.white))
                /// 设置list的高度最大为控件的0.65倍 maxHeight无效
                    .frame(height: min(geometry.size.height * 0.65, itemH * Double(list.count)))
            }
        })
    }
    
    
    
    private func listView() -> some View{
        return LBSwiftUICommonListView(items: list) { item in
            Text(item.title)
                .foregroundColor(item.selected ? Color(UIColor.blt.ffRedColor()) : Color(UIColor.blt.threeThreeBlackColor()))
                .font(Font(UIFont.blt.normalFont(14)))
                .frame(height: itemH,alignment: .center)
            /// 设置响应区域不只是点击文字，点击空白处也响应
                .onTapExpandArea {
                    selectBlock(item, list.firstIndex(of: item) ?? 0)
                }.padding(0)
        }.background(Color(UIColor.white)).listStyle(PlainListStyle()) // 使用 PlainListStyle 去掉默认的外间距
    }
}

#Preview {
    XLMSiftSwiftUIView(list: []) { item, index in
        
    } dismissBlock: {
        
    }

}
