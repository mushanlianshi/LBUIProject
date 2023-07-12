//
//  LBDecoratorModelViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/6.
//

import UIKit


///装饰者模式
///装饰者模式的重点在于增强目标对象功能
class LBDecoratorModelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "装饰者模式"
        view.backgroundColor = .white
        test()
    }
    
    
    ///鞋的原价：500.0
//    打折后价格：425.0
//    满减后的价格：390.0
//    发房优惠券后的价格：340.0
    private func test(){
        var shoes: LBProductProtocol = LBShoesProduct.init(originPrice: 500)
        print("鞋的原价：\(shoes.sellPrice())")
        shoes = LBDiscountDecorator.init(discount: 0.85).createProduct(shoes)
        print("打折后价格：\(shoes.sellPrice())")
        
        shoes = LBFullRefundDecorator(condition: (fullMoney: 200, refundMoney: 35)).createProduct(shoes)
        print("满减后的价格：\(shoes.sellPrice())")
        
        shoes = LBCouponDecorator(condition: (fullMoney: 300, couponAmount: 50)).createProduct(shoes)
        print("发房优惠券后的价格：\(shoes.sellPrice())")
        
    }

}
