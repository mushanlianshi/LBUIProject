//
//  BLTCollectionSectionHeaderTextView.swift
//  chugefang
//
//  Created by liu bin on 2023/2/1.
//  Copyright © 2023 baletu123. All rights reserved.
//

import UIKit

///只是文本展示的textView
public class BLTCollectionSectionHeaderTextView: UICollectionReusableView{
    
    public lazy var titleLab: UILabel = {
        let label = UILabel.blt.initWithText(text: nil, font: .blt.mediumFont(16), textColor: .blt.sixsixBlackColor())
        label.numberOfLines = 0
        return label
    }()
    
    public func refreshText(text: String?, textColor: UIColor? = nil, font: UIFont? = nil, contentInset: UIEdgeInsets? = nil){
        titleLab.text = text
        if let color = textColor{
            titleLab.textColor = color
        }
        
        if let textFont = font{
            titleLab.font = textFont
        }
        
        if let inset = contentInset{
            titleLab.snp.remakeConstraints { make in
                make.edges.equalTo(inset)
            }
        }
    }
    
    public func refreshLabelPositionInsets(insets: UIEdgeInsets){
        titleLab.snp.remakeConstraints { make in
            make.edges.equalTo(insets)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
