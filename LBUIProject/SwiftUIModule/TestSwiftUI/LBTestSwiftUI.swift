//
//  LBTestSwiftUI.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/20.
//

import SwiftUI

struct LBTestSwiftUI: View {
    
    var body: some View {
        Text("Hello, World!")
    }
    
    //会报错 返回不同的类型
//    func createView() -> some View {
//        if true {
//            return Text("Condition is true") // This return statement has a type of Text
//        } else {
//            return Image("placeholder") // This return statement has a type of Image
//        }
//    }
    
    ///用AnyView来处理
    func createView() -> some View {
        if true {
            return AnyView(Text("Condition is true")) // This return statement has a type of Text
        } else {
            return AnyView(Image("placeholder")) // This return statement has a type of Image
        }
    }
    
    @ViewBuilder
    var body22: some View {
        let type = LBSwiftUIExampleType.chart
        switch type {
        case .ScrollKit:
            Text("Condition is true")
        default:
            Image("placeholder")
        }
    }
    
    @ViewBuilder
    var body33: some View {
        let type = LBSwiftUIExampleType.chart
        if type == .ScrollKit {
            Text("Condition is true")
        }
        Image("placeholder")
    }
    
}

struct LBTestSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        LBTestSwiftUI()
    }
}


enum ImageSessions {
    static let gallery: URLSession = {
        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024,
            diskCapacity: 100 * 1024 * 1024
        )
        config.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: config)
    }()
}

struct ImageGallery: View {
    let imageURLs: [URL]

    var body: some View {
        ScrollView {
            AsyncImage(url: imageURLs.first ?? nil, content: {
                image in
                image.resizable()
            }, placeholder: {
                
            })
            
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 120))
                ]
            ) {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 120)
                    .clipShape(.rect(cornerRadius: 16))
                }
            }
        }
    }
}
