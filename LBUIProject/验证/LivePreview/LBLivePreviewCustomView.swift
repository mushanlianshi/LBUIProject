//
//  LBLivePreviewCustomView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/10.
//

import Foundation
import SMSwiftBasicKit
import SnapKit
import SwiftUI

class LBLivePreviewCustomView: UIView {
    lazy var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical)
    lazy var imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage.blt.imageWithSystemColorSymbols(name: "square.and.arrow.up", color: .red, pointSize: 36, weight: .medium))
    lazy var titleLab = UILabel.blt.initWithText(text: "UIKit 借助SwiftUI来实现实时预览title", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    lazy var contentLab = UILabel.blt.initWithText(text: "UIKit 借助SwiftUI来实现实时预览", font: .blt.mediumFont(15), textColor: .blt.ninenineBlackColor(), textAlignment: .center)
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(stackView)
        [imageView, titleLab,contentLab].forEach(stackView.addArrangedSubview(_:))
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        self.blt.setCompressHugging(lowPriorityViews: [contentLab], highPriorityViews: [imageView, titleLab], direction: .vertical)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


#if DEBUG
@available(iOS 13, *)
struct LBLivePreviewCustomView_PreView2: PreviewProvider {
    static var previews: some View {
        LBLivePreviewCustomView().showPreview()
    }
}
#endif
