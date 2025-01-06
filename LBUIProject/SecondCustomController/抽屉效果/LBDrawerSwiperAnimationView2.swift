//
//  LBDrawerSwiperAnimationView2.swift
//  LBUIProject
//
//  Created by liu bin on 2024/8/20.
//

import UIKit

fileprivate let kMaxTopOffsetY = 80.0

fileprivate let kMaxTableViewHeight = BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - kMaxTopOffsetY

fileprivate let kMinTableViewHeight = 100.0

fileprivate let kNormalTableViewHeight = 300.0

class LBDrawerSwiperAnimationView2: UIView {
    
    private var canNotScrollTableViewContent = true
    
    private lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.delegate = self
        tab.dataSource = self
        tab.rowHeight = 80
        tab.blt.registerReusableCell(cell: UITableViewCell.self)
        return tab
    }()
    
    private lazy var dataSources = Array(0...100)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.frame = .init(x: 0, y: BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - kNormalTableViewHeight, width: UIScreen.main.bounds.width, height: kNormalTableViewHeight)
        let pan = tableView.panGestureRecognizer
        pan.addTarget(self, action: #selector(panGestureRecognized(_:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func panGestureRecognized(_ pan: UIPanGestureRecognizer) {
        var startPoint: CGPoint = .zero
        let point = pan.velocity(in: self)
        canNotScrollTableViewContent = false
//        velocity.y<0时向上滚动
        /// 向上，且到达最上面的位置
        if point.y < 0 && reachTopAnimatingPosition(){
            return
        }
        /// 向下 且tableView有偏移量
        else if point.y >= 0.0 && tableView.contentOffset.y > 0{
            return
        }
        
        print("LBLog point y \(point.y)")
        switch pan.state {
        case .possible:
            print("LBLog pan state possible ")
        case .began:
//            print("LBLog pan state began ")
            startPoint = pan.translation(in: self)
        case .changed:
            print("LBLog pan state changed ")
            let nowPoint = pan.translation(in: self)
            changeTableViewHeight(startPoint, nowPoint)
            pan.setTranslation(.zero, in: self)
        case .ended:
            print("LBLog pan state ended ")
            if autoDismissToBottom() {
                return
            }else if autoExpandToTop(){
                return
            }else{
                autoToNormalHeight()
            }
        case .cancelled:
            print("LBLog pan state cancelled ")
        case .failed:
            print("LBLog pan state failed ")
        case .recognized:
            print("LBLog pan state recognized ")
        default:
            print("LBLog pan state \(pan.state) ")
        }
    }
    
    /// 是否到达了最上面动画的位置
    private func reachTopAnimatingPosition() -> Bool{
        if self.tableView.frame.minY <= kMaxTopOffsetY{
            print("LBLog 到达最上面了------")
            return true
        }
        return false
    }
    
    /// 是否达到了最下面的位置
    private func reachBottomAnimatingPosition() -> Bool{
        if self.tableView.frame.minY >= BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - kMinTableViewHeight{
            print("LBLog 到达最底部了------")
            return true
        }
        return false
    }
    
    
    func changeTableViewHeight(_ startPoint: CGPoint, _ nowPoint: CGPoint) {
        let offsetY = nowPoint.y - startPoint.y
        if(offsetY > 0){
//            if reachBottomAnimatingPosition(){
//                return
//            }
        }else{
            if reachTopAnimatingPosition(){
                return
            }
        }
        canNotScrollTableViewContent = true
        let nowY = self.tableView.frame.minY + offsetY
        self.tableView.frame = .init(x: 0, y: nowY, width: BLT_SCREEN_WIDTH, height: self.bounds.height - nowY)
        print("LBLog offsetY is \(canNotScrollTableViewContent) \(offsetY) \(self.tableView.bounds.size)")
    }
    
    /// 如果距离底部的位置 小于100 就认为消失
    private func autoDismissToBottom() -> Bool{
        if self.tableView.frame.minY >= self.bounds.height - kMinTableViewHeight{
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = .init(x: 0, y: BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT, width: BLT_SCREEN_WIDTH, height: 0)
            } completion: { result in
                self.removeFromSuperview()
            }
            return true
        }
        return false
    }
    
    /// 如果tableview的高度大于kNormalTableViewHeight 的1.5倍，就认为要展开
    private func autoExpandToTop() -> Bool{
        if self.tableView.frame.height >= kNormalTableViewHeight * 1.5{
            UIView.animate(withDuration: 0.2) {
                self.tableView.frame = .init(x: 0, y: kMaxTopOffsetY, width: BLT_SCREEN_WIDTH, height: BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - kMaxTopOffsetY)
            } completion: { result in
                
            }
            return true
        }
        return false
    }
    
    
    /// 停止时 自动动画到正常大小
    private func autoToNormalHeight(){
        UIView.animate(withDuration: 0.2) {
            self.tableView.frame = .init(x: 0, y: self.bounds.height - kNormalTableViewHeight, width: BLT_SCREEN_WIDTH, height: kNormalTableViewHeight)
        } completion: { result in
            
        }
    }
    
    
    
    @objc private func tapGestureRecognized(_ tap: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }


}

extension LBDrawerSwiperAnimationView2: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canNotScrollTableViewContent{
            /// 不能有动画，不然会导致滑动不流畅问题
            tableView.setContentOffset(.zero, animated: false)
            return
        }
        print("LBLog tableview 自由滚动----- \(canNotScrollTableViewContent)")
    }
}


extension LBDrawerSwiperAnimationView2: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.blt.dequeueReusableCell(indexPath: indexPath)
        cell.textLabel?.text = String(dataSources[indexPath.row])
        return cell
    }
    
    
}
