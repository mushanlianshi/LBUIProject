//
//  LBDeliveryWidgetBundle.swift
//  LBDeliveryWidget
//
//  Created by liu bin on 2026/9/7.
//

import WidgetKit
import SwiftUI

@main
struct LBDeliveryWidgetBundle: WidgetBundle {
    var body: some Widget {
        LBDeliveryLiveActivity()
        LBDeliveryOrderWidget()
    }
}
