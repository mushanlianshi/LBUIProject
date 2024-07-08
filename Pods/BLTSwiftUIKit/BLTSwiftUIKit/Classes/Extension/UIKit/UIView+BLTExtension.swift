//
//  UIView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation
import UIKit

private struct AssociatedKeys {
    static var autoLayoutGradientLayerKey = "autoLayoutGradientLayerKey"
}

extension UIView: BLTNameSpaceCompatible{}

public enum BLTUIViewGradientLayerDirection: Int {
    case leftToRight = 0
    case topToBottom
    case leftTopToRightBottom
}

private var gradientLayerKey: Bool = false
private var cornerBorderLayerKey: Bool = false



///快速初始化的
extension BLTNameSpace where Base: UIView{
    
    public static func initWithBackgroundColor(color: UIColor = .white,  cornerRadius: CGFloat? = nil) -> Base{
        let view = Base()
        view.backgroundColor = color
        if let radius = cornerRadius {
            view.layer.cornerRadius = radius
            view.layer.masksToBounds = true
        }
        return view
    }
    
}


extension BLTNameSpace where Base: UIView{
    //    设置优先级
    public func setCompressHugging(lowPriorityViews: [UIView], highPriorityViews: [UIView], direction: NSLayoutConstraint.Axis = .horizontal) {
        for lowView in lowPriorityViews {
            lowView.setContentCompressionResistancePriority(.defaultLow, for: direction)
            lowView.setContentHuggingPriority(.defaultLow, for: direction)
        }
        
        for highView in highPriorityViews{
            highView.setContentCompressionResistancePriority(.required, for: direction)
            highView.setContentHuggingPriority(.required, for: direction)
        }
    }
    
    //    获取view的currentVC
    public func currentViewController() -> UIViewController?{
        var superV = base.superview
        while superV != nil {
            let nextResponder = superV?.next
            if nextResponder is UIViewController{
                return nextResponder as? UIViewController
            }
            superV = superV?.superview
        }
        return nil
    }
    
    public func removeAnchorConstraints(){
        self.base.removeConstraints(self.base.constraints)
    }
}


