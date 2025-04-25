//
//  LBBlueToothManager.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/11.
//

import Foundation
import CoreBluetooth

//AT 指令的格式通常是字符串，后面加上一个换行符 \r\n。例如：
//•    AT+TEST\r\n
//•    AT+CONNECT=<device_address>\r\n
//•    AT+SEND=<data>\r\n
//1. MacBook 和 AirPods 默认不作为 BLE 广播设备
//•    CoreBluetooth（iOS/macOS 上的蓝牙框架）只能发现符合 BLE（Bluetooth Low Energy）协议并且主动广播的设备。
//•    MacBook 和 AirPods 并不会主动作为 BLE 外设广播（advertise）自身信息，除非开启某些特殊模式（比如 AirDrop、设置为蓝牙配件、开发者调试等）。
//•    AirPods 连接 Apple 设备使用的是私有协议和 HFP、A2DP，不是公开的 BLE 服务。
class LBBlueToothManager: NSObject, ObservableObject {
    ///查找心率设备的UUID 这些设备的ID都是固定的，公开的
    private let BLE_HEART_RATE_SERVICE_CBUUID = CBUUID(string: "0x180D")
    /// MARK: - Core Bluetooth characteristic IDs
    private let BLE_Heart_Rate_Measurement_Characteristic_CBUUID = CBUUID(string: "0x2A37")
    private let BLE_Body_Sensor_Location_Characteristic_CBUUID = CBUUID(string: "0x2A38")
    
    ///查找蓝牙设备的manager
    var centralManager: CBCentralManager?
    ///当前连接的外设
    @Published
    var currentPeripheral: CBPeripheral?
    
    @Published
    var peripheralDeviceList = [CBPeripheral]()
    
    
    var peripheral: CBPeripheral?
    // 特征服务
    var characteristic: CBCharacteristic?
        
    // AT指令发送和接收的相关变量
    var atCommand = "AT+TEST\r\n" // 这是一个示例AT指令
    
    func initBluetoothManager(){
        ///创建一个串行队列去查找设备
        self.centralManager = CBCentralManager.init(delegate: self, queue: DispatchQueue.init(label: "blue queue", attributes: .concurrent))
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("LBLog is scaning \(String(describing: self.centralManager?.isScanning))")
        })
    }
}

extension LBBlueToothManager: CBCentralManagerDelegate{
    
    ///1.检查当前设备蓝牙状态是否可用
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("LBLog 当前设备蓝牙状态：unknown")
        case .poweredOff:
            print("LBLog 当前设备蓝牙状态：poweredOff")
        case .resetting:
            print("LBLog 当前设备蓝牙状态：resetting")
        case .unauthorized:
            print("LBLog 当前设备蓝牙状态：unauthorized")
        case .unsupported:
            print("LBLog 当前设备蓝牙状态：unsupported")
        case .poweredOn:
            print("LBLog 当前设备蓝牙状态：poweredOn")
            self.startScanPeripherals()
        @unknown default:
            print("LBLog 当前设备蓝牙状态：unknown")
        }
    }
    ///2.搜索到蓝牙外围设备的
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard let deviceName = peripheral.name, deviceName.isEmpty == false else { return }
        
//        guard deviceName = "AirPods 3" else {
//            return
//        }
        ///检查搜索到外设的状态
        decodePeripheralState(peripheral)
        print("LBLog 搜索到的外设 \(deviceName)")
        ///把搜索到的设备添加到设备列表
        let isNewDevice = peripheralDeviceList.allSatisfy({ peripheral in
            peripheral.name != deviceName
        })
        if isNewDevice{
            DispatchQueue.main.async {
                [weak self] in
                self?.peripheralDeviceList.append(peripheral)
            }
        }
//        print("LBLog peripheralDeviceList \(peripheralDeviceList)")
        if peripheral.name == "liubin airpods" {
            // 链接设备
            self.peripheral = peripheral
            centralManager?.connect(peripheral, options: nil)
        }
    }
    
    ///3.外设连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("LBLog Connected to peripheral: \(peripheral.name ?? "Unknown")")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    ///4.外设链接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("LBLog 外设连接失败: didFailToConnect")
    }
    
    ///5.外设断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("LBLog 外设断开连接: didDisconnectPeripheral")
    }
    
}


///外设的代理
extension LBBlueToothManager: CBPeripheralDelegate{
    ///1.连接外设成功后  发现外设的服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let serviceList = peripheral.services else { return }
        
