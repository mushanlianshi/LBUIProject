//
//  LBScrollKitHomeView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/20.
//

import SwiftUI
import DSScrollKit
///Function declares an opaque return type 'some View', but the return statements in its body do not have matching underlying types
///https://developer.apple.com/forums/thread/118172
struct LBScrollKitHomeView: View {
    
    var body: some View {
        addListWithSwiftUINavigation(false)
    }
    
    ///如果是UIKit有UINavigationController了  就不需要包NavigationView了  如果不是需要包NavigationView 来实现跳转
    ///来使用ViewBuilder来代替结果生成器  不然返回some View时不同的类型编译失败 报错： Function declares an opaque return type 'some View', but the return statements in its body do not have matching underlying types
    ///https://developer.apple.com/forums/thread/118172
    ///https://geek-docs.com/swift/swift-tutorials/t_what-is-the-some-keyword-in-swiftui.html
    /// 用ViewBuilder不能用guard
    @ViewBuilder
    func addListWithSwiftUINavigation(_ useSwiftUINavigation: Bool) -> some View{
        if useSwiftUINavigation {
            NavigationView {
                contentV()
            }
        }else{
            contentV()
        }
    }
    
    func contentV() -> some View{
        List {
            linkSection
            spotifySection
        }
        .navigationTitle("ScrollKit")
        .tint(.white)
    }
    
    
    
}


private extension LBScrollKitHomeView{
    var linkSection: some View{
        Section(header: Text("Sticky Headers")) {
            imageLink
            gradientLink
            colorLink
        }
    }
    
    @available(iOS 15.0, *)
    var spotifySection: some View{
        Section(header: Text("Spotify Headers"), footer: Text("Spotify Footer")) {
            spotifyLink(.anthrax)
            spotifyLink(.misfortune)
            spotifyLink(.regina)
        }
    }
}

private extension LBScrollKitHomeView{
    ///图片类型的view
    var imageLink: some View {
        linkView("photo.fill", "Image") {
            LBScrollListView(headerHeight: 250) {
                ZStack {
                   ScrollViewHeaderImage(Image("scale_header_image"))
                    ScrollViewHeaderGradient(.black.opacity(0.2), .black.opacity(0.5))
                }
            }
        }
    }
    
    
    ///渐变类型的view
    var gradientLink: some View{
        linkView("paintbrush.fill", "Gradient") {
            LBScrollListView(headerHeight: 250) {
                ScrollViewHeaderGradient(.yellow, .blue)
            }
        }
    }
    
    var colorLink: some View{
        linkView("paintbrush.pointed.fill", "Color") {
            LBScrollListView(headerHeight: 100) {
                Color.blue
            }
        }
    }
    
    @available(iOS 15.0, *)
    func spotifyLink(_ info: SpotifyPreviewInfo) -> some View{
        linkView("record.circle.fill", "Spotify - \(info.bandName)") {
            SpotifyPreviewScreen(info: info)
        }
    }
        
    
    ///返回一个点击跳转的view
    func linkView<Destination: View>(_ iconName: String, _ title: String, to destination: () -> Destination) -> some View{
        NavigationLink(destination: destination) {
            Label(title, systemImage: iconName)
        }
    }
}

struct LBScrollKitHomeView_Previews: PreviewProvider {
    static var previews: some View {
        LBScrollKitHomeView()
    }
}
