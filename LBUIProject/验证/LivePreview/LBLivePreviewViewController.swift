//
//  LBLivePreviewViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/24.
//

import UIKit
import SwiftUI
import BLTSwiftUIKit
import PhotosUI

///UIKit 借用swiftUI来实现实时预览
class LBLivePreviewViewController: UIViewController {

    lazy var imageView = UIImageView.blt_imageView(with: UIImage(named: "mask_five_star"), mode: .scaleAspectFill)!
    
    lazy var titleLab = UILabel.blt.initWithText(text: "UIKit 借助SwiftUI来实现实时预览", font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "实时预览"
        self.view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(titleLab)
        self.titleLab.textAlignment = .center
//        titleLab.textAlignment = .center
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.snp_centerY).offset(-imageView.intrinsicContentSize.height / 2)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(imageView.snp_bottom).offset(20)
        }
        
        titleLab.text = "111442122323eeeeee"
        
        let view = PHLivePhotoView()
    }

}



#if DEBUG
@available(iOS 13, *)
struct LBLivePreviewViewController_Preview: PreviewProvider {
    static var previews: some View {
        LBLivePreviewViewController().showPreview()
    }
}
#endif

