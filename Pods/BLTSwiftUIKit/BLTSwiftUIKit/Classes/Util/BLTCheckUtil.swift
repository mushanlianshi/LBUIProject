//
//  BLTReverseSequence.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/7/17.
//

///判断一个可选的字符串 是不是空字符串 使用isEmpty和count>0的区别  isEmpty判断是否包含一个字符即可  count是长度  如果字符串很长需要遍历拿到整个长度  效率比isEmpty低
public func bltCheckStringIsEmpty(_ text: String?) -> Bool{
    guard let value = text, value.isEmpty == false else { return true }
    return false
}

///判断可选的数组是不是空
public func bltCheckArrayIsEmpty(_ array: Array<Any>?) -> Bool{
    guard let value = array, value.isEmpty == false else { return true }
    return false
}

///判断可选的字典是不是空
public func bltCheckDicIsEmpty(_ dic: [AnyHashable : Any]?) -> Bool{
    guard let value = dic, value.isEmpty == false else { return true }
    return false
}


///是不是模拟器
public func bltCheckIsSimulator() -> Bool {
#if targetEnvironment(simulator)
    return true
#else
    return false
#endif
}
