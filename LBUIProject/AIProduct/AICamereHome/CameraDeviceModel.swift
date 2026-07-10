//
//  CameraDeviceModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/9.
//

import Foundation

struct CameraDeviceModel: Identifiable {
    let id: String
    let name: String
    let location: String
    let previewImageName: String
    let isOnline: Bool
}

struct CameraTabItem: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let selectedIconName: String
}
