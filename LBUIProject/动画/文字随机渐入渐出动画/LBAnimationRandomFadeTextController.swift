//
//  LBAnimationRandomFadeTextController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/16.
//

import UIKit

///文字随机渐入渐出动画
class LBAnimationRandomFadeTextController: UIViewController {
    
    lazy var fadeLabel: LBRandomFadeAnimationLabel = {
        let label = LBRandomFadeAnimationLabel.blt.initWithFont(font: .blt.normalFont(20), textColor: .blt.threeThreeBlackColor())
        label.numberOfLines = 0
        return label
    }()
    
    var index = 1
    
    var randomTextList = [
        "等我额会哦未回复我噩耗我饿哦豁我饿哈佛未回复额我回复我和佛会务费我饿发货哦我i和哦i我哈佛下达来拿山莨菪碱咯喔黑哦问佛是你哦色佛我诶佛无法",
        "Created by liu bin on 2023/8/16.class LBAnimationRandomFadeTextController: UIViewControlleroverride func viewDidLoad() fadeLabel.snp.makeConstraints",
        "你电脑我滴妈莫德凯撒拉萨的十点多那我拍等你哦你搜到哪我怕额价位呢范围内福禄娃你发来拿我饿冯娜娜年卡了哇饿啦开发拉拉纳你发李文凡",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "文字随机渐入渐出动画"
        view.addSubview(fadeLabel)
        fadeLabel.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(20)
            make.right.equalTo(-20)
        }
        fadeLabel.text = randomTextList.first
        
        fadeLabel.blt_addTap {
            [weak self] in
            self?.changeText()
        }
    }
    
    private func changeText(){
        self.fadeLabel.text = randomTextList[index%randomTextList.count]
        index += 1
    }

}
