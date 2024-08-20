//
//  LBDrawerSwiperAnimationView.swift
//  LBUIProject
//
//  Created by liu bin on 2024/8/20.
//

import UIKit

fileprivate let kMaxTableViewHeight = BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - 80

fileprivate let kMinTableViewHeight = 100.0

class LBDrawerSwiperAnimationView: UIView {
    
    lazy var tableView: UITableView = {
        let tab = UITableView()
        tab.delegate = self
        tab.dataSource = self
        tab.rowHeight = 80
        tab.blt.registerReusableCell(cell: UITableViewCell.self)
        return tab
    }()
    
    lazy var dataSources = Array(0...100)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(tableView)
        tableView.frame = .init(x: 0, y: BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - 400, width: UIScreen.main.bounds.width, height: 400)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func panGestureRecognized(_ pan: UIPanGestureRecognizer) {
        let point = pan.velocity(in: self)
        print("LBLog point y \(point.y)")
        switch pan.state {
        case .possible:
            print("LBLog pan state possible ")
        case .began:
            print("LBLog pan state began ")
        case .changed:
            print("LBLog pan state changed ")
        case .ended:
            print("LBLog pan state ended ")
        case .cancelled:
            print("LBLog pan state cancelled ")
        case .failed:
            print("LBLog pan state failed ")
        case .recognized:
            print("LBLog pan state recognized ")
        }
    }
    
    @objc private func tapGestureRecognized(_ tap: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }


}

extension LBDrawerSwiperAnimationView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        guard scrollView == tableView else {
            return
        }
        
        let pan = scrollView.panGestureRecognizer
        
        let point = pan.velocity(in: scrollView)
        
        if point.y == 0{
            return
        }
        
        if point.y > 0  {
            print("LBLog point 向下 is \(point.y)")
            if scrollView.contentOffset.y > 0{
                return
            }
            if scrollView.bounds.height <= kMinTableViewHeight {
                return
            }
        }else{
            print("LBLog point 向上 is \(point.y) \(scrollView.bounds.height) \(kMaxTableViewHeight)")
            guard scrollView.bounds.height < kMaxTableViewHeight else {
                print("LBLog 已经到达最大位置了  return \(kMaxTableViewHeight)")
                return
            }
        }
        
        let offsetY = scrollView.contentOffset.y
        var tableViewY = tableView.frame.minY - offsetY
        tableViewY = max(tableViewY, 80.0)
        scrollView.frame = CGRect(x: 0, y: tableViewY, width: BLT_SCREEN_WIDTH, height: BLT_SCREEN_HEIGHT - BLT_SCREEN_NAVI_HEIGHT - tableViewY)
        scrollView.setContentOffset(.zero, animated: false)
    }
}


extension LBDrawerSwiperAnimationView: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.blt.dequeueReusableCell(indexPath: indexPath)
        cell.textLabel?.text = String(dataSources[indexPath.row])
        return cell
    }
    
    
}
