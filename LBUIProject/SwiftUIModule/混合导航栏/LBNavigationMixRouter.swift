//
//  LBNavigationMixRouter.swift
//  LBUIProject
//
//  Created by liu bin on 2026/6/30.
//

import SwiftUI

import Foundation

enum LBNavigationMixAppRoute: Hashable {
    case detail(id: Int)
    case edit
}

@available(iOS 16.0, *)
final class LBNavigationMixAppRouter: ObservableObject {
    @Published var path = NavigationPath()
    // push
    func push(_ route: LBNavigationMixAppRoute) {
        path.append(route)
    }

    // pop
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    // pop to root
    func popToRoot() {
        path.removeLast(path.count)
    }
}
