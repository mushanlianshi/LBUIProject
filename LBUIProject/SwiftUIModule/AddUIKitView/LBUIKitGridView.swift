//
//  LBUIKitGridView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/14.
//

import QMUIKit
import SwiftUI

// SwiftUI和UIKit桥梁搭建  SwiftUI包装器
struct LBUIKitGridView: UIViewRepresentable {
    /// 传进来一个可以绑定的selectText， 当内部改变这个selectText时，外面绑定的界面也会被
    @Binding var selectText: String
    /// textList根据外面传进的数据自动驱动
    var textList: [String]
    let selectBlock: ((_ text: String) -> Void)
    
    init(selectText: Binding<String>, textList: [String], selectBlock: @escaping ((_ text: String) -> Void)) {
        self._selectText = selectText
        self.textList = textList
        self.selectBlock = selectBlock
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectText: $selectText, selectBlock: selectBlock)
      }

     /// 进行数据绑定  点击事件等在这个类中处理  自定义视图只负责展示的
    public class Coordinator: NSObject {
        @Binding var selectText: String
        let selectBlock: ((_ text: String) -> Void)
        
          init(selectText: Binding<String>, selectBlock: @escaping ((_ text: String) -> Void)) {
              self._selectText = selectText
              self.selectBlock = selectBlock
          }

          @objc func itemBtnClicked(_ button: UIButton){
              selectText = button.currentTitle ?? ""
              selectBlock(selectText)
          }
      }
    
    func makeUIView(context: Context) -> some UIView {
        let view = QMUIGridView.init(column: 3, rowHeight: 100)!
        textList.forEach { text in
            let button = UIButton.blt.initWithTitle(title: text, font: .blt.normalFont(14), color: .blt.threeThreeBlackColor(), target: context.coordinator, action: #selector(Coordinator.itemBtnClicked(_:)))
//            button.backgroundColor = UIColor.blue;
            view.addSubview(button)
            
        }
        return view
    }
    
    
    /// 在这里面做更新的操作
    func updateUIView(_ uiView: some UIView, context: Context) {
        guard let gridView = uiView as? QMUIGridView else { return }
        // 更新视图的代码（如修改控件的属性等）
        print("LBLog 更新数据 \(textList)")
        gridView.removeAllSubviews()
        textList.forEach { text in
            let button = UIButton.blt.initWithTitle(title: text, font: .blt.normalFont(14), color: .blt.threeThreeBlackColor(), target: context.coordinator, action: #selector(Coordinator.itemBtnClicked(_:)))
//            button.backgroundColor = UIColor.blue;
            gridView.addSubview(button)
        }
    }

}
