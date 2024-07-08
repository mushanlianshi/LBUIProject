//
//  LBListScrollAnimatingController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/14.
//

import UIKit

class LBListScrollAnimatingController: UIViewController {
    
    var contentOffsetY: CGFloat = 0
    var currentTitleLabY: CGFloat = 0
    var hasPin = false

    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()
    
    lazy var headerView = LBListScrollAnimatingHeaderView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "滚动动画的"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}


//8.判断手势或则Scrollview滑动的方向：
//translationInView : 手指在视图上移动的位置（x,y）向下和向右为正，向上和向左为负。
//locationInView ： 手指在视图上的位置（x,y）就是手指在视图本身坐标系的位置。
//velocityInView： 手指在视图上移动的速度（x,y）, 正负也是代表方向，值得一体的是在绝对值上|x| > |y| 水平移动， |y|>|x| 竖直移动。
extension LBListScrollAnimatingController: UIScrollViewDelegate{
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.contentOffsetY = scrollView.contentOffset.y
        ///已经下滑了一点 记录下titleLab在self.view上的位置 便宜在这基础上移动
        if(self.headerView.titleLab.frame.origin.y < 0 && self.headerView.titleLab.superview == self.view){
            self.currentTitleLabY = self.headerView.titleLab.frame.origin.y
        }
//        print("LBLog scrollViewWillBeginDragging \(self.contentOffsetY) \(self.currentTitleLabY)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let point = scrollView.panGestureRecognizer.translation(in: scrollView)
        let point2 = scrollView.panGestureRecognizer.velocity(in: scrollView)
        print("LBLog point2 \(point2.y)")
        let currentOffsetY = scrollView.contentOffset.y
        guard currentOffsetY > 0 else {
            return
        }
//        print("LBLog scrollview \(currentOffsetY)")
        if(currentOffsetY > contentOffsetY){
//            print("向上")
            ///向上  把titleLab添加到headerView上
            if (self.headerView.titleLab.superview != self.headerView){
                self.headerView.addSubview(self.headerView.titleLab)
                self.headerView.titleLab.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.size.width, height: 50)
            }
        }else{
            let offsetY = contentOffsetY - currentOffsetY
//            print("向下 \(offsetY) \(currentOffsetY) \(self.currentTitleLabY)")
            //向下  已经到达headerView上titleLab原本要展示的位置了
            if currentOffsetY < headerView.bounds.height - self.headerView.titleLab.bounds.height{
                if (self.headerView.titleLab.superview != self.headerView){
                    self.headerView.addSubview(self.headerView.titleLab)
                    self.headerView.titleLab.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.size.width, height: 50)
                }
            }else{
                
                ///向下 位置在原来把titleLab添加到self.view上去
                if(self.headerView.titleLab.superview != self.view){
                    self.view.addSubview(self.headerView.titleLab)
                    self.headerView.titleLab.frame.origin.y = -self.headerView.titleLab.height
                    self.currentTitleLabY = -self.headerView.titleLab.height
                }
                
                self.headerView.titleLab.frame = CGRect(x: 0, y:min(self.currentTitleLabY + offsetY, 0), width: self.view.bounds.width, height: self.headerView.titleLab.height)
//                if self.headerView.titleLab.frame.origin.y >= 0{
//                    self.hasPin = true
//                }
            }
        }
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("LBLog scrollViewDidEndDragging ")
        self.currentTitleLabY = self.headerView.titleLab.frame.origin.y
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("LBLOg withVelocity \(velocity.y)")
    }
    
}


extension LBListScrollAnimatingController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "IndexPath \(indexPath.row)";
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    
}
