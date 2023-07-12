//
//  LBDecoratorProduct.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/6.
//

import Foundation


///定义抽象构件： 抽象商品
public protocol LBProductProtocol: AnyObject {
    ///商品的价格
    func sellPrice() -> CGFloat
}

///定义具体构件： 具体商品
class LBShoesProduct: LBProductProtocol {
    private let price: CGFloat
    
    public init(originPrice: CGFloat){
        self.price = originPrice
    }
    
    func sellPrice() -> CGFloat {
        return price
    }
}



///定义抽象装饰者： 创建传参的构造方法  以便增加具体功能
public protocol LBProductDecorator: LBProductProtocol{
    var product: LBProductProtocol? { get set }
    func createProduct(_ product: LBProductProtocol) -> Self
}

///默认实现商品的价格方法
extension LBProductDecorator{
    
    public func createProduct(_ product: LBProductProtocol) -> Self{
        self.product = product
        return self
    }
    
    public func sellPrice() -> CGFloat {
        return product?.sellPrice() ?? 0.0
    }
}


///装饰者A： 打折八五折
class LBDiscountDecorator: LBProductDecorator{
    var product: LBProductProtocol?
    
    let discount: CGFloat
    
//    public func createProduct(_ product: LBDecoratorProductProtocol) {
//        self.product = product
//    }
    
    public init(discount: CGFloat){
        self.discount = discount
    }
    
    public func sellPrice() -> CGFloat {
        guard let p = product else {
            fatalError("please create product before =======")
        }
        
        return discount * p.sellPrice()
    }
        
}



///装饰者B  满200减35
class LBFullRefundDecorator: LBProductDecorator{
    
    let condition: (fullMoney:CGFloat, refundMoney:CGFloat)
    
    var product: LBProductProtocol?
    
    init(condition: (fullMoney:CGFloat, refundMoney:CGFloat)){
        self.condition = condition
    }
    
    func sellPrice() -> CGFloat {
        guard let p = product else {
            fatalError("please create product before =======")
        }
        let price = p.sellPrice()
        
        guard price > condition.fullMoney else{
            return price
        }
        return price - condition.refundMoney
    }
    
}


///装饰者C 满300 发50优惠券
public class LBCouponDecorator: LBProductDecorator{
    
    public var product: LBProductProtocol?
    
    let condition: (fullMoney:CGFloat, couponAmount:CGFloat)
    
    public init(condition: (fullMoney:CGFloat, couponAmount:CGFloat)){
        self.condition = condition
    }
    
    public func sellPrice() -> CGFloat {
        guard let p = product else {
            fatalError("please create product before =======")
        }
        let price = p.sellPrice()
        
        guard price > condition.fullMoney else{
            return price
        }
        return price - condition.couponAmount
    }
}
