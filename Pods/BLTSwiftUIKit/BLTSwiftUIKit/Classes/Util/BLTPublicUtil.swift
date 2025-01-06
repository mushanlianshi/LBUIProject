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


///获取引用类型的地址
public func getClassObjAddress(obj: AnyObject) -> String{
    if Mirror.init(reflecting: obj).displayStyle == .class{
        let opaquePointer = Unmanaged.passUnretained(obj as AnyObject).toOpaque()
        let classPoint = UnsafeRawPointer(opaquePointer)
        return classPoint.debugDescription
    }
    return ""
}

///获取值类型的地址
public func getValueObjAddress<T>(obj: inout T) -> String {
    let structPoint = withUnsafePointer(to: &obj) { $0 }
    return structPoint.debugDescription
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



@discardableResult
public func BLTDump<T>(_ value: T, name: String? = nil, indent: Int = 0, maxDepth: Int = .max, maxItems: Int = .max) -> T{
#if DEBUG
    return dump(value, name: name, indent: indent, maxDepth: maxDepth, maxItems: maxItems)
#endif
    return value
}


@discardableResult
public func swizzlingMethodSwift(_ objClass: AnyClass, _ originalSelector: Selector, _ swizzleSelector: Selector) -> Bool{
    let originalMethod = class_getInstanceMethod(objClass, originalSelector)
    let swizzleMethod = class_getInstanceMethod(objClass, swizzleSelector)
    
    guard let _ = originalMethod, let _ = swizzleMethod else { return false}
    
    if class_addMethod(objClass, originalSelector, method_getImplementation(swizzleMethod!), method_getTypeEncoding(swizzleMethod!)){
        class_replaceMethod(objClass, swizzleSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
    }else{
        method_exchangeImplementations(originalMethod!, swizzleMethod!)
    }
    return true
}
