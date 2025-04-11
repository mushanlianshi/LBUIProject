//
//  URL+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//

import Foundation
extension URL: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == URL{
//    下采样图片  减少内存占用空间
    public func downsampleImage(to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let imageSourcesOptions = [kCGImageSourceShouldCache : false] as NSDictionary
        
        let imageSource = CGImageSourceCreateWithURL(base as CFURL, imageSourcesOptions)!
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels,
        ] as CFDictionary
        
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions)!
        return UIImage(cgImage: downsampledImage)
    }
}
