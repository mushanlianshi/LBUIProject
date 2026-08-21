//
//  LBShareManagementView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/21.
//

import SwiftUI

// MARK: - 数据模型
struct LBShareItemModel: Identifiable {
    let id = UUID()
    var deviceName: String
    var shareTime: String
    var shareTo: String
    /// true：分享中；false：已取消
    var isSharing: Bool
}

/// 分享管理页（SwiftUI 版）
/// 还原 lanhu 设计稿：https://lanhuapp.com/web/#/item/project/stage?tid=f1bbb63a-34bb-454a-bf44-3ac667b4cd7b&pid=dd61d1c1-a450-47ac-a8fb-c36df2f75c2d
/// 设计稿关键信息：背景 #F4F6F9 / 白色卡片圆角 12 / 图标 66x80 / 设备名 14 #333 / 时间·被分享人 12 #868686
/// 「分享中」浅蓝底 #F3FAFF 蓝字 #0E8AFD /「取消分享」浅橙底 #FFF5F3 橙字 #FD890E /「取消」蓝底白字 68x28
struct LBShareManagementView: View {

    @Environment(\.presentationMode) private var presentationMode

    @State private var items: [LBShareItemModel] = [
        LBShareItemModel(deviceName: "客厅摄像头", shareTime: "分享时间：2026-08-18 10:20", shareTo: "被分享人：张阿姨", isSharing: true),
        LBShareItemModel(deviceName: "阳台摄像头", shareTime: "分享时间：2026-08-01 09:30", shareTo: "被分享人：李叔叔", isSharing: true),
        LBShareItemModel(deviceName: "门口摄像头", shareTime: "分享时间：2026-07-20 15:40", shareTo: "被分享人：王奶奶", isSharing: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach($items) { $item in
                        shareCard(item: $item)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }

    // MARK: - 自定义导航栏（白色背景，返回 + 标题「分享管理」17px）
    private var navBar: some View {
        HStack(spacing: 0) {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Text("分享管理")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
            Spacer()
            // 占位保持标题居中
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 4)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
        }
    }

    // MARK: - 分享卡片
    private func shareCard(item: Binding<LBShareItemModel>) -> some View {
        HStack(spacing: 12) {
            Image("share_camera")
                .resizable()
                .scaledToFit()
                .frame(width: 66, height: 80)

            VStack(alignment: .leading, spacing: 5) {
                Text(item.deviceName.wrappedValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                Text(item.shareTime.wrappedValue)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255))
                Text(item.shareTo.wrappedValue)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255))
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 8) {
                statusTag(isSharing: item.isSharing.wrappedValue)
                if item.isSharing.wrappedValue {
                    cancelButton {
                        item.isSharing.wrappedValue = false
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 状态标签
    @ViewBuilder
    private func statusTag(isSharing: Bool) -> some View {
        if isSharing {
            Text("分享中")
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(red: 0xF3 / 255, green: 0xFA / 255, blue: 0xFF / 255))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        } else {
            Text("取消分享")
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0xFD / 255, green: 0x89 / 255, blue: 0x0E / 255))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(red: 0xFF / 255, green: 0xF5 / 255, blue: 0xF3 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    // MARK: - 取消按钮（蓝底白字 68x28）
    private func cancelButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("取消")
                .font(.system(size: 12))
                .foregroundColor(.white)
                .frame(width: 68, height: 28)
                .background(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

#Preview {
    LBShareManagementView()
}
