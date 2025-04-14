//
//  LBScrollViewInScrollViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/11.
//

import Foundation


class LBMutiGestureScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return true
        }
        return false
    }
}


class LBScrollViewInScrollViewController: UIViewController{
    
    // 最大偏移高度， 默认和headerView的高度一样
    var maxOffsetY = 160.0
    
    var pinHeaderOffsetY = 50.0
    
    lazy var  needOffsetY = maxOffsetY - pinHeaderOffsetY
    
    private lazy var headerView = UIImageView.blt.initWithMode(mode: .scaleAspectFill, image: UIImage(named: "scale_header_image"), cornerRadius: 1)
    
    private lazy var outScrollView: LBMutiGestureScrollView = {
        let scrollView = LBMutiGestureScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    
    private lazy var innerScrollView: LBInnerScrollView = {
        let view = LBInnerScrollView.init(frame: .zero)
        view.scrollViewDidScrollBlock = {
            [weak self] scrollView in
            self?.processInnerScrollViewDidScroll(scrollView)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(outScrollView)
        [headerView, innerScrollView].forEach(outScrollView.addSubview(_:))
        outScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalTo(view)
            make.height.equalTo(maxOffsetY)
        }
        innerScrollView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(self.view)
        }
    }
}


extension LBScrollViewInScrollViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (innerScrollView.innerScrollView.contentOffset.y > 0) {
            //mainTableView的header已经滚动不见，开始滚动某一个listView，那么固定mainTableView的contentOffset，让其不动
            scrollView.contentOffset.y = needOffsetY
        }

        if (scrollView.contentOffset.y < needOffsetY) {
            //mainTableView已经显示了header，listView的contentOffset需要重置
            innerScrollView.innerScrollView.contentOffset.y = 0
        }

        if scrollView.contentOffset.y > needOffsetY && innerScrollView.innerScrollView.contentOffset.y == 0 {
            //当往上滚动mainTableView的headerView时，滚动到底时，修复listView往上小幅度滚动
            scrollView.contentOffset.y = needOffsetY
        }
    }
    
    
    // 内部滑动的 处理外部该偏移的时候偏移，不该偏移的时候停止
    func processInnerScrollViewDidScroll(_ innerScrollView: UIScrollView) {
        if (outScrollView.contentOffset.y < needOffsetY) {
            //回调给代理即将重置子listView的offset
            innerScrollView.contentOffset.y = 0
        } else {
            //mainTableView的header刚好消失，固定mainTableView的位置，显示listScrollView的滚动条
            outScrollView.contentOffset.y = needOffsetY
        }
    }
}
