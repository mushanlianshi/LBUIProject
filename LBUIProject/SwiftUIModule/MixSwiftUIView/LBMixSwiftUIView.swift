//
//  LBMixSwiftUIView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import SwiftUI
import Kingfisher

struct LBMixSwiftUIView: View {
    var model: LBTestSwiftUIModel?
    
    
    var body: some View {
        let model = LBTestSwiftUIModel.init(imageUrl: "", name: "3434344ewewe ", desc: "")
        return AnyView(
            VStack(
                spacing: 5,
                content: {
                    HStack(
                        alignment: .center,
                        content: {
                            KFImage(URL.init(string: model.imageUrl ?? ""))
                                .resizable()
                                .frame(width: 100, height: 100)
                                .background(Color.blue.opacity(0.6));
                            
                            VStack(
                                spacing: 10,
                                content: {
                                    Group {
                                        Text(model.name)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.blue)
                                            .padding(.init(top: 12, leading: 25, bottom: 0, trailing: 0))
                                    }.background(Color.yellow);
                                    //                            Spacer(minLength: 10);
                                    if model.desc.isEmpty == false {
                                        Text(model.desc)
                                            .font(.system(size: 14, weight: .thin))
                                            .foregroundColor(Color(UIColor.blt.threeThreeBlackColor()))
                                    }
                                })
                        }).frame(alignment: .leading)
                })
            .frame(width: 300, alignment: .leading)
            .background(Color.red.opacity(0.2))
            .cornerRadius(5)
            .padding(.horizontal, 0)
            //            .padding(.leading, 20)
            //            .padding(.trailing, 10)
            //            .frame(height: 180)
        );
        
    }
    
    func refreshTitleAndDesc(title: String, desc: String) {
        
    }
}

#Preview {
    LBMixSwiftUIView()
}
