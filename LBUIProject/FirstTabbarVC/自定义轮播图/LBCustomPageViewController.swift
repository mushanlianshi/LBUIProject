//
//  LBCustomPageViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/26.
//

import UIKit
import FSPagerView
import BLTUIKitProject

//自定义轮播图
class LBCustomPageViewController: UIViewController {
    
    fileprivate let sectionTitles = ["设置", "距离", "item尺寸", "间距", "个数", "翻页动画"]
    fileprivate let configurationTitles = ["自动轮播","无线循环"]
    fileprivate let decelerationDistanceOptions = ["Automatic", "1", "2"]
    fileprivate let imageNames = ["pageView1","pageView2","pageView3","pageView4","pageView5","pageView6","pageView7"]
    fileprivate var numberOfItems = 7
    
    fileprivate let transformerTypes: [FSPagerViewTransformerType] = [.crossFading,
                                                                      .zoomOut,
                                                                      .depth,
                                                                      .linear,
                                                                      .overlap,
                                                                      .ferrisWheel,
                                                                      .invertedFerrisWheel,
                                                                      .coverFlow,
                                                                      .cubic]
    
    var currentAnimationIndex = 0
    
    lazy var pageView: FSPagerView = {
        let view = FSPagerView()
        view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.blt_className)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: .zero, style: .grouped)
        view.delegate = self
        view.dataSource = self
        view.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.blt_className)
        view.register(LBSliderTableCell.self, forCellReuseIdentifier: LBSliderTableCell.blt_className)
        return view
    }()
    
    lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPageIndicatorTintColor = .blue
        view.pageIndicatorTintColor = .lightGray
        view.numberOfPages = self.numberOfItems
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(pageView)
        view.addSubview(tableView)
        pageView.addSubview(pageControl)
        setConstraints()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "自定义", style: .done, target: self, action: #selector(pushCustomPageVC))
    }
    
    @objc private func pushCustomPageVC(){
        self.navigationController?.pushViewController(LBTestPageViewController(), animated: true)
    }
    
    private func setConstraints(){
        pageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(220)
        }
        
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
            make.top.equalTo(pageView.snp_bottom)
        }
        
        pageControl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(10)
        }
    }
    
}


extension LBCustomPageViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return configurationTitles.count
        case 1:
            return decelerationDistanceOptions.count
        case 2,3,4,5:
            return 1
        default:
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.blt_className, for: indexPath)
            cell.textLabel?.text = configurationTitles[indexPath.row]
            if indexPath.row == 0{
                cell.accessoryType = self.pageView.automaticSlidingInterval > 0 ? .checkmark : .none
            }else if indexPath.row == 1{
                cell.accessoryType = self.pageView.isInfinite ? .checkmark : .none
            }
            return cell
        
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.blt_className, for: indexPath)
            cell.textLabel?.text = decelerationDistanceOptions[indexPath.row]
            if indexPath.row == 0{
                cell.accessoryType = self.pageView.decelerationDistance == FSPagerView.automaticDistance ? .checkmark : .none
            }else if indexPath.row == 1{
                cell.accessoryType = self.pageView.decelerationDistance == 1 ? .checkmark : .none;
            }else if indexPath.row == 2{
                cell.accessoryType = self.pageView.decelerationDistance == 2 ? .checkmark : .none;
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: LBSliderTableCell.blt_className, for: indexPath) as! LBSliderTableCell
            cell.sliderView.value = {
                let scale: CGFloat = self.pageView.itemSize.width/self.pageView.frame.width
                let value: CGFloat = (0.5-scale)*2
                return Float(value)
            }()
            cell.valueChanged = {
                [weak self] progress, slider in
                self?.processItemSize(progress: progress)
            }
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: LBSliderTableCell.blt_className, for: indexPath) as! LBSliderTableCell
            cell.sliderView.value = Float(self.pageView.interitemSpacing / 20)
            cell.valueChanged = {
                [weak self] progress, slider in
                self?.pageView.interitemSpacing = -200
//                self?.progressItemMargin(progress: progress)
            }
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: LBSliderTableCell.blt_className, for: indexPath) as! LBSliderTableCell
            cell.sliderView.maximumValue = 1.0
            cell.sliderView.minimumValue = 1.0 / Float(numberOfItems)
            cell.sliderView.value = Float(self.numberOfItems) / 7.0
            cell.valueChanged = {
                [weak self] progress, slider in
                self?.progressItemCounts(progress: progress)
            }
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.blt_className, for: indexPath)
            cell.textLabel?.text = "随机动画"
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section{
        case 0:
            if indexPath.row == 0{
                self.pageView.automaticSlidingInterval = 3.0 - self.pageView.automaticSlidingInterval
            }else if indexPath.row == 1{
                self.pageView.isInfinite = !self.pageView.isInfinite
            }
        case 1:
            if indexPath.row == 0{
                self.pageView.decelerationDistance = FSPagerView.automaticDistance
            }else if indexPath.row == 1{
                self.pageView.decelerationDistance = 1
            }else if indexPath.row == 2{
                self.pageView.decelerationDistance = 2
            }
        case 5:
            self.progressAnimation()
            
        default:
            break
        }
        tableView.reloadSections([indexPath.section], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
    
}


//处理点击事件的
extension LBCustomPageViewController{
//    处理itemSize 0.5 - 1
    func processItemSize(progress: CGFloat){
        let newScale = 0.5 + 0.5 * progress
        let size = self.pageView.frame.size.applying(CGAffineTransform(scaleX: newScale, y: newScale))
        print("LBLog size is \(size)")
        pageView.itemSize = size
    }
    
//    处理margin
    func progressItemMargin(progress: CGFloat){
        let margin = progress * 20
        self.pageView.interitemSpacing = margin
    }
    
//    处理个数
    func progressItemCounts(progress: CGFloat) {
        self.numberOfItems = Int(roundf(Float(progress) * 7))
        self.pageControl.numberOfPages = self.numberOfItems
        self.pageView.reloadData()
    }
    
//    随机动画
    func progressAnimation()  {
        currentAnimationIndex += 1;
        
        let typeIndex = currentAnimationIndex % transformerTypes.count
        
        let type = self.transformerTypes[typeIndex]
        print("LBLog animation type \(type.rawValue) \(typeIndex)")
        self.pageView.transformer = FSPagerViewTransformer(type:type)
        switch type {
        case .crossFading, .zoomOut, .depth:
            self.pageView.itemSize = FSPagerView.automaticSize
            self.pageView.decelerationDistance = 0
        case .linear, .overlap:
            let transform = CGAffineTransform(scaleX: 0.6, y: 0.75)
            self.pageView.itemSize = self.pageView.frame.size.applying(transform)
            self.pageView.decelerationDistance = FSPagerView.automaticDistance
        case .ferrisWheel, .invertedFerrisWheel:
            self.pageView.itemSize = CGSize(width: 180, height: 140)
            self.pageView.decelerationDistance = FSPagerView.automaticDistance
        case .coverFlow:
            self.pageView.itemSize = CGSize(width: 220, height: 170)
            self.pageView.decelerationDistance = FSPagerView.automaticDistance
        case .cubic:
            let transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.pageView.itemSize = self.pageView.frame.size.applying(transform)
            self.pageView.decelerationDistance = 0
        }
    }
}


extension LBCustomPageViewController: FSPagerViewDelegate, FSPagerViewDataSource{
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.blt_className, at: index)
        cell.imageView?.image = UIImageNamed(self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "index \(index)"
        return cell
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.numberOfItems
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        print("LBlog did selected item \(index)")
    }
    
}
