//
//  UIView+BLTShape.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2024/1/11.
//

import Foundation

private var gradientLayerKey: Bool = false
private var cornerBorderLayerKey: Bool = false

private struct AssociatedKeys {
    /// autoLayout之后 调用了layoutSubviews后刷新形状的
    static var didLayoutSubviewsBlockKey = "blt_didLayoutSubviewsBlock"
    
    /// 是不是自动布局后刷新渐变色的layer的key
    static var autoLayoutGradientLayerKey = "blt_autoLayoutGradientLayerKey"
    /// 渐变色layer的key
    static var gradientLayerKey = "blt_gradientLayerKey"
    
    
    /// 是不是自动布局后再刷新边框的key
    static var autoLayoutBorderLayerKey = "blt_autoLayoutBorderLayer"
    /// 边框的layer
    static var borderShapeLayerKey = "blt_borderShapeLayer"
    /// 边框的layer各种数字存储对象的key
    static var borderShapeModelKey = "blt_borderShapeModel"
    
    
    /// 是不是自动布局后再刷新形状的key
    static var autoLayoutCornerShapeLayerKey = "blt_autoLayoutCornerShapeLayer"
    /// 形状的layer各种数字存储对象的key
    static var cornerShapeModelKey = "blt_cornerShapeModel"
}

/// 记录形状属性的类型，用来关联属性存储用的， 在view 位置刷新后取出刷新界面的
fileprivate class BLTShapeModel: NSObject{
    let borderColor: UIColor
    let lineWidth: CGFloat
    /// 是否需要布局后刷新的  默认是true  只有刷新位置后改变的才会后面再刷新形状
    var autoLayout = true
    /// 相同圆角半径的值
    var cornerRadius: CGFloat?
    var roundCorners: UIRectCorner?
    
    /// 不同圆角的值
    var leftTopRadius: CGFloat = 0
    var rightTopRadius: CGFloat = 0
    var leftBottomRadius: CGFloat = 0
    var rightBottomRadius: CGFloat = 0
    
    /// 快速初始化边框的
    init(lineWidth: CGFloat,borderColor: UIColor){
        self.lineWidth = lineWidth
        self.borderColor = borderColor
        super.init()
    }
    convenience init(lineWidth: CGFloat,borderColor: UIColor, cornerRadius: CGFloat, roundCorners: UIRectCorner) {
        self.init(lineWidth: lineWidth, borderColor: borderColor)
        self.cornerRadius = cornerRadius
        self.roundCorners = roundCorners
    }
    convenience init(lineWidth: CGFloat,borderColor: UIColor, leftTopRadius: CGFloat = 0, rightTopRadius: CGFloat = 0, leftBottomRadius: CGFloat = 0, rightBottomRadius: CGFloat = 0) {
        self.init(lineWidth: lineWidth, borderColor: borderColor)
        self.leftTopRadius = leftTopRadius
        self.rightTopRadius = rightTopRadius
        self.leftBottomRadius = leftBottomRadius
        self.rightBottomRadius = rightBottomRadius
    }
    
}


/// 渐变位置类型的枚举
public enum BLTUIViewGradientLayerDirection: Int {
    case leftToRight = 0
    case topToBottom
    case leftTopToRightBottom
}

/// 处理view的形状的   比如渐变、不同圆角半径的、相同圆角半径某些角的
/// 分类的属性
fileprivate extension UIView{
    
    var blt_didLayoutSubviewsBlock:(() -> Void)?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.didLayoutSubviewsBlockKey) as? (() -> Void)
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.didLayoutSubviewsBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    /// 是不是需要layout后刷新渐变  只根据layer判断不出来  防止多次添加的layer会被记录下来  下次改变界面后移除用的
    var blt_isAutoLayoutGradient: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.autoLayoutGradientLayerKey) as? Bool) ?? false
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.autoLayoutGradientLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var blt_gradientLayer: CAGradientLayer?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.gradientLayerKey) as? CAGradientLayer
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.gradientLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    /// 边框
    var blt_isAutoLayoutBorder: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.autoLayoutBorderLayerKey) as? Bool) ?? false
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.autoLayoutBorderLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var blt_borderShapeLayer: CAShapeLayer?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.borderShapeLayerKey) as? CAShapeLayer
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.borderShapeLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var blt_borderShapeModel: BLTShapeModel?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.borderShapeModelKey) as? BLTShapeModel
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.borderShapeModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    
    /// 形状
    var blt_isAutoLayoutCornerShape: Bool{
        get{
            return (objc_getAssociatedObject(self, &AssociatedKeys.autoLayoutCornerShapeLayerKey) as? Bool) ?? false
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.autoLayoutCornerShapeLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var blt_cornerShapeModel: BLTShapeModel?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.cornerShapeModelKey) as? BLTShapeModel
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.cornerShapeModelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}