        for service in serviceList {
            print("LBLog service is \(service)")
            ///是我们需要的服务
            if service.uuid == BLE_HEART_RATE_SERVICE_CBUUID{
                ///搜索服务上的数据 特征
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    
    ///2.发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            print("LBlog characteristic \(characteristic)")
            
            if characteristic.uuid == BLE_Body_Sensor_Location_Characteristic_CBUUID {
                peripheral.readValue(for: characteristic)
                
            }

            if characteristic.uuid == BLE_Heart_Rate_Measurement_Characteristic_CBUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.properties.contains(.write) {
                self.characteristic = characteristic
                print("Found writable characteristic: \(characteristic.uuid)")
                sendATCommand()
            }
            
        } //
    }
    
    ///3.服务发送数据更新了 // 接收设备返回数据
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        ///是我们需要的心跳频率的uuid数据
        if characteristic.uuid == BLE_Heart_Rate_Measurement_Characteristic_CBUUID {
            let heartRate = deriveBeatsPerMinute(using: characteristic)
            print("LBLog 心率是 \(heartRate)")
        }
        
        ///是位置信息
        if characteristic.uuid == BLE_Body_Sensor_Location_Characteristic_CBUUID {
            let sensorLocation = readSensorLocation(using: characteristic)
            print("LBLog 心率是 \(sensorLocation)")
        }
        
        if let value = characteristic.value {
            let response = String(data: value, encoding: .utf8)
            print("Received response: \(response ?? "No response")")
        }
    }
    
    // 发送 AT 指令
        func sendATCommand() {
            let atCommand = "seek"
            guard let characteristic = self.characteristic else { return }
            if let data = atCommand.data(using: .utf8) {
                peripheral?.writeValue(data, for: characteristic, type: .withResponse)
                print("Sent AT Command: \(atCommand)")
            }
        }
    
}

extension LBBlueToothManager{
    ///开始搜索外围设备
    private func startScanPeripherals(){
        ///搜索指定UUID的外设  不设置就是搜索所有的外设
//        self.centralManager?.scanForPeripherals(withServices: [BLT_HEART_RATE_SERVICE_CBUUID])
        self.centralManager?.scanForPeripherals(withServices: nil)
    }
    
    func stopScanPeripherals()  {
        self.centralManager?.delegate = nil
//        print("LBLog is scaning ------ \(self.centralManager?.isScanning)")
        if let scan = self.centralManager?.isScanning, scan {
            self.centralManager?.stopScan()
        }
        
    }
    
    ///检查外围设备的状态
    private func decodePeripheralState(_ peripheral: CBPeripheral){
        switch peripheral.state {
        case .disconnected:
            print("LBLog peripheral 外围设备状态： disconnected");
        case .connected:
            print("LBLog peripheral 外围设备状态： connected");
        case .connecting:
            print("LBLog peripheral 外围设备状态： connecting");
        case .disconnecting:
            print("LBLog peripheral 外围设备状态： disconnecting");
        @unknown default:
            print("LBLog peripheral 外围设备状态： unkonw");
        }
    }
    
    ///连接外设
    func connectPeripheral(_ peripheral: CBPeripheral){
        ///已连接 断开连接
        if peripheral.state == .connected{
            self.centralManager?.cancelPeripheralConnection(peripheral)
            self.currentPeripheral = nil
            self.currentPeripheral?.delegate = nil
            print("LBLog 外设断开连接 成功");
            return
        }
        
        self.currentPeripheral?.delegate = nil
        self.currentPeripheral = peripheral
        self.currentPeripheral?.delegate = self
        ///连接外设就不在搜索了
        self.centralManager?.stopScan()
        self.centralManager?.connect(peripheral)
        print("LBLog 连接 成功");
    }
    
    func deriveBeatsPerMinute(using heartRateMeasurementCharacteristic: CBCharacteristic) -> Int {
        let heartRateValue = heartRateMeasurementCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](heartRateValue)
        if ((buffer[0] & 0x01) == 0) {
            // second byte: "Heart Rate Value Format is set to UINT8."
            print("BPM is UInt8")
            // write heart rate to HKHealthStore
            // healthKitInterface.writeHeartRateData(heartRate: Int(buffer[1]))
            return Int(buffer[1])
        } else { // I've never seen this use case, so I'll
            print("BPM is UInt16")
            return -1
        }
        
    } // END func deriveBeatsPerMinute
    
    func readSensorLocation(using sensorLocationCharacteristic: CBCharacteristic) -> String {
        
        let sensorLocationValue = sensorLocationCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](sensorLocationValue)
        var sensorLocation = ""
        
        // look at just 8 bits
        if buffer[0] == 1
        {
            sensorLocation = "Chest"
        }
        else if buffer[0] == 2
        {
            sensorLocation = "Wrist"
        }
        else
        {
            sensorLocation = "N/A"
        }
        
        return sensorLocation
        
    } // END fun
}
