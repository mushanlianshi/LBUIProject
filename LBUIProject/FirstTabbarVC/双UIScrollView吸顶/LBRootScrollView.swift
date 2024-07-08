//
//  LBRootScrollView.swift
//  LBUIProject
//
//  Created by liu bin on 2022/5/31.
//

import UIKit

class LBRootScrollView: UIScrollView, UIGestureRecognizerDelegate {
//    可以多手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        //简单处理  直接返回true
//        print("LBLog gesture  %@", gestureRecognizer)
//        print("LBLog other gesture  %@", otherGestureRecognizer)
        return true
    }
}
