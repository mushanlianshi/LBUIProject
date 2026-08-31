import Foundation
import UIKit
import QuartzCore

// ===== BLTNameSpace 修改后的多场景编译验证 =====
// 1) non-final class 遵守（此前报错场景：CAShapeLayer）
extension CAShapeLayer: BLTNameSpaceCompatible {}
extension UILabel: BLTNameSpaceCompatible {}
// 2) struct（值类型）
struct MyValue: BLTNameSpaceCompatible {}
// 3) final class
final class MyFinal: BLTNameSpaceCompatible {}
// 4) 旧协议名（typealias 兼容层）
extension String: BLTNameSpaceCompatibleValue {}

// 扩展方法两条路径
extension BLTNameSpace where Base: CAShapeLayer {
    func testStroke() -> CGColor { base.strokeColor ?? UIColor.red.cgColor }
    static func make() -> Base { Base() }
}

// 实例调用路径
let layer = CAShapeLayer()
_ = layer.blt.base
_ = layer.blt.testStroke()
// 类型调用路径
_ = CAShapeLayer.blt.make()
_ = UILabel.blt
// struct / 旧协议名
let s = MyValue()
_ = s.blt.base
_ = "abc".blt.base

// ===== 以下为被测本体：与 Pods 内 BLTNameSpace.swift 完全一致 =====

/// 命名空间容器
public struct BLTNameSpace<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol BLTNameSpaceCompatible {
    associatedtype BLTCompatibleType
    var blt: BLTCompatibleType { get }
    static var blt: BLTCompatibleType.Type { get }
}

public extension BLTNameSpaceCompatible {
    var blt: BLTNameSpace<Self> {
        BLTNameSpace(self)
    }
    static var blt: BLTNameSpace<Self>.Type {
        BLTNameSpace<Self>.self
    }
}

@available(*, deprecated, renamed: "BLTNameSpaceCompatible")
public typealias BLTNameSpaceCompatibleValue = BLTNameSpaceCompatible
