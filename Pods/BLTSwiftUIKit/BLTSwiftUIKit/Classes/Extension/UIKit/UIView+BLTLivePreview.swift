//
//  UIView+BLTLivePreview.swift
//  chugefang
//
//  Created by liu bin on 2022/11/1.
//  Copyright © 2022 baletu123. All rights reserved.
//


import UIKit
import SwiftUI
#if DEBUG
extension UIViewController{
    @available(iOS 13, *)
    private struct Preview: UIViewControllerRepresentable {
        // 用于注入当前的viewcontroller
        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            //
        }
    }
    
    @available(iOS 13, *)
    public func showPreview() -> some View {
        Preview(viewController: self)
    }

}


extension UIView{
    @available(iOS 13, *)
    private struct Preview: UIViewRepresentable {
        typealias UIViewType = UIView
        let view: UIView
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    
    @available(iOS 13, *)
    public func showPreview() -> some View {
        // inject self (the current UIView) for the preview
        Preview(view: self)
    }
}
#endif
