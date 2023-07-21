//
//  LBChartView.swift
//  LBSwiftUIDemo2023
//
//  Created by liu bin on 2023/5/17.
//

import SwiftUI

#if DEBUG
//LB DEBUG TEST
///SwiftUI的实时预览
struct LBChartView_preView: PreviewProvider {
    static var previews: some View{
        LBChartView()
    }
}
#endif

///http://it.wonhero.com/itdoc/Post/2023/0301/87B20B84428BC57C Charts demo
struct LBChartView: View{
    

    var body: some View{
        NavigationView {
            if #available(iOS 14.0, *) {
                TabView {
                    LBChartMutiCurveMarkView()
                        .tabItem {
                            Image(systemName: "1.circle")
                            Text("对比曲线图")
                        }
                    
                    LBChartLineMarkView()
                        .tabItem {
                            Image(systemName: "2.circle")
                            Text("折线图")
                        }
                    
                    LBChartBarMarkView()
                        .tabItem {
                            Image(systemName: "3.circle")
                            Text("柱状对比图")
                        }
                }.navigationTitle("Chart图表222")
            } else {
                // Fallback on earlier versions
            }
        }
        
    }
    
}
