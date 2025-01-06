//
//  LBHeaderImageScaleDismissHeaderView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit

///原理 往上滑时  在阈值范围内 修改headerView中的imageView的y值，使其位置一直在视线内，就像变小了一样，
///大于等于阈值时 不做处理  让header自然上去
class LBHeaderImageScaleDismissHeaderView: UIView {
    var imageViewFrame: CGRect = .zero
    
    lazy var imageView: UIImageView = {
        let view = UIImageView.blt_imageView(with: UIImage(named: "scale_header_image"), mode: .scaleAspectFill)!
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        imageViewFrame = bounds
    }
    
    func scrollDidScroll(_ contentOffsetY: CGFloat) {
        ///向上 先缩小  缩小到一定高度就暂停
        guard contentOffsetY < 100 else {
            return
        }
        var imageFrame = imageViewFrame
        ///向下拉  放大图片
            imageFrame.size.height -= contentOffsetY
            imageFrame.origin.y = contentOffsetY
            imageView.frame = imageFrame
        print("LBLog self bounds \(self.frame)  \(imageView.frame)")
    }
}
