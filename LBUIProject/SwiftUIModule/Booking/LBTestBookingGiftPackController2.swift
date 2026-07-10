//
//  LBTestBookingGiftPackController.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/4/10.
//

import UIKit
import SwiftUI

// 根据有模型了在创建view的
class LBTestBookingGiftPackController2: UIViewController {
    
    var giftView: XLMBookDetailGiftPacketContentView2?
    var currentCount = 0
    
    @ObservedObject var itemModel = XLMBookDetailGiftPacketItemModel2.init(title: "金卡", content: "单位分为", selected: true, type: .silver, price: "50")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.addGiftViewIfNeeded(itemModel: self?.itemModel)
            self?.refreshGiftView()
        })
        
    }
    
    func addGiftViewIfNeeded(itemModel: XLMBookDetailGiftPacketItemModel2?) {
        guard giftView == nil else {
            return
        }
        guard let itemModel else {
            return
        }
        giftView = XLMBookDetailGiftPacketContentView2.init(itemModel: itemModel, detailBlock: { item in
            print("LBLog item is \(item)")
        }, selectBlock: { item in
            print("LBLog select item is \(item)")
        })
        let hostVC = UIHostingController(rootView: giftView)
        view.addSubview(hostVC.view)
        hostVC.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(90)
        }
    }
    
    func refreshGiftView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            guard let self = self else { return }
            let model = self.itemModel
            model.price = "\(model.price.blt.toInt()! + model.price.blt.toInt()!)"
            model.title = model.title + "1"
            model.selected = !model.selected
            model.type = XLMBookDetailGiftPacketType2.init(rawValue: model.type.rawValue + 1) ?? .gold
            print("LBLog selected \(model.selected) \(model.title)")
            if currentCount < 3{
                self.currentCount += 1
                self.refreshGiftView()
            }
            
        })
    }
}
