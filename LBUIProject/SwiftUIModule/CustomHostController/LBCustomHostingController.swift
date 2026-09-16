//
//  LBCustomHostingController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/6/29.
//

import SwiftUI

class LBCustomHostingController<Content: View>: UIHostingController<Content> {
    let naviTitle: String?
    init(naviTitle: String? = nil, rootView: Content) {
        self.naviTitle = naviTitle
        super.init(rootView: rootView)
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let naviTitle, naviTitle.isEmpty == false {
            navigationItem.title = naviTitle
        }
//        self.fd_prefersNavigationBarHidden = true
    }
}
