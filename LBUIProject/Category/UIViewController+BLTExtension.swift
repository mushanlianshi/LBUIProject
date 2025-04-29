//
//  UIViewController+BLTExtension.swift
//  MobileHotel
//
//  Created by liu bin on 2024/12/16.
//  Copyright © 2024 ethank. All rights reserved.
//

import Foundation
import SMSwiftBasicKit
import TZImagePickerController
import GKPhotoBrowser

extension UIViewController: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIViewController{
    
    func presentFullAlert(_ alertVC: UIViewController) {
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        self.base.definesPresentationContext = true
        self.base.present(alertVC, animated: true)
    }
    
    /// 选择图片
    public func selectImage(maxCount: Int = 1, allowTakePicture: Bool = true, allowPickingImage: Bool = true, completeBlock: ((_ imageList: [UIImage]?) -> Void)?){
        let vc = TZImagePickerController()
        vc.maxImagesCount = maxCount
        vc.barItemTextColor = .white
        vc.statusBarStyle = self.base.preferredStatusBarStyle
        vc.allowTakePicture = allowTakePicture
        vc.allowPickingImage = allowPickingImage
        vc.allowTakeVideo = false
        vc.allowPickingVideo = false
        vc.didFinishPickingPhotosHandle = {
            photoList, assetList, originalPhoto in
            completeBlock?(photoList)
        }
        self.base.present(vc, animated: true)
    }
    
    /// 预览图片 originalList大图List，如果originalList是大图，前面的imageList就是缩略图
    public func previewImage(imageList: [Any], originalList: [Any]? = nil, currentIndex: Int){
        func processImage(photo: GKPhoto, isOriginal: Bool, item: Any){
            if let image = item as? UIImage{
                photo.image = image
            }else if let url = item as? String{
                if url.hasPrefix("http") {
                    if isOriginal {
                        photo.originUrl = URL.init(string: url)!
                    }else{
                        photo.url = URL.init(string: url)!
                    }
                }else{
                    if isOriginal {
                        photo.originUrl = URL.init(fileURLWithPath: url)
                    }else{
                        photo.url = URL.init(fileURLWithPath: url)
                    }
                }
            }
        }
        
        var photoList = [GKPhoto]();
        for (index, item) in imageList.enumerated(){
            let photo = GKPhoto()
            processImage(photo: photo, isOriginal: false, item: item)
            if let list = originalList, list.isEmpty == false, index < list.count {
                processImage(photo: photo, isOriginal: true, item: item)
            }
            photoList.append(photo)
        }
        
        let browser = GKPhotoBrowser.init(photos: photoList, currentIndex: currentIndex)
//        browser.configure.hideStyle = .zoomScale
//        browser.configure.statusBarStyle = .default
//        browser.configure.isStatusBarShow = true
        browser.show(fromVC: self.base)
    }
    
    
    
    
    
}
