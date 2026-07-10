//
//  LBShareBarCodeView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/9.
//

import SwiftUI

struct LBShareBarCodeView: View {
    @State private var isConfirmed = false

    private let gradientColors = [
        Color(red: 0x4D / 255, green: 0xA2 / 255, blue: 0xFF / 255),
        Color(red: 0x3B / 255, green: 0x82 / 255, blue: 0xEC / 255),
    ]

    var body: some View {
        VStack(spacing: 0) {
            headerArea
            Spacer()
            qrCodeArea
                .padding(.horizontal, 40)
            Spacer()
            bottomArea
        }
        .background(Color.white)
    }

    // MARK: - Header
    private var headerArea: some View {
        VStack(spacing: 16) {
            Text("二维码配网")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))

            Text("向设备的摄像头展示二维码，距离10-30厘米")
                .font(.system(size: 15))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding(.top, 60)
    }

    // MARK: - QR Code
    private var qrCodeArea: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0xE5 / 255, green: 0xE5 / 255, blue: 0xE5 / 255), lineWidth: 1)

                VStack(spacing: 8) {
                    Image(systemName: "qrcode")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                    Text("二维码区域")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .padding(20)
        }
    }

    // MARK: - Bottom
    private var bottomArea: some View {
        VStack(spacing: 20) {
            // Checkbox + text
            HStack(spacing: 8) {
                Button(action: { isConfirmed.toggle() }) {
                    Image(systemName: isConfirmed ? "checkmark.square.fill" : "square")
                        .font(.system(size: 18))
                        .foregroundColor(isConfirmed ? Color(red: 0x3B / 255, green: 0x82 / 255, blue: 0xEC / 255) : Color(red: 0xCC / 255, green: 0xCC / 255, blue: 0xCC / 255))
                }
                Text("我已听到设备发出\"网络连接成功\"")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255))
                Spacer()
            }
            .padding(.horizontal, 28)

            // Next button
            Button(action: {}) {
                Text("下一步")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: gradientColors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .padding(.horizontal, 40)
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    LBShareBarCodeView()
}
