//
//  LBBlueSwiftUIPage.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/11.
//

import SwiftUI
///swiftUI 请求数据的三种时机
///1.在 onAppear方法中
///2.在task task()方法允许您在页面渲染时执行异步任务，并在任务完成时更新视图。
///3.在viewModel的init方法中
struct LBBluetoothSwiftUIPage: View {
    ///定义这个模型为可观察对象  当里面的属性被public修饰   变化的时候自动触发UI刷新
    @ObservedObject
    var bluetoothManager = LBBlueToothManager()
    var body: some View {
        List{
            Section(header: Text("蓝牙设备").bold().foregroundColor(.black).font(.title).padding(.bottom,10)) {
                listItemViews.listRowInsets(EdgeInsets())///去掉listItem的间距  靠边的
            }
        }.task {
            self.bluetoothManager.initBluetoothManager()
        }.onDisappear{
            self.bluetoothManager.stopScanPeripherals()
        }
        ///去掉内间距
//        .listStyle(.plain)
        ///外间距
//        .padding(.all,20)
//        .onAppear{
//            self.bluetoothManager.initBluetoothManager()
//        }
    }
    
    ///LazyVStack 使用懒加载  避免一次性创建所有view  懒加载只有到屏幕中才会创建
    ///ForEach(0 ..< viewModel.modelVM.total, id:\.self) 解决 Non-constant range: argument must be an integer literal
    private var listItemViews: some View{
        let count = bluetoothManager.peripheralDeviceList.count
        return LazyVStack(spacing: 5) {
            ForEach(0 ..< count, id: \.self) { item in
                let peripheral = bluetoothManager.peripheralDeviceList[item]
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        Text(peripheral.name ?? "")
                            .padding()
                            .frame(alignment: .leading)
                            Spacer()
                            peripheral == bluetoothManager.currentPeripheral ? Text("已连接") : Text("")
                    }
                    Divider()
                }
                ///不用系统的  系统的点击空白区域无效
                .onTapExpandArea {
                    self.bluetoothManager.connectPeripheral(peripheral)
                }
            }
            ///去掉listitem 的间距
        }.listRowInsets(EdgeInsets())
    }
    
    
    
    private var listItemViews2: some View{
        let count = bluetoothManager.peripheralDeviceList.count
        return LazyVStack(spacing: 5) {
            ForEach(0 ..< count, id:\.self) { item in
                let peripheral = bluetoothManager.peripheralDeviceList[item]
                VStack(spacing: 0) {
                    HStack(spacing: 10) {
                        Text(peripheral.name ?? "")
                            .padding()
                            .frame(alignment: .leading)
                            Spacer()
                            peripheral == bluetoothManager.currentPeripheral ? Text("已连接") : Text("")
                    }
                    Divider()
                }
                ///不用系统的  系统的点击空白区域无效
                .onTapExpandArea {
                    self.bluetoothManager.connectPeripheral(peripheral)
                }
            }
        }
    }
}




struct LBBlueSwiftUIPage_Previews: PreviewProvider {
    static var previews: some View {
        LBBluetoothSwiftUIPage()
    }
    
}
