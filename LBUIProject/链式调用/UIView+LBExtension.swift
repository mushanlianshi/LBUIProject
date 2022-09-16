//
//  UIView+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/27.
//

import Foundation


extension UIView{
    
    public typealias chainBlock = ((_ item: UIView) -> UIView)
    
    public func lbWith() -> ((_ view: UIView) -> UIView){
        let block = { (_ item: UIView) -> UIView in
            print("LBLog block \(item)")
            return self
        }
        return block
    }
}
