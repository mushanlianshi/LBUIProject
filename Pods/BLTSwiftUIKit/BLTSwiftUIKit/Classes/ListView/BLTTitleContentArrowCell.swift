//
//  BLTTitleContentArrowCell.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/3/29.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import Foundation
import HandyJSON
import UIKit
import BLTUIKitProject
import SnapKit

open class BLTTitleContentArrowModel: NSObject, HandyJSON{
    public var title: String?
    public var content: String?
    public var extraData: Any?
    public var image: UIImage?
    
    public convenience init(title: String?, content: String?,image: UIImage? = nil){
        self.init()
        self.title = title
        self.content = content
        self.image = image
    }
    
    required public override init() {
        super.init()
    }
}

open class BLTTitleContentArrowCell: BLTCommonListCell<BLTTitleContentArrowModel>{
    public var contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15){
        didSet{
            stackView.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview().inset(self.contentInset)
            }
        }
    }
    
    public var lineInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0){
        didSet{
            lineView.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(lineInset.left)
                make.right.equalToSuperview().offset(lineInset.right)
                make.bottom.equalToSuperview().offset(lineInset.bottom)
                make.height.equalTo(BLTLineViewHeight())
            }
        }
    }
    
    public var stackView = UIStackView.blt_stackView(withSpacing: 10, distribution: .fill, alignment: .center)!
    public var titleLab = UILabel.blt_label(withTitle: "", font: UIFontPFFontSize(15), textColor: UIColor.blt.threeThreeBlackColor())!
    public var contentLab = UILabel.blt_label(withTitle: "", font: UIFontPFFontSize(15), textColor: UIColor.blt.ninenineBlackColor())!
    public var arrowIV = UIImageView()
    
    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews() {
        arrowIV.image = UIImageNamed("public_right_arrow")
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(stackView)
        contentLab.numberOfLines = 0;
        contentLab.textAlignment = .right;
        titleLab.numberOfLines = 0;
        
        let titleContainerView = UIView()
        titleContainerView.addSubview(titleLab)
        
        let contentContainerView = UIView();
        contentContainerView.addSubview(contentLab);
        
        
        stackView.addArrangedSubview(titleContainerView)
        stackView.addArrangedSubview(contentContainerView)
        stackView.addArrangedSubview(arrowIV)
        self.contentView.addSubview(lineView)
        
        titleLab.snp.makeConstraints { (make) in
            make.edges.equalTo(titleContainerView)
        }
        
        contentLab.snp.makeConstraints { (make) in
            make.edges.equalTo(contentContainerView);
        }
        
        stackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(self.contentInset)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(lineInset.left)
            make.right.equalToSuperview().offset(lineInset.right)
            make.bottom.equalToSuperview().offset(lineInset.bottom)
            make.height.equalTo(BLTLineViewHeight())
        }
        
        arrowIV.setContentHuggingPriority(.required, for: .horizontal)
        arrowIV.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleContainerView.setContentHuggingPriority(.required, for: .horizontal)
        titleContainerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        contentContainerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentContainerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var itemModel: BLTTitleContentArrowModel?{
        didSet{
            guard let model = itemModel else { return }
            titleLab.text = model.title
            contentLab.text = model.content
            guard let image = model.image else { return }
            arrowIV.image = image
        }
    }
}
