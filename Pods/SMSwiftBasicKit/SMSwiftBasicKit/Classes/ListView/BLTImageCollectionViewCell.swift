//
//  BLTChooseListView.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2021/8/25.
//  Copyright © 2021 com.wanjian. All rights reserved.
//

import Foundation

open class BLTImageCollectionViewCell: UICollectionViewCell{
    public lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