///处理渐变色
extension BLTNameSpace where Base: UIView{
    ///渐变色背景 可以autolayout之后的
    public func addGradientLayer(_ startColor: UIColor, _ endColor: UIColor, _ direction: BLTUIViewGradientLayerDirection = .leftToRight, autoLayout: Bool = false){
        
        func refreshGradientLayer(){
            ///处理调用多次的  先移除
            var gradientLayer: CAGradientLayer? = self.base.blt_gradientLayer
            
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
            
            self.base.blt_gradientLayer = gradientLayer
        }
        
        self.base.blt_isAutoLayoutGradient = autoLayout
        
        if autoLayout{
            self.exchangeViewLayoutSubviews()
        }
        refreshGradientLayer()
    }
    
}



/// 处理不规则边框的 + Border
extension BLTNameSpace where Base: UIView{
    
    ///添加相同圆角的边框  如果是autoLayout  返回的是nil  需要layoutSubviews之后才会真的绘制
    @discardableResult
    public func addCornerBorder(cornerRadius: CGFloat, roundCorners:UIRectCorner, borderColor: UIColor, lineWidth: CGFloat = 1, autoLayout: Bool = false) -> CAShapeLayer? {
        
        
        func addBorderNow() -> CAShapeLayer{
            /// 如果有尺寸或则不需要layoutSubview之后刷新的
            let path = self.cornerShapePath(cornerRadius, roundCorners: roundCorners)
            return self.p_addCornerBorderLayer(path: path, borderColor: borderColor, lineWidth: lineWidth)
        }
        
        /// 如果需要autoLayout后再画边框   那就先不画   等layoutSubviews后再画   省一次画
        if autoLayout{
            let shapeModel = BLTShapeModel.init(lineWidth: lineWidth, borderColor: borderColor, cornerRadius: cornerRadius, roundCorners: roundCorners)
            storeAutoLayoutShapeModel(shapeModel: shapeModel)
            
            /// 如果这时尺寸不是0  先直接画一遍
            if(self.base.bounds.size != .zero){
                return addBorderNow()
            }
            return nil
        }
        
        return addBorderNow()
    }
    
    ///添加不通圆角的边框
    @discardableResult
    public func addDifferentCornerRadiusBorder(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat, borderColor: UIColor, lineWidth: CGFloat = 1, autoLayout: Bool = false) -> CAShapeLayer? {
        
        func addBorderNow() -> CAShapeLayer{
            let path = self.differentCornerRadiusPath(leftTopRadius, rightTopRadius, leftBottomRadius, rightBottomRadius, lineWidth: lineWidth)
            return self.p_addCornerBorderLayer(path: path, borderColor: borderColor, lineWidth: lineWidth)
        }
        
        /// 如果需要autoLayout后再画边框   那就先不画   等layoutSubviews后再画   省一次画
        if autoLayout{
            let shapeModel = BLTShapeModel.init(lineWidth: lineWidth, borderColor: borderColor, leftTopRadius: leftTopRadius, rightTopRadius: rightTopRadius, leftBottomRadius: leftBottomRadius, rightBottomRadius: rightBottomRadius)
            storeAutoLayoutShapeModel(shapeModel: shapeModel)
            
            if(self.base.bounds.size != .zero){
                return addBorderNow()
            }
            
            return nil
        }
        
        return addBorderNow()
    }
    
    private func storeAutoLayoutShapeModel(shapeModel: BLTShapeModel){
        self.base.blt_borderShapeModel = shapeModel
        self.base.blt_isAutoLayoutBorder = true
        self.exchangeViewLayoutSubviews()
    }
    
    private func p_addCornerBorderLayer(path: UIBezierPath, borderColor: UIColor, lineWidth: CGFloat = 1) -> CAShapeLayer{
        if let borderLayer = self.base.blt_borderShapeLayer{
            borderLayer.removeFromSuperlayer()
        }
        
        let borderLayer = CAShapeLayer()
        borderLayer.frame = self.base.bounds
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        self.base.layer.addSublayer(borderLayer)
        self.base.layer.insertSublayer(borderLayer, at: 0)
        self.base.blt_borderShapeLayer = borderLayer
        return borderLayer
    }
    
}

