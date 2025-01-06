//
//  BLTResponderTransfer.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/6/29
//

public struct BLTResponderEvent: Hashable, Equatable, RawRepresentable, Comparable{
    
    public typealias RawValue = Int
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var hashValue: Int{
        return rawValue
    }
    
    public static func < (lhs: BLTResponderEvent, rhs: BLTResponderEvent) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public static func == (lhs: BLTResponderEvent, rhs: BLTResponderEvent) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}


public extension BLTResponderEvent{
//    public static let callMobile = LBResponderEvent.init(rawValue: 1)
}


public protocol BLTResponderTransferProtocol: AnyObject {
    func receiveEvent(_ eventType: BLTResponderEvent, obj: Any?)
}



extension BLTNameSpace where Base: UIView{
    
    ///根据找响应链  遵守传递响应的协议就是我们要找的对象
    public func transferEvent(_ event: BLTResponderEvent, obj: Any?){
        var nextResponder = base.next
        while nextResponder != nil{
            if let resd = nextResponder as? BLTResponderTransferProtocol{
                resd.receiveEvent(event, obj: obj)
                nextResponder = nil
                break
            }
            nextResponder = nextResponder?.next
        }
    }
    
}