///处理渐变色   圆角   形状的常用方法
extension BLTNameSpace where Base: UIView{
    ///渐变色背景 可以autolayout之后的
    public func addGradientLayer(_ startColor: UIColor, _ endColor: UIColor, _ direction: BLTUIViewGradientLayerDirection = .leftToRight, autoLayout: Bool = false){
        
        func refreshGradientLayer(){
            var gradientLayer: CAGradientLayer?
            gradientLayer = objc_getAssociatedObject(self.base, &gradientLayerKey) as? CAGradientLayer
            
            if gradientLayer != nil{
                gradientLayer?.removeFromSuperlayer()
                gradientLayer = nil
            }
            
            gradientLayer = CAGradientLayer()
            gradientLayer?.frame = self.base.bounds
            gradientLayer?.colors = [startColor.cgColor, endColor.cgColor]
            
            var startPoint = CGPoint(x: 0, y: 0.5)
            var endPoint = CGPoint(x: 1, y: 0.5)
            
            switch direction {
            case .leftToRight:
                endPoint = CGPoint(x: 1, y: 0.5)
            case .topToBottom:
                startPoint = CGPoint(x: 0.5, y: 0)
                endPoint = CGPoint(x: 0.5, y: 1)
            case .leftTopToRightBottom:
                startPoint = CGPoint(x: 0, y: 0)
                endPoint = CGPoint(x: 1, y: 1)
            }
            
            gradientLayer?.startPoint = startPoint
            gradientLayer?.endPoint = endPoint
            
            if self.base is UILabel{
                assert(false, "please use UIButton or view ,not label")
            }else{
                self.base.layer.addSublayer(gradientLayer!)
                self.base.layer.insertSublayer(gradientLayer!, at: 0)
            }
            
            objc_setAssociatedObject(self.base, &gradientLayerKey, gradientLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
        
        self.base.blt_autoLayoutGradientLayer = autoLayout
        
        if autoLayout{
            var objClass: AnyClass = UIView.self
            if self.base is UIButton{
                objClass = UIButton.self
            }
            BLTOnceExecuteManager.executeTask(task: {
                if self.base is UIButton{
                    UIButton.exchangeButtonLayoutSubviewsMethod()
                }else{
                    UIView.exchangeLayoutSubviewsMethod()
                }
            }, onceIdentifier: "\(objClass.description()) addGradientLayer")
            
        }
        
        refreshGradientLayer()
    }
    
    
    ///添加不通圆角的边框
    @discardableResult
    public func addCornerBorder(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat, lineWidth: CGFloat = 1, borderColor: UIColor = .lightText) -> CAShapeLayer {
        if let layer = objc_getAssociatedObject(self.base, &cornerBorderLayerKey) as? CAShapeLayer{
            layer.removeFromSuperlayer()
        }
        
        let path = self.cornerShape(leftTopRadius, rightTopRadius, leftBottomRadius, rightBottomRadius, lineWidth: lineWidth)
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.base.bounds
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        self.base.layer.addSublayer(borderLayer)
        self.base.layer.insertSublayer(borderLayer, at: 0)
        objc_setAssociatedObject(self.base, &cornerBorderLayerKey, borderLayer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return borderLayer
    }
    
    ///画不通的形状
    @discardableResult
    public func addCornerShape(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat) -> CAShapeLayer{
        let path = self.cornerShape(leftTopRadius, rightTopRadius, leftBottomRadius, rightBottomRadius)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.base.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        self.base.layer.mask = shapeLayer
        return shapeLayer
    }
    
    
    public func cornerShape(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat, lineWidth: CGFloat = 1) -> UIBezierPath{
        let width = self.base.bounds.width
        let height = self.base.bounds.height
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        // 左下角
        path.move(to: CGPoint(x: leftBottomRadius, y: height))
        path.addLine(to: CGPoint(x: width - rightBottomRadius, y: height))
        
        //右下角弧线
        path.addQuadCurve(to: CGPoint(x: width, y: height - rightBottomRadius), controlPoint: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: width, y: rightTopRadius))
        
        //右上角弧线
        path.addQuadCurve(to: CGPoint(x: width - rightTopRadius, y: 0), controlPoint: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: leftTopRadius, y: 0))
        
        //左上角弧线
        path.addQuadCurve(to: CGPoint(x: 0, y: leftTopRadius), controlPoint: .zero)
        path.addLine(to: CGPoint(x: 0, y: height - leftBottomRadius))
        
        //左下角弧线
        path.addQuadCurve(to: CGPoint(x: leftBottomRadius, y: height), controlPoint: CGPoint(x: 0, y: height))
        
        return path
    }
}








fileprivate extension UIView{
    var blt_autoLayoutGradientLayer: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.autoLayoutGradientLayerKey) as? Bool) ?? false
        }
        set{
            return objc_setAssociatedObject(self, &AssociatedKeys.autoLayoutGradientLayerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}




///渐变色用的
fileprivate extension UIView{
    
    static func exchangeLayoutSubviewsMethod(){
        swizzlingMethodSwift(UIView.self, #selector(layoutSubviews), #selector(blt_layoutSubviews))
    }
    
    @objc func blt_layoutSubviews(){
        self.blt_layoutSubviews()
        
        guard blt_autoLayoutGradientLayer else {
            return
        }
        guard let gradientLayer = objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer else { return }
        
        //        消除layer的隐式动画 UIView performWithoutAnimation消除不了 使用事务
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = self.bounds
        CATransaction.commit()
    }
}




fileprivate extension UIButton{
    
    static func exchangeButtonLayoutSubviewsMethod(){
        swizzlingMethodSwift(UIButton.self, #selector(layoutSubviews), #selector(blt_ButtonLayoutSubviews))
    }
    
    @objc func blt_ButtonLayoutSubviews(){
        self.blt_ButtonLayoutSubviews()
        
        guard blt_autoLayoutGradientLayer else {
            return
        }
        
        guard let gradientLayer = objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer else { return }
        
        //        消除layer的隐式动画 UIView performWithoutAnimation消除不了 使用事务
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = self.bounds
        CATransaction.commit()
    }
}