/// 处理不规则形状的 + cornerShape
extension BLTNameSpace where Base: UIView{
    
    ///画不通的形状  如果等layoutSubview后自动调整  立马返回的是nil
    @discardableResult
    public func addCornerShape(_ cornerRadius: CGFloat, roundCorners: UIRectCorner, autoLayout: Bool = false) -> CAShapeLayer?{
        
        /// 如果有尺寸或则不需要layoutSubview之后刷新的
        func addCornerShapeNow() -> CAShapeLayer{
            let path = self.cornerShapePath(cornerRadius, roundCorners: roundCorners)
            return self.p_addCornerShapeLayer(path: path, autoLayout: autoLayout)
        }
        
        
        
        /// 如果需要autoLayout后再画边框   那就先不画   等layoutSubviews后再画   省一次画
        if autoLayout{
            let shapeModel = BLTShapeModel.init(lineWidth: 0, borderColor: .clear, cornerRadius: cornerRadius, roundCorners: roundCorners)
            storeAutoLayoutCornerShapeModel(shapeModel: shapeModel)
            
            if(self.base.bounds.size != .zero){
                return addCornerShapeNow()
            }
            return nil
        }
        
        return addCornerShapeNow()
    }
    
    ///画不通的形状
    @discardableResult
    public func addDifferentCornerShape(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat, autoLayout: Bool = false) -> CAShapeLayer?{
        
        /// 如果有尺寸或则不需要layoutSubview之后刷新的
        func addCornerShapeNow() -> CAShapeLayer{
            let path = self.differentCornerRadiusPath(leftTopRadius, rightTopRadius, leftBottomRadius, rightBottomRadius)
            return self.p_addCornerShapeLayer(path: path, autoLayout: autoLayout)
        }
        
        
        
        /// 如果需要autoLayout后再画边框   那就先不画   等layoutSubviews后再画   省一次画
        if autoLayout{
            let shapeModel = BLTShapeModel.init(lineWidth: 0, borderColor: .clear, leftTopRadius: leftTopRadius, rightTopRadius: rightTopRadius, leftBottomRadius: leftBottomRadius, rightBottomRadius: rightBottomRadius)
            storeAutoLayoutCornerShapeModel(shapeModel: shapeModel)
            if(self.base.bounds.size != .zero){
                return addCornerShapeNow()
            }
            return nil
        }
        
        return addCornerShapeNow()
    }
    
    private func storeAutoLayoutCornerShapeModel(shapeModel: BLTShapeModel){
        self.base.blt_borderShapeModel = shapeModel
        self.base.blt_isAutoLayoutCornerShape = true
        self.exchangeViewLayoutSubviews()
    }
    
    private func p_addCornerShapeLayer(path: UIBezierPath, autoLayout: Bool = false) -> CAShapeLayer{
        
        if let shapeLayer = self.base.layer.mask as? CAShapeLayer, shapeLayer.bounds.size == self.base.bounds.size{
            return shapeLayer
        }
        
        if let _ = self.base.layer.mask{
            self.base.layer.mask = nil;
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.base.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        self.base.layer.mask = shapeLayer
        self.base.blt_isAutoLayoutBorder = autoLayout
        return shapeLayer
    }
}


/// 处理不规则形状的贝塞尔曲线的
extension BLTNameSpace where Base: UIView{
    ///每个角半径都相同的贝塞尔曲线
    public func cornerShapePath(_ cornerRadius: CGFloat, roundCorners:UIRectCorner = .allCorners) -> UIBezierPath{
        let path = UIBezierPath.init(roundedRect: self.base.bounds, byRoundingCorners: roundCorners, cornerRadii: .init(width: cornerRadius, height: cornerRadius))
        return path
    }
    
