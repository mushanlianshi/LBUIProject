//
//  SwiftUIView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/8.
//

import SwiftUI

struct LBTestSwiftListView: View {
    let clickBlock: (() -> Void)
    let isLazyVStackOpen = false
    @State var isStartAnimating = false
    @State var startCountAnimating = 1
    @State var notificationsEnabled = false
    var dataSources = (0...80).map { "\($0)" }

    var body: some View {
        if #available(iOS 17.0, *) {
            testSFSombolsAnimating()
        } else {
            Text("低于iOS 17，请使用UIKit实现").font(.system(size: 16, weight: .medium)).foregroundColor(Color(.black))
        }
    }
    
    @available(iOS 17.0, *)
    func testSFSombolsAnimating() -> AnyView{
        return AnyView(
            ScrollView(content: {
                LazyVStack (alignment: .center){
                    Image(systemName:isStartAnimating ? "sun.max" : "cloud")
        //                .resizable()
        //                .aspectRatio(contentMode: .fit)
        //                .frame(width: 80, height: 80)
                        .font(.system(size: 80))
                        .background(Color(.systemGray2))
                        .contentTransition(.symbolEffect)
                        .onTapGesture{
                            isStartAnimating.toggle()
                            clickBlock()
                        }
                    Image(systemName: "basket")
                        .symbolEffect(
                        .bounce,
                        options: .repeat(3).speed(2),
                        value:startCountAnimating
                        ).font(.system(size: 50)).onTapGesture {
                            startCountAnimating += 1
                        }
                    Image(systemName: "basket")
                        .symbolVariant(
                            notificationsEnabled ? .none : .fill
                        )
                        .font(.system(size: 60))
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            notificationsEnabled.toggle()
                        }
                    
                    Image(systemName: "bell")
                        .symbolVariant(
                            notificationsEnabled ? .none : .fill
                        )
                        .font(.system(size: 60))
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            notificationsEnabled.toggle()
                        }
                    Image(systemName: "bell")
                        .symbolVariant(
                            notificationsEnabled ? .none : .slash
                        )
                        .font(.system(size: 60))
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            notificationsEnabled.toggle()
                            clickBlock()
                        }
                    Image(systemName: "bell")
                        .symbolVariant(
                            notificationsEnabled ? .none : .square
                        )
                        .font(.system(size: 60))
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            notificationsEnabled.toggle()
                            clickBlock()
                        }
                    Image(systemName: "bell")
                        .symbolVariant(
                            notificationsEnabled ? .none : .circle.fill
                        )
                        .font(.system(size: 60))
                        .contentTransition(.symbolEffect)
                        .onTapGesture {
                            notificationsEnabled.toggle()
                            clickBlock()
                        }
                }.background(Color(.blue.withAlphaComponent(0.15)))
            })
        )
    }
    
    func testListView() -> AnyView {
        if isLazyVStackOpen {
            return AnyView(
                ScrollView {
                    LazyVStack(spacing: 0){
                        ForEach(dataSources, id: \.self) { item in
                            Text(item)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 50)
                                .background(Color(.systemGray6))
                        }
                    }
                }
            )
        }else{
            return AnyView(List(dataSources, id: \.self) { item in
                Text(item)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 50)
                    .listRowBackground(Color(.systemGray6))
                    .listRowInsets(EdgeInsets())
                    .onAppear { debugPrint("LBLog List is \(item)") }
            }.listStyle(.plain).background(Color(.blue.withAlphaComponent(0.2))))
        }
    }
    
}

#Preview {
    debugPrint("LBLog preview swiftUI2")
    return LBTestSwiftListView {
        debugPrint("LBLog item clicked --------")
    }
}
