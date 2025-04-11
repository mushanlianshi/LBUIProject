//
//  BLTViewBuilder.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//


/// 使用resultBuilder来处理代码块   和SwiftUI的viewBuilder声明式一样
@resultBuilder
public enum BLTViewBuilder{
    
    public typealias Expression = UIView
    public typealias Component = [UIView]
    
    
    
    public static func buildBlock(_ components: BLTViewBuilder.Component...) -> BLTViewBuilder.Component {
        //flatMap 来降维
        return components.flatMap{ $0 }
    }
    
    public static func buildBlock(_ components: UIView...) -> BLTViewBuilder.Component {
        //flatMap 来降维
        return components.map{ $0 }
    }
    
    public static func buildOptional(_ component: BLTViewBuilder.Component?) -> BLTViewBuilder.Component {
        return component ?? []
    }
    
    
    ///处理block内含有表达式 if else这种的
    public static func buildExpression(_ expression: Expression) -> BLTViewBuilder.Component {
        return [expression]
    }
    
    ///处理block中的if else的
    public static func buildEither(first component: BLTViewBuilder.Component) -> BLTViewBuilder.Component {
        return component
    }
    
    public static func buildEither(second component: BLTViewBuilder.Component) -> BLTViewBuilder.Component {
        return component
    }
}
