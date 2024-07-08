//
//  LBVerticalHorizontalScrollView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/2/17.
//

import UIKit

protocol LBVerticalHorizontalScrollViewDelegate: NSObject {
    func lb_numberOfSections(position: LBVerticalHorizontalScrollPosition) -> Int
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, numberOfRowsInSection section: Int) -> Int
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, didSelectRowAt indexPath: IndexPath)
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, viewForFooterInSection section: Int) -> UIView?
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, viewForHeaderInSection section: Int) -> UIView?
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForFooterInSection section: Int) -> CGFloat
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForHeaderInSection section: Int) -> CGFloat
}


///上下左右滑动  继承ScrollView  可以添加上拉加载 下拉刷新
class LBVerticalHorizontalScrollView: UIScrollView {
    
    private var testProperty: Int = 11
    
    var didScroll: ((_ offset: CGPoint) -> Void)?
    
    weak var lbDelegate: LBVerticalHorizontalScrollViewDelegate?
    
    ///左边上下滑动的宽度
    let leftScrollWidth: CGFloat
    ///右边左右滑动的宽度
    var rightScrollWidth: CGFloat
    
    ///自适应高度的 一般这种联动的用不到
    var leftAutoSizingCellHeight = false{
        didSet{
            guard leftAutoSizingCellHeight else {
                return
            }
            setAutoSizingCellHeight(leftTableView)
        }
    }
    
    var rightAutoSizingCellHeight = false{
        didSet{
            guard leftAutoSizingCellHeight else {
                return
            }
            setAutoSizingCellHeight(leftTableView)
        }
    }
    
    
    override var isDragging: Bool{
        return super.isDragging
    }
    
    ///左边上下滑动的tableView   用来实现上下滑动的  需要联动右边的tableView
    private lazy var leftTableView: UITableView = {
       let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.bounces = false
        view.delegate = self
        view.dataSource = self
       return view
    }()
    
    
    ///右边 左右滑动的scrollView  用来实现左右滑动的
    private lazy var rightScrollView: UIScrollView = {
       let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.bounces = false
        view.delegate = self
        ///不能同事上下和左右滑动  没效果
        view.isDirectionalLockEnabled = true
        return view
    }()


    ///右边上下滑动的tableView  在右边scrollView里面   用来实现上下滑动的   需要联动左边的tableview
    private lazy var rightTableView: UITableView = {
       let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
//        view.bounces = false
        view.delegate = self
        view.dataSource = self
       return view
    }()
    
    init(frame: CGRect, leftScrollWidth: CGFloat, rightScrollWidth: CGFloat) {
        self.leftScrollWidth = leftScrollWidth
        self.rightScrollWidth = rightScrollWidth
        super.init(frame: frame)
        self.delegate = self
        [leftTableView, rightScrollView].forEach(addSubview(_:))
        rightScrollView.addSubview(rightTableView)
//        rightScrollView.isUserInteractionEnabled = false
        
        self.panGestureRecognizer.require(toFail: rightTableView.panGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        leftTableView.frame = CGRect(x: 0, y: 0, width: leftScrollWidth, height: self.bounds.height)
        rightScrollView.frame = CGRect(x: leftScrollWidth, y: 0, width: self.bounds.width - leftScrollWidth, height: self.bounds.height)
        rightTableView.frame = CGRect(x: 0, y: 0, width: rightScrollWidth, height: self.bounds.height)
        rightScrollView.contentSize = CGSize(width: rightScrollWidth, height: self.bounds.height)
    }
    
    
    private func setAutoSizingCellHeight(_ tableView: UITableView){
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
    }
    
}



extension LBVerticalHorizontalScrollView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        print("LBLog istracking \(scrollView.isTracking) \(scrollView.isDragging) \(self.isDragging)")
        if scrollView == self {
            print("LBLog scroll is Self \(scrollView.contentOffset)")
        }else if scrollView == leftTableView{
            print("LBLog scroll is leftTableView \(scrollView.contentOffset)")
        }else if scrollView == rightTableView{
            print("LBLog scroll is rightTableView \(scrollView.contentOffset)")
        }else if scrollView == rightScrollView{
            print("LBLog scroll is rightScrollView \(scrollView.contentOffset)")
        }
        
        
        
