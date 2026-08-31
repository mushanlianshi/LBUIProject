//
//  BLTNameSpace.swift
//  BLTSwiftUIKit 讹误
//
//  Created by liu bin on 2021/12/8.
//

import Foundation

/// 命名空间容器：所有 `.blt` 扩展方法写在「本类型的条件扩展」里
///（如 extension BLTNameSpace where Base == UILabel），
/// 避免方法直接污染 UIKit / 基础类型的全局命名。
/// 参考 RxSwift.rx / Kingfisher.kf / SnapKit.snp 同款模式
public struct BLTNameSpace<Base> {

    /// 被包装的对象实例；类型调用（XXX.blt.xxx）时不使用此属性
    public let base: Base

    public init(_ base: Base) {
        self.base = base
    }
}

/// 命名空间接入协议（class / struct / enum 通用）
///
/// 用法：
/// 1. 类型接入：`extension UILabel: BLTNameSpaceCompatible {}`
/// 2. 实例调用：`label.blt.xxx`（实例扩展方法）
/// 3. 类型调用：`UILabel.blt.xxx`（static 扩展方法）
///
/// associatedtype 是必需设计，不是冗余：协议要求里若直接写
/// `var blt: BLTNameSpace<Self>`，Self 位于属性类型位置，
/// non-final class（UIKit 类均可继承，如 CAShapeLayer/UILabel）
/// 将无法满足要求而编译报错；用 associatedtype 占位、协议扩展的
/// 默认实现里再引入 `BLTNameSpace<Self>`，经推断绑定即可合法合成
/// witness（RxSwift.ReactiveCompatible 同款手法）。
///
/// 注意：struct 遵守时 `blt.base` 是值拷贝——扩展方法应返回新值，
/// 不要期望原地修改原变量（class 无此问题，base 持引用）
public protocol BLTNameSpaceCompatible {
    /// 占位类型，默认推断为 BLTNameSpace<Self>
    associatedtype BLTCompatibleType
    /// 实例命名空间入口（只读，杜绝无效赋值）
    var blt: BLTCompatibleType { get }
    /// 类型命名空间入口（只读，static 扩展方法经此调用）
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

/// 兼容层：旧协议名（原值类型专用协议，已并入统一协议）
/// 保留 typealias 让既有遵守代码无需改动即可编译
@available(*, deprecated, renamed: "BLTNameSpaceCompatible")
public typealias BLTNameSpaceCompatibleValue = BLTNameSpaceCompatible
