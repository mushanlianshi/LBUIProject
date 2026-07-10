//
//  AICamereHomeView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/9.
//

import SwiftUI

struct AICamereHomeView: View {
    @State private var selectedTab = "首页"

    private let devices: [CameraDeviceModel] = [
        CameraDeviceModel(id: "1", name: "房间摄像头", location: "房间", previewImageName: "", isOnline: true),
        CameraDeviceModel(id: "2", name: "阳台摄像头", location: "阳台", previewImageName: "", isOnline: true),
        CameraDeviceModel(id: "3", name: "客厅摄像头", location: "客厅", previewImageName: "", isOnline: false),
        CameraDeviceModel(id: "4", name: "厨房摄像头", location: "厨房", previewImageName: "", isOnline: false),
    ]

    private let tabs: [CameraTabItem] = [
        CameraTabItem(id: "home", title: "首页", iconName: "house", selectedIconName: "house.fill"),
        CameraTabItem(id: "message", title: "消息", iconName: "message", selectedIconName: "message.fill"),
        CameraTabItem(id: "profile", title: "我的", iconName: "person", selectedIconName: "person.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerView
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    welcomeSection
                    ForEach(devices) { device in
                        CameraDeviceCardView(device: device)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
            tabBar
        }
        .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        .edgesIgnoringSafeArea(.bottom)
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("欢迎使用摄像头APP")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255))
                Text("Hi～王西瓜｜2024年2月2日")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                    .padding(.top, 4)
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
//                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                    .foregroundColor(Color(.red))
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(Color.white)
    }

    private var welcomeSection: some View {
        VStack(spacing: 0) {
            EmptyView()
        }
        .frame(height: 0)
    }

    private var tabBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 0) {
                ForEach(tabs) { tab in
                    Button(action: { selectedTab = tab.title }) {
                        VStack(spacing: 2) {
                            Image(systemName: selectedTab == tab.title ? tab.selectedIconName : tab.iconName)
                                .font(.system(size: 22))
                                .foregroundColor(selectedTab == tab.title ? Color(red: 0x33 / 255, green: 0x80 / 255, blue: 0xFF / 255) : Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                            Text(tab.title)
                                .font(.system(size: 10))
                                .foregroundColor(selectedTab == tab.title ? Color(red: 0x33 / 255, green: 0x80 / 255, blue: 0xFF / 255) : Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 49)
            .background(Color.white)
        }
    }
}

#Preview {
    AICamereHomeView()
}
