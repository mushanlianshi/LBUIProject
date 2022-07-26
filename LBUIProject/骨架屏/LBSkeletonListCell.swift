//
//  LBSkeletonListCell.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/22.
//

import Foundation
import UIKit
import BLTUIKitProject
import SkeletonView

struct LBSkeletonListModel {
    var title: String?
    var content: String?
}

class LBSkeletonListCell: UITableViewCell {
    
    var listModel: LBSkeletonListModel?{
        didSet{
            titleLab.text = listModel?.title
            contentLab.text = listModel?.content
        }
    }
    
    lazy var containerView: UIView = {
        let view = UIView.blt_view(withBackgroundColor: .white)!
        view.backgroundColor = .white
        return view
    }()
    
    lazy var iconIV: UIImageView = {
        let imageV = UIImageView()
        imageV.blt_layerCornerRaduis = 5
        imageV.backgroundColor = UIColor.blt.hexColor(0x888888)
        return imageV
    }()
    
    lazy var titleLab: UILabel = {
        let label = UILabel.blt_label(with: UIFontPFFontSize(16), textColor: UIColor.black)!
        return label
    }()
    
    lazy var contentLab: UILabel = {
        let label = UILabel.blt_label(with: UIFontPFFontSize(16), textColor: UIColor.blt.hexColor(0x999999))!
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackView = UIStackView.blt_stackView(withSpacing: 10, distribution: .fill, alignment: .fill, axis: .vertical)!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.blt.hexColor(0xeeeeee)
        contentView.addSubview(containerView)
        containerView.addSubview(iconIV)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLab)
        stackView.addArrangedSubview(contentLab)
        setConstraints()
        setSkeletonConfig()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
        }
        iconIV.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.width.height.equalTo(50)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(iconIV.snp_right).offset(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.bottom.equalTo(-15)
        }
    }
    
    private func setSkeletonConfig(){
        self.isSkeletonable = true
        containerView.isSkeletonable = true
        stackView.isSkeletonable = true
        iconIV.isSkeletonable = true
        titleLab.isSkeletonable = true
        contentLab.isSkeletonable = true
//        渲染两行
        contentLab.skeletonTextNumberOfLines = 2
    }
    
    
}
