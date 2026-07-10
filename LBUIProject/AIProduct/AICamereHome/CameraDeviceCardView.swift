//
//  CameraDeviceCardView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/9.
//

import SwiftUI

struct CameraDeviceCardView: View {
    let device: CameraDeviceModel

    var body: some View {
        VStack(spacing: 0) {
            previewArea
            infoBar
            actionBar
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    private var previewArea: some View {
        ZStack {
            Color(.systemGray5)
            Image(systemName: "video.fill")
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.6))
            playButtonOverlay
        }
        .frame(height: 142)
        .clipped()
    }

    private var playButtonOverlay: some View {
        Image(systemName: "play.circle.fill")
            .font(.system(size: 30))
            .foregroundColor(.white.opacity(0.9))
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }

    private var infoBar: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(device.isOnline ? Color.green : Color.gray)
                .frame(width: 6, height: 6)
            Text(device.name)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                .padding(.leading, 6)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
        }
        .padding(.horizontal, 10)
        .frame(height: 34)
    }

    private var actionBar: some View {
        HStack(spacing: 0) {
            actionItem(icon: "dollarsign.circle", title: "充值")
            Spacer()
            actionItem(icon: "message", title: "消息")
            Spacer()
            actionItem(icon: "square.and.arrow.up", title: "分享")
            Spacer()
            actionItem(icon: "arrowtriangle.right.circle", title: "回放")
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private func actionItem(icon: String, title: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255))
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255))
        }
    }
}

#Preview {
    CameraDeviceCardView(
        device: CameraDeviceModel(
            id: "1",
            name: "房间摄像头",
            location: "房间",
            previewImageName: "",
            isOnline: true
        )
    )
    .padding(.horizontal, 14)
    .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
}
