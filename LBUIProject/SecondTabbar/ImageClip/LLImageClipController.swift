//
//  LLImageClipController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/9/6.
//

import Foundation

/// 旋转图片，让图片始终在框里
class LLImageClipController: UIViewController{
    
    private var nowAngle = 0.0
    private let faceImage = UIImage(named: "face")!
    
    private lazy var imageView: UIImageView = {
         let iv = UIImageView()
        /// 始终保持宽度不被裁剪
         iv.contentMode = .scaleAspectFit
         iv.image = faceImage
         return iv
     }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initNaviItems()
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
            /// 给图片固定高度 不自适应高度
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        DispatchQueue.main.async {
            [weak self] in
            print("LBLog imageview size 222 \(self?.imageView.size)")
            self?.imageView.image = self?.rotateImageWithAngle(0, size: self!.imageView.size, image: self!.faceImage)
        }
        view.layoutIfNeeded()
        imageView.layoutIfNeeded()
        
        print("LBLog imageview size \(imageView.size)")
    }
    
   
    
    private func initNaviItems(){
        let leftBtn = UIButton.blt.initWithTitle(title: "左", font: .blt.normalFont(16), color: .blt.threeThreeBlackColor(), target: self, action: #selector(leftButtonClicked))
        let rightBtn = UIButton.blt.initWithTitle(title: "右", font: .blt.normalFont(16), color: .blt.threeThreeBlackColor(), target: self, action: #selector(rightButtonClicked))
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: leftBtn), UIBarButtonItem(customView: rightBtn)]
    }
    
    
    @objc private func leftButtonClicked() {
        nowAngle -= 10
        let image = rotateImageWithAngle(nowAngle, size: imageView.size, image: faceImage)
        imageView.image = image
    }
    
    @objc private func rightButtonClicked() {
        nowAngle += 10
        let image = rotateImageWithAngle(nowAngle, size: imageView.size, image: faceImage)
        imageView.image = image
    }
    
    /// 旋转图片
    func rotateImageWithAngle(_ angle: CGFloat, size: CGSize, image: UIImage) -> UIImage {
        let backView = UIView.init(frame: .init(origin: .zero, size: size))
        let transform = CGAffineTransformMakeRotation(angle * Double.pi / 180)
        backView.transform = transform
        let rotateSize = backView.size
     
        UIGraphicsBeginImageContextWithOptions(rotateSize, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: rotateSize.width / 2, y: rotateSize.height / 2)
        context?.rotate(by: angle * Double.pi / 180.0)
        context?.scaleBy(x: 1, y: -1.0)
        if let img = image.cgImage{
            context?.draw(img, in: .init(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height), byTiling: false)
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
    
//    - (UIImage  *)rotationImageWithAngle:(CGFloat)angle size:(CGSize)size{
//
//        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
//        CGAffineTransform transform = CGAffineTransformMakeRotation(angle * M_PI / 180.f);
//        backView.transform = transform;
//        CGSize rotatedSize = backView.frame.size;
//
//        UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, self.scale);
//
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextTranslateCTM(context, rotatedSize.width/2, rotatedSize.height/2);
//        CGContextRotateCTM(context, angle * M_PI/180.f);
//        CGContextScaleCTM(context, 1.0, -1.0);
//
//        CGContextDrawImage(context, CGRectMake(-size.width/2, -size.height/2, size.width, size.height), [self CGImage]);
//
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        return newImage;
//    }


}
