//
//  LBChartLineMarkView.swift
//  LBSwiftUIDemo2023
//
//  Created by liu bin on 2023/5/17.
//

import SwiftUI
import Charts

enum LBPeople {
    case liubin
    case kelei
}

///体重的模型
struct LBWeightModel: Identifiable {
    var month: Int
    var weight: CGFloat
    var id: Int { month }
}

///直线的ChartView
struct LBChartLineMarkView: View {
    ///@State 修饰 可以改变值 刷新界面
    @State var people: LBPeople = .liubin
    
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
    
    var dataList: [LBWeightModel]{
        switch people {
        case .liubin:
            return liubinData
        case .kelei:
            return keleiData
        }
    }
    
    let lineColor = Color(hue: 0.69, saturation: 0.19, brightness: 0.79)
    let curColor = Color(hue: 0.33, saturation: 0.81, brightness: 0.76)
    
    var body: some View {
        if #available(iOS 16.0, *) {
            VStack(alignment: .leading, spacing: 20){
                Picker("人", selection: $people.animation(.easeInOut)) {
                    Text("刘彬").tag(LBPeople.liubin)
                    Text("柯磊").tag(LBPeople.kelei)
                }.pickerStyle(.segmented).frame(height: 60).clipped()
                ///.clipped() 设置可以裁剪  不然设置高度太小  会无效
                
                Chart(dataList) { element in
                    LineMark(x: .value("month", element.month),
                             y: .value("weight", Int(element.weight))
                    )
                    ///折线的颜色
                    .foregroundStyle(lineColor)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(){
                        Circle().fill(.red).frame(width: 8 ,height: 8)
//                        Rectangle().fill(.red).frame(width: 8, height: 8)
                    }
                    .symbolSize(20)
                    
//                    .foregroundStyle(by: .value("month", 1))
//                    .accessibilityLabel(element.month)
//                    .accessibilityValue(element.weight)
                    
                    PointMark(x: .value("month", element.month),
                              y: .value("weight", Int(element.weight)))
                    .foregroundStyle(.red)
                    
                }.frame(height: 200)
                ///设置Y轴靠左
                .chartYAxis {
                    ///stride 设置步长的间隔
                    AxisMarks(position: .leading, values: .stride(by: 80))
                }// Set color for each data in the chart
                .chartXAxis(content: {
                    AxisMarks(position: .bottom, values: .stride(by: 2))
                })
                .chartForegroundStyleScale([
                    "month" : Color(hue: 0.33, saturation: 0.81, brightness: 0.76),
                    "kk": Color(hue: 0.69, saturation: 0.19, brightness: 0.79)
                ])
                ///chartBackground设置整个图片的背景颜色
//                .chartBackground { chartProxy in
//                        Color.red.opacity(0.5)
//                }
//                ///设置绘图区背景色
//                .chartPlotStyle { plotArea in
//                    plotArea.background{
//                        Color.blue.opacity(0.2)
//                    }
//                }
//                    .listRowSeparator(.hidden)
                Spacer()
            }
        }
    }
}


struct LBChartLineMarkView_Previews: PreviewProvider {
    
    static var previews: some View {
        LBChartLineMarkView()
    }
}
