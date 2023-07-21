//
//  LBListScrollAnimatingHeaderView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/14.
//

import UIKit

class LBListScrollAnimatingHeaderView: UIView {

    lazy var imageView = UIImageView.blt_imageView(with: UIImage(named: "pageView1"), mode: .scaleToFill)!
    lazy var titleLab = UILabel.blt.initWithText(text: "titleBar", font: .blt.mediumFont(16), textColor: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.clipsToBounds = true
        titleLab.backgroundColor = .blt.hexColor(0xFFAE3B)
        addSubview(imageView)
        addSubview(titleLab)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        imageView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(150)
        }
        
        titleLab.frame = CGRect(x: 0, y: 150, width: UIScreen.main.bounds.size.width, height: 50)
    }

}
