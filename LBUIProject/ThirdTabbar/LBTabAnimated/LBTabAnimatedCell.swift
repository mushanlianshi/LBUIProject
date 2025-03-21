//
//  LBTabAnimatedCell.swift
//  LBUIProject
//
//  Created by liu bin on 2025/3/21.
//

import UIKit
import BLTSwiftUIKit

class LBTabAnimatedCell: UITableViewCell {
    
    private lazy var containerView = UIView.blt.initWithBackgroundColor(color: .white, cornerRadius: 6)
    
    private lazy var hotelIV: UIImageView = {
        let hotelIV = UIImageView.blt.initWithMode(mode: .scaleAspectFill, image: nil, cornerRadius: 5)
        return hotelIV
    }()
    
    private lazy var stackView = UIStackView.blt.initStackView(spacing: 10, axis: .vertical, distribution: .fill, alignment: .fill)
    
    private lazy var titleLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    
    private lazy var contentLab = UILabel.blt.initWithText(text: "", font: .blt.normalFont(15), textColor: .blt.sixsixBlackColor())
    
    private lazy var descLab = UILabel.blt.initWithText(text: "", font: .blt.normalFont(12), textColor: .blt.eeColor())
    
    var cellModel: String?{
        didSet{
            titleLab.text = "我是标题"
            contentLab.text = "我是内容"
            descLab.text = "我是描述"
            hotelIV.kf.setImage(with: URL.init(string: "https://sunmei-sjz.oss-cn-shanghai.aliyuncs.com/prod/merchant/1861225753460674560.png"))
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        contentView.addSubview(containerView)
        contentView.backgroundColor = .blt.eeColor()
        self.backgroundColor = .clear
        [hotelIV, stackView].forEach(containerView.addSubview(_:))
        [titleLab, contentLab, descLab].forEach(stackView.addArrangedSubview(_:))
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15))
        }
        
        hotelIV.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(100)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(hotelIV.snp.right).offset(15)
            make.right.equalTo(-15)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
    }
}
