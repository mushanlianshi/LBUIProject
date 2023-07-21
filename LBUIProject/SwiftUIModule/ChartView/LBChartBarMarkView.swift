//
//  LBChartBarView.swift
//  LBSwiftUIDemo2023
//
//  Created by liu bin on 2023/5/17.
//

import SwiftUI
import Charts

///蛋糕模型
struct LBCakeProduct: Identifiable {
    ///种类的名称
    let name: String
    ///销售的数量
    let salesCount: Int
    ///Identifiable 的id 以name为唯一标识
    var id: String { name }
}

///柱状对比图
struct LBChartBarMarkView: View {
    var people: LBPeople = .liubin
    ///蛋糕的数据模型列表
    private let liubinList: [LBCakeProduct] = [
        .init(name: "红丝绒", salesCount: 985),
        .init(name: "慕斯", salesCount: 755),
        .init(name: "巧克力", salesCount: 645),
        .init(name: "冰淇淋", salesCount: 185),
        .init(name: "水果", salesCount: 485),
        .init(name: "生日", salesCount: 885),
    ]
    
    private let keleiList: [LBCakeProduct] = [
        .init(name: "红丝绒", salesCount: 585),
        .init(name: "慕斯", salesCount: 785),
        .init(name: "巧克力", salesCount: 445),
        .init(name: "冰淇淋", salesCount: 685),
        .init(name: "水果", salesCount: 585),
        .init(name: "生日", salesCount: 785),
    ]
    
    var seriesData: [(people: String, data: [LBCakeProduct])] {
        [
            (people: "liubin", data: liubinList),
            (people: "kelei", data: keleiList),
        ]
    }
    
    
    ///第一种写法
    @available(iOS 16.0, *)
    func methodOne() -> some ChartContent {
        ForEach(seriesData, id: \.people) { series in
            ForEach(series.data, id: \.id) { list in
                BarMark(x: .value("name", list.name),
                        y: .value("count", list.salesCount)
                )
                ///按people分成两组颜色
                .foregroundStyle(by: .value("people", series.people))
                //                        .foregroundStyle(.red)
                ///分成两组
                .position(by: .value("people", series.people))
                
            }
        }
    }
    
    ///第二种写法
//    @available(iOS 16.0, *)
//    func methodTwo() -> some ChartContent {
//        ForEach(liubinList, id: \.id) { list in
//            BarMark(x: .value("name", list.name),
//                    y: .value("count", list.salesCount)
//            )
//            .foregroundStyle(.red)
//        }
//
//        ForEach(keleiList, id: \.id) { list in
//            BarMark(x: .value("name", list.name),
//                    y: .value("count", list.salesCount)
//            )
//            .foregroundStyle(.red)
//        }
//    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            Chart{
                
                ForEach(liubinList, id: \.id) { list in
                    BarMark(x: .value("name", list.name),
                            y: .value("count", list.salesCount)
                    )
//                    .foregroundStyle(.red)
                }
                .position(by: .value("people", "liubin"))
                .foregroundStyle(by: .value("name", "liubin"))
                
                ForEach(keleiList, id: \.id) { list in
                    BarMark(x: .value("name", list.name),
                            y: .value("count", list.salesCount)
                    )
//                    .foregroundStyle(.yellow)
//                    .foregroundStyle(by: .value("name", "kelei"))
                    .position(by: .value("people", "kelei"))
                }
                
            }
            .foregroundColor(.red)
            ///设置柱状图的颜色
            .chartForegroundStyleScale(
                [
                    "liubin" : .green,
                    "kelei" : .red
                ]
            )
        } else {
            // Fallback on earlier versions
        }
    }
}

///预览图片
struct LBChartBarView_Previews: PreviewProvider {
    static var previews: some View {
        LBChartBarMarkView()
    }
}
