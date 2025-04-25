//
//  XLMBookDetailGiftPacketContentView.swift
//  XLMSwiftUIProject
//
//  Created by liu bin on 2025/4/9.
//

import SwiftUI
// 处理@observedObject观察的不是可选的， 导致编译报错的
class LBModelWrapper<T>: ObservableObject {
    @Published var itemModel: T?
}

enum XLMBookDetailGiftPacketType: Int {
    case gold = 1
    case silver
    case xiaomeika
    case diamond
    case other
}

class XLMBookDetailGiftPacketItemModel: ObservableObject {
    var title = ""
    var content = ""
    var selected = false
    var price = ""
    var type: XLMBookDetailGiftPacketType = .gold
    
    init(title: String = "", content: String = "", selected: Bool = false, type: XLMBookDetailGiftPacketType, price: String = "") {
        self.title = title
        self.content = content
        self.selected = selected
        self.type = type
        self.price = price
    }
    
    lazy var textColor: UIColor = {
        switch type {
        case .gold:
            return .blt.hexColor(0xB05617)
        case .silver:
            return .blt.hexColor(0xAF6F3C)
        case .xiaomeika:
            return .blt.hexColor(0x475668)
        case .diamond:
            return .blt.hexColor(0x163367)
        case .other:
            return .blt.hexColor(0xE05943)
        }
    }()
    
    lazy var backImage: UIImage? = {
        switch type {
        case .gold:
            return UIImage(named: "gift_pack_gold")
        case .silver:
            return UIImage(named: "gift_pack_silver")
        case .xiaomeika:
            return UIImage(named: "gift_pack_xiaomeika")
        case .diamond:
            return UIImage(named: "gift_pack_diamond")
        case .other:
            return UIImage(named: "gift_pack_other")
        }
    }()
}

struct XLMBookDetailGiftPacketContentView: View {
    @ObservedObject var itemModelWrapper: LBModelWrapper<XLMBookDetailGiftPacketItemModel>
    
    let detailBlock: ((_ model: XLMBookDetailGiftPacketItemModel) -> Void)
    let selectBlock: ((_ model: XLMBookDetailGiftPacketItemModel) -> Void)
    
    init(wrapper: LBModelWrapper<XLMBookDetailGiftPacketItemModel>, detailBlock: @escaping (_: XLMBookDetailGiftPacketItemModel) -> Void, selectBlock: @escaping (_: XLMBookDetailGiftPacketItemModel) -> Void) {
        self.itemModelWrapper = wrapper
        self.detailBlock = detailBlock
        self.selectBlock = selectBlock
    }
    
    var body: some View {
        return contentView()
    }
    
    func contentView() -> some View{
        guard let itemModel = itemModelWrapper.itemModel else {
            return AnyView(VStack(content: {
                Text("Placeholder")
            }))
        }
        let textColor: Color = Color(itemModel.textColor)
        return AnyView(
            ZStack(alignment: .bottomTrailing) {
                if let image = itemModel.backImage{
                    Image(uiImage: image).resizable(resizingMode: .stretch)
                }
                
                VStack( alignment: .leading, spacing: 8) {
                    Button {
                        detailBlock(itemModel)
                    } label: {
                        HStack (spacing: 6){
                            Text(itemModel.title).foregroundColor(textColor).font(.blt.mediumFont(12))
                            Image(systemName: "chevron.right").foregroundColor(textColor).font(.system(size: 10, weight: .medium))
                        }
                    }
                    Text(itemModel.content).foregroundColor(textColor).font(.blt.mediumFont(10))
                    HStack(spacing: -1) {
                        Text("￥").foregroundColor(.blt.ffRedColor()).font(.blt.normalFont(12))
                        Text(itemModel.price).foregroundColor(.blt.ffRedColor()).font(.blt.mediumFont(16))
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity).padding(10)
                
                Button {
                    selectBlock(itemModel)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(itemModel.selected ? .blt.ffRedColor() : textColor)
                        .font(.system(size: 16))
                }.offset(x: -10, y: -10)

            }
        )
    }
    
}

//#Preview {
//    XLMBookDetailGiftPacketContentView(itemModel: XLMBookDetailGiftPacketItemModel.init(title: "小美卡", content: "房费92折｜免费早餐｜延迟退房", selected: false, type: .other, price: "50")) { model in
//        
//    } selectBlock: { model in
//        model.selected = !model.selected
//        print("LBLog model selected ==== \(model.selected)")
//        
//    }
//
//
//}
