//
//  LYJInitSwiftManager.swift
//  leyouju
//
//  Created by liu bin on 2022/9/9.
//

import Foundation
import Kingfisher
import KingfisherWebP

class LYJInitSwiftManager: NSObject{
    @objc static func initNeededSDK(){
        KingfisherManager.shared.defaultOptions += [
          .processor(WebPProcessor.default),
          .cacheSerializer(WebPSerializer.default)
        ]
        
        let modifier = AnyModifier { request in
            var req = request
            req.addValue("image/webp */*", forHTTPHeaderField: "Accept")
            return req
        }

        KingfisherManager.shared.defaultOptions += [
            .requestModifier(modifier),
            // ... other options
        ]
        
    }
}
