//
//  LBNavigationMixRootContainerView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/6/30.
//

import Foundation
import SwiftUI
/**
 * 混合导航栏的，可以使用 每次都用UIKit的方式push新的UIHostViewController
 * let vc = LBCustomHostingController(rootView: page);
 vc.view.backgroundColor = .blt.eeColor()
 vc.navigationItem.title = title
 // 自定义返回按钮，仅显示图标，不显示文字
 let backButton = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
 let currentVC = currentVC ?? Util.getCurrentUIVC()
 currentVC?.navigationItem.backBarButtonItem = backButton
 currentVC?.navigationController?.pushViewController(vc, animated: true)
 */
@available(iOS 16.0, *)
struct LBNavigationMixRootContainerView: View {

    @StateObject private var router = LBNavigationMixAppRouter()
    var body: some View {
        NavigationStack(path: $router.path) {
            LBNavigationMixHomeView()
                .environmentObject(router)
                .navigationDestination(for: LBNavigationMixAppRoute.self) { route in
                    switch route {
                    case .detail(let id):
                        LBNavigationMixDetailView(id: id)
                            .environmentObject(router)

                    case .edit:
                        LBNavigationMixEditView()
                            .environmentObject(router)
                    }
                }
        }
    }
}
