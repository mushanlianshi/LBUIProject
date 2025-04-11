//
//  XLMSiftItemModel.swift
//  MobileHotel
//
//  Created by liu bin on 2025/2/10.
//  Copyright © 2025 ethank. All rights reserved.
//

import Foundation

/// 筛选的模型
public class XLMSiftItemModel: NSObject{
    public var title = ""
    public var selected = false
    
    public init(title: String = "", selected: Bool = false) {
        self.title = title
        self.selected = selected
    }
}
