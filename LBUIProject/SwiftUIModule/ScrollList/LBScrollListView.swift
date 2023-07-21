//
//  LBScrollListView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/20.
//

import SwiftUI
import DSScrollKit

struct LBScrollListTestModel {
    var age = 0
    var title = "Demo Title"
}


///有参数的用方法func   没参数的用属性var来构造view
struct LBScrollListView<HeaderView: View>: View {
    
    let headerHeight: CGFloat
    
    @ViewBuilder
    let headerView: () -> HeaderView
    
    ///@State 修饰表示值变了之后会更新UI
    @State
    private var headerVisibleRatio: CGFloat = 1
    
    @State
    private var scrollOffset: CGPoint = .zero
    
    @State
    private var detailModel = LBScrollListTestModel()
    @State
    private var testChangeText = "Some additional information"
    
    
    var body: some View {
        return ScrollViewWithStickyHeader(
            header: stickyHeaderView,
            headerHeight: headerHeight,
            onScroll: handleScrollOffset) {
                listItemViews
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Demo Titleeee")
                        .font(.headline)
                        .previewHeaderContent()
                        .opacity(1 - headerVisibleRatio)
                }
            }
            .statusBarHidden(scrollOffset.y > -3.0)
//            .toolbarBackground(.hidden)
//            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear{
                print("LBLog on Appear ==========")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    print("LBLog on Appear asyncAfter ==========")
                    detailModel.title = "Demo Title Changed ----------"
//                    testChangeText = "Some additional information changed ===="
                })
            }
    }
    
    
    private func stickyHeaderView() -> some View{
        ZStack (alignment: .bottomLeading){
            headerView()
            ScrollViewHeaderGradient()
            headerTitle.previewHeaderContent()
        }
    }
    
    private var headerTitle: some View{
        VStack(alignment: .leading, spacing: 5) {
            Text(detailModel.title).font(.largeTitle)
            Text(testChangeText)
        }
        .padding(20)
        .opacity(headerVisibleRatio)
    }
    
    ///LazyVStack 使用懒加载  避免一次性创建所有view  懒加载只有到屏幕中才会创建
    private var listItemViews: some View{
        LazyVStack(spacing: 5) {
            ForEach(1...100, id: \.self) { item in
                VStack(spacing: 0) {
                    Text("Item \(item)")
                        .padding()
                        .frame( maxWidth: .infinity, alignment: .leading)
                    Divider()
                }
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGPoint, headerVisibleRatio: CGFloat){
        self.scrollOffset = offset
        self.headerVisibleRatio = headerVisibleRatio
        
        print("LBLog headerVisibleRatio \(headerVisibleRatio) \(self.scrollOffset.y)")
    }
}



extension View{
    func previewHeaderContent() -> some View{
        self.foregroundColor(.white).shadow(color: .black.opacity(0.4), radius: 1, x: 1, y: 1)
    }
}

struct LBScrollListView_Previews: PreviewProvider {
    static var previews: some View {
        LBScrollListView(headerHeight: 250) {
            ZStack {
               ScrollViewHeaderImage(Image("scale_header_image"))
                ScrollViewHeaderGradient(.black.opacity(0.2), .black.opacity(0.5))
            }
        }
    }
}
