//
//  LBImageMemoryController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/1/6.
//

import UIKit

//Alpha 8 Format:1字节显示1像素，擅长显示单色调的图片。
//Luminance and alpha 8 format: 亮度和 alpha 8 格式，2字节显示1像素，擅长显示有透明度的单色调图片。
//SRGB Format: 4个字节显示1像素。
//Wide Format: 广色域格式，8个字节显示1像素。适用于高精度图片，
//下采样内存峰值 19.8 - 28.6 -> 31 -> 26.3
//不使用下采样 contentsOfFile  19.4 -> 34.4 -> 39.3 -> 34.4  -> 31 会释放内存
//不使用下采样 imageNamed      19.2 -> 34.1 -> 39 -> 34.1     不会释放内存
@objc class LBImageMemoryController: UIViewController {
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(imageView)
        //21.9 -> 25 -> 25
//        testImageNamedCache()
        //21.9 -> 24.8 -> 22.2
//        testFilePathNotCache()
//        21.8 -> 22.4
        testDownloadImage()
    }
    
    
    ///1.图片缓存的内存大小 最终和加载到imageView上的尺寸大小无关
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
//        imageView.frame = view.bounds
    }
    
    
    
    ///测试使用imageNamed 使用缓存的
    func testImageNamedCache() {
        let image = UIImage(named: "test_memory")
        self.imageView.image = image
    }
    
    
    func testFilePathNotCache(){
        let urlPath = Bundle.main.path(forResource: "test_memory_image.jpeg", ofType: nil)
        let url = URL.init(fileURLWithPath: urlPath ?? "")
        let image = UIImage.init(contentsOfFile: urlPath ?? "");
        guard let img = image else { return }
        imageView.image = img
    }
    
    
    func testDownloadImage() {
        let urlPath = Bundle.main.path(forResource: "test_memory_image.jpeg", ofType: nil)
        let url = URL.init(fileURLWithPath: urlPath ?? "")
        let image = UIImage.init(contentsOfFile: urlPath ?? "");
        guard let img = image else { return }
//        imageView.image = UIImage(named: "test_memory")
//        imageView.image = UIImage.init(contentsOfFile: urlPath ?? "")
        imageView.image = downsample(imageAt: url, to: CGSize(width: img.size.width, height: img.size.height), scale: UIScreen.main.scale)
    }
    
    func downsample(imageAt imageURL: URL, to pointSize:CGSize, scale:CGFloat) ->UIImage {
        let imageSourcesOptions = [kCGImageSourceShouldCache: false] as CFDictionary

        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourcesOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize:maxDimensionInPixels
            ] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
     }
    
    
    deinit {
        self.imageView.image = nil
        print("LBLog image memory controller dealloc")
    }

}


