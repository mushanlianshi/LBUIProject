//
//  UIApplication+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/7/22.
//

import Foundation

extension UIApplication: BLTNameSpaceCompatible{}

public extension BLTNameSpace where Base: UIApplication{
    
    static func callMobile(_ mobile: String?){
        guard var phone = mobile, phone.isEmpty == false else { return }
        let prefix = "tel://"
        if phone.contains(prefix) == false{
            phone = prefix + phone
        }
        guard let url = URL.init(string: phone) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey : Any](), completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
}
