//
//  LBDrawImageController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/10/13.
//

import Foundation


class LBDrawImageController: UIViewController {
    lazy var circleIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    lazy var arrowIV: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(circleIV)
        self.view.addSubview(arrowIV)
        self.circleIV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(80)
        }
        
        self.arrowIV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.circleIV.snp_bottom).offset(50)
        }
        
        setImage()
    }
    
    private func setImage(){
        let image = LBDrawImageUtil.drawCircleImage(text: "你好", backgroundColor: UIColor.red)
        self.circleIV.image = image
        
        self.arrowIV.image = LBDrawImageUtil.drawBottomArrowImage(text: "金蝶软件园", backgroundColor: UIColor.red)
    }
}
