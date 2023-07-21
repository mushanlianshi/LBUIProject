//
//  LBChartTabView.swift
//  LBSwiftUIDemo2023
//
//  Created by liu bin on 2023/5/17.
//

import SwiftUI

struct LBChartTabView: View {
    var body: some View {
        TabView {
            LBChartView()
            .tabItem {
                Image(systemName: "1.circle")
                Text("Chart图")
            }
            
            Text("Second Tab")
                .tabItem {
                    Image(systemName: "2.circle")
                    Text("Second")
                }
            
            Text("Third Tab")
                .tabItem {
                    Image(systemName: "3.circle")
                    Text("Third")
                }
        }
    }
}
