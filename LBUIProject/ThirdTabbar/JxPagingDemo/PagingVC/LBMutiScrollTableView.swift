//
//  LBMutiScrollTableView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/21.
//

import UIKit


///Tableview 可以同事滚动的
open class LBMutiScrollTableView: UITableView, UIGestureRecognizerDelegate {
    ///如果是Pan收拾  可以同事响应
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let result = gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        return result
    }
}
