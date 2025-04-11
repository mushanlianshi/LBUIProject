//
//  BLTImageContentCell.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/3/31.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import UIKit

fileprivate let lineHeight = 1 / UIScreen.main.scale

open class BLTImageContentModel{
    public var title: String = ""
    public var desc: String?
    public var extraData: Any?
    public var image: UIImage?
    public var imageUrl: String?
    
    public convenience init(title: String, image: UIImage?, desc: String? = nil,imageUrl: String? = nil, extraData: Any?) {
        self.init()
        self.title = title
        self.image = image
        self.desc = desc
//        self.imageUrl = imageUrl
        self.extraData = extraData
    }
    public required init(){
        
    }
}

//左边是图片     右边箭头   中间可以是title+desc的
open class BLTImageContentCell: BLTCommonListCell<BLTImageContentModel> {
    lazy var leftImageIV: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15){
        didSet{
            stackView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview().inset(self.contentInset)
            }
        }
    }
    
    var lineInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0){
        didSet{
            lineView.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(lineInset.left)
                make.right.equalToSuperview().offset(lineInset.right)
                make.bottom.equalToSuperview().offset(lineInset.bottom)
                make.height.equalTo(lineHeight)
            }
        }
    }
    
    var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .horizontal, distribution: .fill, alignment: .center)
    var verticalStackView = UIStackView.blt.initStackView(spacing: 5, axis: .vertical, distribution: .fill, alignment: .fill)
    var titleLab = UILabel.blt.initWithText(text: "", font: .blt.normalFont(15), textColor: .blt.threeThreeBlackColor())
    var contentLab = UILabel.blt.initWithText(text: "", font: .blt.normalFont(13), textColor: .blt.ninenineBlackColor())
    var arrowIV = UIImageView()
    
    
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
        arrowIV.image = UIImage(named: "public_right_arrow")
        contentView.backgroundColor = .white
        contentView.addSubview(stackView)
        contentLab.numberOfLines = 0;
        titleLab.numberOfLines = 0;
        
        stackView.addArrangedSubview(leftImageIV)
        stackView.addArrangedSubview(verticalStackView)
        stackView.addArrangedSubview(arrowIV)
        
        verticalStackView.addArrangedSubview(titleLab)
        verticalStackView.addArrangedSubview(contentLab)
        
        self.contentView.addSubview(lineView)
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(self.contentInset)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(lineInset.left)
            make.right.equalToSuperview().offset(lineInset.right)
            make.bottom.equalToSuperview().offset(lineInset.bottom)
            make.height.equalTo(lineHeight)
        }
        
        arrowIV.setContentHuggingPriority(.required, for: .horizontal)
        arrowIV.setContentCompressionResistancePriority(.required, for: .horizontal)
        leftImageIV.setContentHuggingPriority(.required, for: .horizontal)
        leftImageIV.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        verticalStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        verticalStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var itemModel: BLTImageContentModel?{
        didSet{
            guard let model = itemModel else { return }
            titleLab.text = model.title
            if let desc = model.desc, desc.isEmpty == false{
                contentLab.isHidden = false
            }else{
                contentLab.isHidden = true
            }
            contentLab.text = model.desc
            if let _ = model.image{
                leftImageIV.isHidden = false
            }else{
                leftImageIV.isHidden = true
            }
            leftImageIV.image = model.image
        }
    }
    
}
