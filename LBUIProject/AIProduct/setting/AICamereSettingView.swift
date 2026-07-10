//
//  AICamereSettingView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/9.
//

import SwiftUI

// MARK: - Models
struct AICamereSettingSection: Identifiable {
    let id: String
    let header: String?
    let items: [AICamereSettingItem]
}

struct AICamereSettingItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String?
    let value: String?
    let hasArrow: Bool
}

// MARK: - Main View
struct AICamereSettingView: View {
    private let sections: [AICamereSettingSection] = [
        AICamereSettingSection(id: "wifi", header: nil, items: [
            AICamereSettingItem(id: "wifi", icon: "wifi", title: "当前 WiFi", subtitle: "360-DHSJ", value: nil, hasArrow: true),
        ]),
        AICamereSettingSection(id: "device", header: "设备设置", items: [
            AICamereSettingItem(id: "speed", icon: "gauge.with.dots.needle.33percent", title: "云台转速", subtitle: nil, value: "标准", hasArrow: true),
            AICamereSettingItem(id: "timezone", icon: "globe", title: "设备时区", subtitle: nil, value: "GMT+8:00", hasArrow: true),
        ]),
        AICamereSettingSection(id: "function", header: "功能设置", items: [
            AICamereSettingItem(id: "recording", icon: "video.circle", title: "录像设置", subtitle: nil, value: nil, hasArrow: true),
            AICamereSettingItem(id: "calibration", icon: "arrow.triangle.2.circlepath", title: "云台校准", subtitle: nil, value: nil, hasArrow: true),
        ]),
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading,spacing: 12) {
                    headerView.padding(.horizontal, 14)
                    LazyVStack(spacing: 0) {
                        ForEach(sections) { section in
                            sectionView(section)
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Header background
    private var headerView: some View {
        HStack(
            alignment: .center,
            spacing: 15) {
                Image(systemName: "camera").font(.system(size: 30, weight: .bold))
                VStack(alignment: .leading, spacing: 10) {
                    Text("客厅camera").font(.system(size: 16)).foregroundColor(.black)
                    Text("位置：客厅").font(.system(size: 14)).foregroundColor(Color(.systemGray3))
                    Text("version: 1.1.0").font(.system(size: 14)).foregroundColor(Color(.systemGray3))
                }
        }
    }

    // MARK: - Header background
    private var headerBackground: some View {
        VStack(spacing: 0) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0xEB / 255, green: 0xF6 / 255, blue: 0xFB / 255),
                    Color(red: 0xF7 / 255, green: 0xFB / 255, blue: 0xFD / 255),
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
        }
    }

    // MARK: - Section builder
    @ViewBuilder
    private func sectionView(_ section: AICamereSettingSection) -> some View {
        if let header = section.header {
            HStack {
                Text(header)
                    .font(.system(size: 13))
                    .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                    .padding(.leading, 4)
                Spacer()
            }
            .padding(.top, 20)
            .padding(.bottom, 6)
        }

        VStack(spacing: 0) {
            ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                settingRow(item)
                if index < section.items.count - 1 {
                    Divider()
                        .padding(.leading, 50)
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Row
    private func settingRow(_ item: AICamereSettingItem) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: item.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0x52 / 255, green: 0x9B / 255, blue: 0xF3 / 255))
                .frame(width: 30, height: 30)

            // Title + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0x2C / 255, green: 0x2C / 255, blue: 0x2C / 255))

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0x8D / 255, green: 0x8D / 255, blue: 0x8D / 255))
                }
            }

            Spacer()

            // Value
            if let value = item.value {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0x8D / 255, green: 0x8D / 255, blue: 0x8D / 255))
            }

            // Arrow
            if item.hasArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(red: 0xCC / 255, green: 0xCC / 255, blue: 0xCC / 255))
            }
        }
        .padding(.horizontal, 14)
        .frame(minHeight: 50)
    }
}

#Preview {
    AICamereSettingView()
}
