//
//  LBNavigationMixPage.swift
//  LBUIProject
//
//  Created by liu bin on 2026/6/30.
//

import Foundation
import SwiftUI



import SwiftUI

@available(iOS 16.0, *)
struct LBNavigationMixHomeView: View {

    @EnvironmentObject var router: LBNavigationMixAppRouter

    var body: some View {

        VStack(spacing: 20) {

            Button("进入详情") {
                router.push(.detail(id: 1))
            }

            Button("进入编辑") {
                router.push(.edit)
            }
        }
        .navigationTitle("Home")
    }
}

@available(iOS 16.0, *)
struct LBNavigationMixDetailView: View {

    @EnvironmentObject var router: LBNavigationMixAppRouter
    let id: Int

    var body: some View {

        VStack(spacing: 20) {

            Text("Detail \(id)")

            Button("下一页") {
                router.push(.edit)
            }

            Button("返回上一页") {
                router.pop()
            }
        }
        .navigationTitle("Detail")
    }
}


@available(iOS 16.0, *)
struct LBNavigationMixEditView: View {

    @EnvironmentObject var router: LBNavigationMixAppRouter

    var body: some View {

        VStack(spacing: 20) {

            Text("edit ")

        }
        .navigationTitle("edit")
    }
}
