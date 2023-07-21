//
//  LBChartMutiCurveMarkView.swift
//  LBSwiftUIDemo2023
//
//  Created by liu bin on 2023/5/17.
//

import SwiftUI
import Charts

struct YellowGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .padding(.top, 30)
            .padding(20)
            .background(Color(hue: 0.10, saturation: 0.10, brightness: 0.98))
            .cornerRadius(20)
            .overlay(
                configuration.label.padding(10),
                alignment: .topLeading
            )
//            .labelStyle(.automatic)
    }
}

///http://it.wonhero.com/itdoc/Post/2023/0301/87B20B84428BC57C Charts demo
//多条曲线的
struct LBChartMutiCurveMarkView: View {
    var people: LBPeople = .liubin
    ///蛋糕的数据模型列表
    let liubinData: [LBWeightModel] = [
        .init(month: 1, weight: 130),
        .init(month: 2, weight: 138),
        .init(month: 3, weight: 135),
        .init(month: 4, weight: 132),
        .init(month: 5, weight: 134),
        .init(month: 6, weight: 137),
        .init(month: 7, weight: 136),
    ]
    
    let keleiData: [LBWeightModel] = [
        .init(month: 1, weight: 105),
        .init(month: 2, weight: 108),
        .init(month: 3, weight: 102),
        .init(month: 4, weight: 115),
        .init(month: 5, weight: 104),
        .init(month: 6, weight: 106),
        .init(month: 7, weight: 105),
    ]
    
    var seriesData: [(people: String, data: [LBWeightModel])] {
        [
            (people: "liubin", data: liubinData),
            (people: "kelei", data: keleiData),
        ]
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                GroupBox("体重变化对比图") {
                    Chart{
                        ForEach(seriesData, id: \.people) { series in
                            ForEach(series.data, id: \.month) { data in
                                LineMark(x: .value("month", data.month),
                                         y: .value("weight", Int(data.weight))
                                )
                                ///按人分颜色
                                .foregroundStyle(by: .value("people", series.people))
                                ///曲线图
                                .interpolationMethod(.catmullRom)
                                ///展示点
                                .symbol(by: .value("people", series.people))
                                ///点的大小
                                .symbolSize(30)
                                .symbol {
                                    
                                }
                            }
                        }
                    }.chartYAxis {
                        AxisMarks(position: .leading, values:.stride(by: 60))
                    }
                    ///标注分类 的位置  默认在左下角 设置成overlay图上面  右上角
                    .chartLegend(position: .overlay, alignment: .topTrailing)
                    ///chart图展示区域的背景色
                    .chartPlotStyle { plotArea in
                        plotArea.background(Color(hue: 0.12, saturation: 0.10, brightness: 0.92))
                    }
                    ///设置线条的颜色
                    .chartForegroundStyleScale(
                        [
                            "liubin" : .red,
                            "kelei" : .green
                        ]
                    )
                }
                .frame(height: 300)
//                .background(Color(hue: 0.10, saturation: 0.10, brightness: 0.98))
                .groupBoxStyle(YellowGroupBoxStyle())
            
//                .onTapGesture {
//                    print("-----")
//                }
                Spacer()
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct LBChartMutiCurveMarkView_Previews: PreviewProvider {
    static var previews: some View {
        LBChartMutiCurveMarkView()
    }
}
