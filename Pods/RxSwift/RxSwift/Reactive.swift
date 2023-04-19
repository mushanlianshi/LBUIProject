//
//  Reactive.swift
//  RxSwift
//
//  Created by Yury Korolev on 5/2/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

/**
 Use `Reactive` proxy as customization point for constrained protocol extensions.

 General pattern would be:

 // 1. Extend Reactive protocol with constrain on Base
 // Read as: Reactive Extension where Base is a SomeType
 extension Reactive where Base: SomeType {
 // 2. Put any specific reactive extension for SomeType here
 }

 With this approach we can have more specialized methods and properties using
 `Base` and not just specialized on common base type.

 `Binder`s are also automatically synthesized using `@dynamicMemberLookup` for writable reference properties of the reactive base.
 */

@dynamicMemberLookup
public struct Reactive<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }

    /// Automatically synthesized binder for a key path between the reactive
    /// base and one of its properties
    /// ///ReferenceWritableKeyPath通过keypath的方式来获取值
    ///Property需要声明泛型Property来和ReferenceWritableKeyPath对应   实际上是ReferenceWritableKeyPath的Base的keypath来获取对应的属性
    ///在包装成一个binder<Property>来返回
    ///使用subscript的方式  可以避免以前的写各种extension（extension Reactive where Base: UIView） 来实现各个属性   减少代码量等
    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Property>) -> Binder<Property> where Base: AnyObject {
        let result = Binder(self.base) { base, value in
            base[keyPath: keyPath] = value
        }
        return result
    }
}

/// A type that has reactive extensions.
public protocol ReactiveCompatible {
    /// Extended type
    associatedtype ReactiveBase

    /// Reactive extensions.
    static var rx: Reactive<ReactiveBase>.Type { get set }

    /// Reactive extensions.
    var rx: Reactive<ReactiveBase> { get set }
}

extension ReactiveCompatible {
    /// Reactive extensions.
    public static var rx: Reactive<Self>.Type {
        get { Reactive<Self>.self }
        // this enables using Reactive to "mutate" base type
        // swiftlint:disable:next unused_setter_value
        set { }
    }

    /// Reactive extensions.
    public var rx: Reactive<Self> {
        get { Reactive(self) }
        // this enables using Reactive to "mutate" base object
        // swiftlint:disable:next unused_setter_value
        set { }
    }
}

import Foundation

/// Extend NSObject with `rx` proxy.
extension NSObject: ReactiveCompatible { }