        func linkTableViewScroll(){
            if scrollView == leftTableView {
                rightTableView.contentOffset = scrollView.contentOffset
            }else{
                leftTableView.contentOffset = scrollView.contentOffset
            }
        }
        
        ///上下滑动  联动的
        if scrollView == leftTableView || scrollView == rightTableView {
            didScroll?(scrollView.contentOffset)
            let offset = scrollView.contentOffset
            
            ///处理最外面一层的offset 不然上拉 下拉控件就无法展示了
            ///让左右tableView无法下拉更多  让最外层的scrollView去下拉更多
            if (offset.y < 0 || self.contentOffset.y < 0) && self.isTracking  {
                scrollView.contentOffset = CGPoint(x: offset.x, y: 0)
                let point = self.contentOffset
                ///模拟正常tableView的滑动速度
                let y = offset.y / pow(fabs(point.y) + 1, 9.0/40) + point.y
                self.setContentOffset(CGPoint(x: point.x, y: y), animated: false)
                return
            }else if((offset.y + scrollView.bounds.size.height > scrollView.contentSize.height || self.contentOffset.y > 0) && self.isTracking){
                ///保证左右tableView 不上拉更多  让最外面的Scroll去上拉更多
                scrollView.contentOffset = CGPoint(x: offset.x, y: scrollView.contentSize.height - scrollView.bounds.height)
                
                let offsetY = offset.y + scrollView.bounds.size.height - scrollView.contentSize.height
                let point = self.contentOffset
                ///模拟正常tableView的滑动速度
                let y = offsetY / pow(fabs(point.y) + 1, 9.0/40) + point.y
                self.setContentOffset(CGPoint(x: point.x, y: y), animated: false)
                return
            }
            
            ///联动左右两个tableView的
            linkTableViewScroll()
        }
    }
}


extension LBVerticalHorizontalScrollView: UITableViewDelegate, UITableViewDataSource{
    
    private func positionOfTableView(_ tableView: UITableView) -> LBVerticalHorizontalScrollPosition{
        return tableView == leftTableView ? .left : .right
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), tableView: tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return lbDelegate?.lb_numberOfSections(position: positionOfTableView(tableView)) ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), numberOfRowsInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lbDelegate?.lb_tableView(position: positionOfTableView(tableView), didSelectRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), viewForFooterInSection: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), viewForHeaderInSection: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == leftTableView && leftAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        if tableView == rightTableView && rightAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), heightForRowAt: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == leftTableView && leftAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        if tableView == rightTableView && rightAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), heightForFooterInSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == leftTableView && leftAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        if tableView == rightTableView && rightAutoSizingCellHeight {
            return UITableView.automaticDimension
        }
        return lbDelegate?.lb_tableView(position: positionOfTableView(tableView), heightForHeaderInSection: section) ?? 0
    }
    
}


extension LBVerticalHorizontalScrollView: UIGestureRecognizerDelegate{
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
}

enum LBVerticalHorizontalScrollPosition: Int {
    case left = 1
    case right = 2
}


extension LBVerticalHorizontalScrollViewDelegate{
    func lb_numberOfSections(position: LBVerticalHorizontalScrollPosition) -> Int{
        return 1
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, didSelectRowAt indexPath: IndexPath){
        
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, viewForFooterInSection section: Int) -> UIView?{
        return nil
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, viewForHeaderInSection section: Int) -> UIView?{
        return nil
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 44
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForFooterInSection section: Int) -> CGFloat{
        return 0
    }
    
    func lb_tableView(position: LBVerticalHorizontalScrollPosition, heightForHeaderInSection section: Int) -> CGFloat{
        return 0
    }
}
