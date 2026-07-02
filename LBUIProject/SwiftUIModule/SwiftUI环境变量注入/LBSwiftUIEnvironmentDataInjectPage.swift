//
//  LBSwiftUIEnvironmentDataInjectPage.swift
//  LBUIProject
//
//  Created by liu bin on 2026/6/29.
//

import SwiftUI

// MARK: - 辅助：隐藏 UIKit UINavigationController 的导航栏
struct UIKitNavigationBarHidden: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        DispatchQueue.main.async {
//            view.findNavigationController()?.setNavigationBarHidden(true, animated: false)
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
//            uiView.findNavigationController()?.setNavigationBarHidden(true, animated: false)
        }
    }
}

extension UIView {
    func findNavigationController() -> UINavigationController? {
        var responder: UIResponder? = self.next
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc.navigationController
            }
            responder = r.next
        }
        return nil
    }
}

// MARK: - 环境变量模型1（class，通过 @EnvironmentObject）
class LBAppEnvironmentSettings: ObservableObject {
    @Published var title: String = "初始标题"
    @Published var count: Int = 0
}

// MARK: - 环境变量模型2（struct，通过 @Environment + Binding）
struct LBAppEnvironmentConstValueConfig {
    var title: String = "ConstConfig初始标题"
    var count: Int = 100
}

struct LBAppEnvironmentConstValueConfigKey: EnvironmentKey {
    static let defaultValue: Binding<LBAppEnvironmentConstValueConfig> = .constant(LBAppEnvironmentConstValueConfig())
}

extension EnvironmentValues {
    var constConfig: Binding<LBAppEnvironmentConstValueConfig> {
        get { self[LBAppEnvironmentConstValueConfigKey.self] }
        set { self[LBAppEnvironmentConstValueConfigKey.self] = newValue }
    }
}

// MARK: - 主页面
struct LBSwiftUIEnvironmentDataInjectPage: View {
    @StateObject private var settings = LBAppEnvironmentSettings()
    @State private var constConfig = LBAppEnvironmentConstValueConfig()

    var body: some View {
        NavigationView {
            VStack(spacing: 26) {
                Text("SwiftUI 环境变量注入示例")
                    .font(.headline)
                    .padding(.top, 30)

                VStack(spacing: 8) {
                    Text("LBAppEnvironmentSettings（@EnvironmentObject）:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("标题: \(settings.title)")
                    Text("次数: \(settings.count)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                VStack(spacing: 8) {
                    Text("LBAppEnvironmentConstValueConfig（@Environment + Binding）:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("标题: \(constConfig.title)")
                    Text("次数: \(constConfig.count)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                NavigationLink {
                    EnvironmentModifyPage()
                } label: {
                    Label("按钮1 - 进入修改页面", systemImage: "pencil.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                NavigationLink {
                    EnvironmentDisplayPage()
                } label: {
                    Label("按钮2 - 进入展示页面", systemImage: "eye.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .navigationTitle("环境变量注入")
            .background(UIKitNavigationBarHidden())
//            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .environmentObject(settings)
        .environment(\.constConfig, $constConfig)
    }
}

// MARK: - 修改页面（可读可改）
struct EnvironmentModifyPage: View {
    @EnvironmentObject var settings: LBAppEnvironmentSettings
    @Environment(\.constConfig) var constConfig

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("修改 LBAppEnvironmentSettings:")
                    .font(.headline)

                VStack(spacing: 8) {
                    Text("当前标题: \(settings.title)")
                    Text("当前次数: \(settings.count)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                Button("修改标题（随机数字后缀）") {
                    settings.title = "已修改标题 - \(Int.random(in: 1...100))"
                }
                .buttonStyle(.borderedProminent)

                Button("增加计数") {
                    settings.count += 1
                }
                .buttonStyle(.bordered)

                Divider().padding(.horizontal, 20)

                Text("修改 LBAppEnvironmentConstValueConfig:")
                    .font(.headline)

                VStack(spacing: 8) {
                    Text("当前标题: \(constConfig.wrappedValue.title)")
                    Text("当前次数: \(constConfig.wrappedValue.count)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.teal.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)

                Button("修改Const标题（随机数字后缀）") {
                    var newConfig = constConfig.wrappedValue
                    newConfig.title = "Const已修改 - \(Int.random(in: 1...100))"
                    constConfig.wrappedValue = newConfig
                }
                .buttonStyle(.borderedProminent)

                Button("Const增加计数") {
                    var newConfig = constConfig.wrappedValue
                    newConfig.count += 1
                    constConfig.wrappedValue = newConfig
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical)
        }.navigationBarHidden(true)
        .navigationTitle("修改页面")
    }
}

// MARK: - 展示页面（只读）
struct EnvironmentDisplayPage: View {
    @EnvironmentObject var settings: LBAppEnvironmentSettings
    @Environment(\.constConfig) var constConfig

    var body: some View {
        VStack(spacing: 20) {
            Text("读取环境变量最新值:")
                .font(.headline)

            VStack(spacing: 8) {
                Text("LBAppEnvironmentSettings:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("标题: \(settings.title)")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("次数: \(settings.count)")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text("LBAppEnvironmentConstValueConfig:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("标题: \(constConfig.wrappedValue.title)")
                    .font(.title2)
                    .fontWeight(.medium)
                Text("次数: \(constConfig.wrappedValue.count)")
                    .font(.title2)
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.teal.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }.navigationBarHidden(true)
        .navigationTitle("展示页面")
    }
}

#Preview {
    NavigationView {
        LBSwiftUIEnvironmentDataInjectPage()
    }
}
