//
//  LBLivePreviewViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/24.
//

import UIKit
import SwiftUI
import PhotosUI
import SnapKit
import SMSwiftBasicKit

///UIKit 借用swiftUI来实现实时预览
class LBLivePreviewViewController: UIViewController {
    lazy var imageView: UIImageView = {
        let image = UIImage.blt.imageWithSystemColorSymbols(name: "square.and.arrow.up", color: .red, pointSize: 35, weight: .medium)
        let iv =  UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: image)
        iv.backgroundColor = .systemGray6.withAlphaComponent(0.5)
        return iv
    }()
    
    lazy var titleLab = UILabel.blt.initWithText(text: "UIKit 借助SwiftUI来实现实时预览", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    lazy var contentLab = UILabel.blt.initWithText(text: "UIKit 借助SwiftUI来实现实时预览", font: .blt.mediumFont(15), textColor: .blt.ninenineBlackColor(), textAlignment: .center)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "实时预览"
        self.view.backgroundColor = .white
        debugPrint("LBLog self.imageView .image \(self.imageView.image)")
//        [imageView, titleLab, contentLab].forEach(contentLab.addSubview(_:))
        view.addSubview(imageView)
        view.addSubview(titleLab)
        view.addSubview(contentLab)
        self.titleLab.textAlignment = .center
        titleLab.frame = CGRectMake(0, 0, 300, 100);
        //        titleLab.textAlignment = .center
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
//            make.height.width.equalTo(50)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(imageView.snp_bottom).offset(20)
        }
        
        contentLab.snp.makeConstraints { make in
            make.left.right.equalTo(self.titleLab);
            make.top.equalTo(self.titleLab.snp.bottom).offset(15)
        }
        
        titleLab.text = "111442122323eeeeee让人11"
        
        _ = PHLivePhotoView()
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

