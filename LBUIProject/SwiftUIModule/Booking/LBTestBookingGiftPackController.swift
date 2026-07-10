//
//  LBTestBookingGiftPackController.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/4/10.
//

import UIKit
import SwiftUI 

// 包裹一层处理属性后面设置的， 这样就是可选的了，不是创建的时候就必传
class LBTestBookingGiftPackController: UIViewController {
    
    var currentCount = 0
    
    lazy var wrapper = LBModelWrapper<XLMBookDetailGiftPacketItemModel>()
    
    lazy var giftView = XLMBookDetailGiftPacketContentView.init(wrapper: wrapper,detailBlock: { item in
        print("LBLog item is \(item)")
    }, selectBlock: { item in
        print("LBLog select item is \(item)")
    })
    
    @ObservedObject var itemModel = XLMBookDetailGiftPacketItemModel.init(title: "金卡", content: "单位分为", selected: true, type: .silver, price: "50")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let hostVC = UIHostingController(rootView: giftView)
        view.addSubview(hostVC.view)
        hostVC.view.backgroundColor = .lightGray
        hostVC.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(90)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
//            print("LBLog itemModel \(self?.itemModel)")
            self?.wrapper.itemModel = self?.itemModel
            self?.refreshGiftView()
        })
        
    }
    
    func refreshGiftView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            guard let self = self else { return }
            let model = self.itemModel
            model.price = "\(model.price.blt.toInt()! + model.price.blt.toInt()!)"
            model.title = model.title + model.title
            model.selected = !model.selected
            model.type = XLMBookDetailGiftPacketType.init(rawValue: model.type.rawValue + 1) ?? .gold
            self.wrapper.itemModel = self.itemModel
            print("LBLog selected \(model.selected) \(model.title)")
            if self.currentCount < 4{
                self.currentCount += 1
                self.refreshGiftView()
            }
        })
    }
}
