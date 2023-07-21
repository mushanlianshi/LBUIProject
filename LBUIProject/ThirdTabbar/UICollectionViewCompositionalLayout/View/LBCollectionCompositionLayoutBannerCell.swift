//
//  LBCollectionCompositionLayoutBannerCell.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/13.
//

import Foundation
import BLTSwiftUIKit

class LBCollectionCompositionLayoutBannerCell: UICollectionViewCell {
    let imageView = UIImageView.blt_imageView(with: nil, mode: .scaleAspectFill)!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class LBCollectionCompositionLayoutTextCell: UICollectionViewCell {
    lazy var titleLab = UILabel.blt.initWithFont(font: .blt.mediumFont(16), textColor: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


class LBCollectionCompositionLayoutListCell: UICollectionViewCell {
    lazy var titleLab = UILabel.blt.initWithFont(font: .blt.normalFont(15), textColor: .blt.threeThreeBlackColor())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLab)
        titleLab.numberOfLines = 0
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
