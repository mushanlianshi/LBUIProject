//
//  LBPreviewImageViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/28.
//

import UIKit
import FSPagerView

class LBPreviewImageViewController: UIViewController {
    fileprivate let imageNames = ["pageView1","pageView2","pageView3","pageView4","pageView5","pageView6","pageView7"]

    fileprivate lazy var pageView: FSPagerView = {
        let view = FSPagerView()
        view.register(FSPagerViewCell.self, forCellWithReuseIdentifier: FSPagerViewCell.blt_className)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "仿微信、头条图片预览"
        view.addSubview(pageView)
        pageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.width.equalTo(pageView.snp_height).multipliedBy(16.0 / 9.0)
        }
    }

}


extension LBPreviewImageViewController: FSPagerViewDataSource, FSPagerViewDelegate{
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return imageNames.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: FSPagerViewCell.blt_className, at: index)
        cell.imageView?.image = UIImage(named: self.imageNames[index])
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        cell.textLabel?.text = "index \(index)"
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        BLTPreviewImageManager.previewImage(imageNames.map{ UIImage(named: $0) }.compactMap{ $0 }, originList: nil, currentIndex: index, currentVC: self)
    }
    
}


