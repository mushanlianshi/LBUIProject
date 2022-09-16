//
//  ViewController.swift
//  BLTSwiftUIKit
//
//  Created by mushanlianshi on 12/08/2021.
//  Copyright (c) 2021 mushanlianshi. All rights reserved.
//


//利用元组来实现交换元素
public func BLTSwapElement<T>(a: inout T,b: inout T){
    (a,b) = (b,a)
}

//老方法交换  仅对比
private func BLTOldSwapElement<T>(a: inout T,b: inout T){
    let tmp = a
    a = b
    b = tmp
}

public func isSimulator() -> Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
}

public func BLTSwiftLog(_ content: Any, isDebugPrint: Bool = false, file: String = #file, line: Int = #line, method: String = #function){
#if DEBUG
    //LB DEBUG TEST
    let outContent = "\((file as NSString).lastPathComponent)[\(line)], \(method): \(content)"
    if isDebugPrint{
        debugPrint(outContent)
    }else{
        print(outContent)
    }
#endif
}




//类似OC里的KVC
public func BLTKVCValueFrom(_ object: Any, key: String) -> Any?{
//    反射
    let mirror = Mirror(reflecting: object)
    for child in mirror.children {
        if key == child.label{
            return child.value
        }
    }
    
    return nil
}


public func CGRectFromEdgeInsetsSwift(frame: CGRect, insets: UIEdgeInsets) -> CGRect{
    return CGRect(x: frame.origin.x + insets.left, y: frame.origin.y + insets.top, width: frame.size.width - insets.left - insets.right, height: frame.size.height - insets.top - insets.bottom)
}