    /// 每个角不相同的贝塞尔曲线
    public func differentCornerRadiusPath(_ leftTopRadius: CGFloat, _ rightTopRadius: CGFloat, _ leftBottomRadius: CGFloat, _ rightBottomRadius: CGFloat, lineWidth: CGFloat = 1) -> UIBezierPath{
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




/// 交换方法的
extension BLTNameSpace where Base: UIView{
    func exchangeViewLayoutSubviews() {
        var objClass: AnyClass = UIView.self
        if self.base is UIButton{
            objClass = UIButton.self
        }
        BLTOnceExecuteManager.executeTask(task: {
            UIView.exchangeLayoutSubviewsMethod()
            if self.base is UIButton{
                UIButton.exchangeButtonLayoutSubviewsMethod()
            }else{
                UIView.exchangeLayoutSubviewsMethod()
            }
        }, onceIdentifier: "\(objClass.description()) exchangeViewLayoutSubviews")
    }
}

///渐变色用的
fileprivate extension UIView{
    
    static func exchangeLayoutSubviewsMethod(){
        swizzlingMethodSwift(UIView.self, #selector(layoutSubviews), #selector(blt_layoutSubviews))
    }
    
    @objc func blt_layoutSubviews(){
        self.blt_layoutSubviews()
        refreshGradientLayerIfNeeded()
        refreshBorderLayerIfNeeded()
        refreshCornerShapeLayerIfNeeded()
    }
    
    func refreshGradientLayerIfNeeded(){
        if let gradientLayer = self.blt_gradientLayer, self.blt_isAutoLayoutGradient, self.bounds.size != gradientLayer.bounds.size {
            //        消除layer的隐式动画 UIView performWithoutAnimation消除不了 使用事务
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer.frame = self.bounds
            CATransaction.commit()
        }
    }
    
    
    /// 画边框
    private func refreshBorderLayerIfNeeded(){
        
        func refreshBorderWithLayer(shapeModel: BLTShapeModel){
            if let cornerRadius = shapeModel.cornerRadius, cornerRadius != 0, let corners = shapeModel.roundCorners{
                self.blt.addCornerBorder(cornerRadius: cornerRadius, roundCorners: corners, borderColor: shapeModel.borderColor, lineWidth: shapeModel.lineWidth)
            }else{
                self.blt.addDifferentCornerRadiusBorder(shapeModel.leftTopRadius, shapeModel.rightTopRadius, shapeModel.leftBottomRadius, shapeModel.rightBottomRadius, borderColor: shapeModel.borderColor, lineWidth: shapeModel.lineWidth)
            }
        }
        
        guard self.blt_isAutoLayoutBorder, let shapeModel = self.blt_borderShapeModel else {
            return
        }
        
        /// 没有画过形状边框
        guard let borderLayer = self.blt_borderShapeLayer  else {
           refreshBorderWithLayer(shapeModel: shapeModel)
            return
        }
        
        ///画过边框  判断bound的size是否变化
        guard self.bounds.size != borderLayer.bounds.size else {
            return
        }
        refreshBorderWithLayer(shapeModel: shapeModel)
        
    }
    
    /// 画形状
    private func refreshCornerShapeLayerIfNeeded(){
        
        func refreshCornerShapeWithLayer(shapeModel: BLTShapeModel){
            if let cornerRadius = shapeModel.cornerRadius, cornerRadius != 0, let corners = shapeModel.roundCorners{
                self.blt.addCornerShape(cornerRadius, roundCorners: corners)
            }else{
                self.blt.addDifferentCornerShape(shapeModel.leftTopRadius, shapeModel.rightTopRadius, shapeModel.leftBottomRadius, shapeModel.rightBottomRadius)
            }
        }
        
        guard self.blt_isAutoLayoutCornerShape, let shapeModel = self.blt_borderShapeModel else {
            return
        }
        
        /// 没有画过形状边框
        guard let borderLayer = self.layer.mask  else {
            print("LBLog border 还没画过------ \(self.frame)")
            refreshCornerShapeWithLayer(shapeModel: shapeModel)
            return
        }
        
        ///画过边框  判断bound的size是否变化
        guard self.bounds.size != borderLayer.bounds.size else {
            return
        }
        print("LBLog border 已经画过， 刷新------")
        refreshCornerShapeWithLayer(shapeModel: shapeModel)
        
    }
    
}



fileprivate extension UIButton{
    
    static func exchangeButtonLayoutSubviewsMethod(){
        swizzlingMethodSwift(UIButton.self, #selector(layoutSubviews), #selector(blt_ButtonLayoutSubviews))
    }
    
    @objc func blt_ButtonLayoutSubviews(){
        super.layoutSubviews()
        self.blt_ButtonLayoutSubviews()
    }
}
