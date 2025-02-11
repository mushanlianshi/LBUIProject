//
//  LBCompressVideoUtil.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/5.
//

import AVFoundation
//// https://mp.weixin.qq.com/s?__biz=MjM5MDI3MjA5MQ%3D%3D&mid=2697267472&idx=2&sn=8260857e7fc9201bad8decaf04b0ebe9&chksm=8376f624b4017f32c18186ac4c30ce3e0a22b2ca3d82089c857d5d7ed4c26e6e433f0ac44e5c&mpshare=1&scene=23&srcid=0904cbU12nkK96nGMZwKCHVf%23rd
func compressVideoWithWriter(inputURL: URL, outputURL: URL, targetBitrate: Int, completion: @escaping (Bool, Error?) -> Void) {
    let asset = AVAsset(url: inputURL)
    
    guard let assetTrack = asset.tracks(withMediaType: .video).first else {
        completion(false, NSError(domain: "VideoCompression", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video track found"]))
        return
    }
    
    // 设置 AVAssetWriter 输出设置
    guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
        return
    }
    
    // 设置视频编码设置
    let settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoWidthKey: assetTrack.naturalSize.width,
        AVVideoHeightKey: assetTrack.naturalSize.height,
        AVVideoCompressionPropertiesKey: [
            AVVideoAverageBitRateKey: targetBitrate,
            AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
        ]
    ]
    
    let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
    writerInput.expectsMediaDataInRealTime = true
    writer.add(writerInput)
    
    // 设置视频输入源
    let reader = try? AVAssetReader(asset: asset)
    let videoTrack = asset.tracks(withMediaType: .video).first!
    let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
    reader?.add(readerOutput)
    
    // 开始写入操作
    writer.startWriting()
    reader?.startReading()
    
    writer.startSession(atSourceTime: .zero)
    
    // 在循环中处理帧数据
    writerInput.requestMediaDataWhenReady(on: DispatchQueue.global(qos: .background)) {
        while writerInput.isReadyForMoreMediaData {
            if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                writerInput.append(sampleBuffer)
            } else {
                writerInput.markAsFinished()
                writer.finishWriting {
                    completion(true, nil)
                }
                break
            }
        }
    }
}
