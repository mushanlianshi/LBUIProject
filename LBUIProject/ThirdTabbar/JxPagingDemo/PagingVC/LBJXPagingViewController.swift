//
//  LBJXPagingViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/20.
//

import UIKit

protocol LBJXPagingViewProtocol {
    var cateScroll: Bool { get set }
}

extension LBJXPagingViewController: LBJXPagingViewProtocol{
    var cateScroll: Bool{
        get{
            return true
        }
        set (newValue){
            print("LBLog cate Scroll new value \(newValue)")
        }
    }
}

class LBJXPagingViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cateScroll = false
        cacluateProperty = 1
        print("LBLog cate scroll \(self.cateScroll) \(self.cacluateProperty)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            self?.cateScroll = false
            self?.cacluateProperty = 2
            print("LBLog cate scroll \(self?.cateScroll) \(self?.cacluateProperty)")
        }
    }
    
    var cacluateProperty: Int{
        get{
           return 100
        }
        set (newValue){
            print("LBLog new value is \(newValue)")
        }
    }

    lazy var titleList: [String] = {
        let list = ["头部缩放", "主页上拉刷新下拉加载", "列表下拉刷新", "导航栏隐藏", "CollectionView实例", "列表是VC实例", "CategoryView嵌套PagingView", "HeaderView高度改变实例", "headerView高度改变实例（动画）", "悬浮Header位置调整", "滚动延续"]
        return list
    }()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var listCell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if listCell == nil{
            listCell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            listCell?.textLabel?.textColor = .black
        }
        listCell?.textLabel?.text = titleList[indexPath.row]
        return listCell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        var title: String?
        for view in cell!.contentView.subviews {
            if view.isKind(of: UILabel.self) {
                let label = view as! UILabel
                title = label.text
                break
            }
        }
        switch indexPath.row {
        case 0:
            let vc = ZoomViewController()
            vc.title = title
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = RefreshViewController()
            vc.title = title
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = ListRefreshViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = NaviHiddenViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 4:
            let vc = CollectionViewViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 5:
            let vc = VCViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 6:
            let vc = NestViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 7:
            let vc = HeightChangeViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 8:
            let vc = HeightChangeAnimationViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 9:
            let vc = HeaderPositionViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 10:
            let vc = SmoothViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    

}
