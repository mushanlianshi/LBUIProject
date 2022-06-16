//
//  BLTTableViewSectionHeaderTextView.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/5/9.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import Foundation
import BLTUIKitProject
import UIKit

public class BLTTableViewSectionHeaderTextView: UITableViewHeaderFooterView{
    public lazy var titleLab: BLTContentInsetLabel = {
        let label = BLTContentInsetLabel.blt_label(with: UIFontPFMediumFontSize(16), textColor: UIColor.blt.sixsixBlackColor())!
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
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
            titleLab.contentEdgeInsets = inset
        }
        
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
