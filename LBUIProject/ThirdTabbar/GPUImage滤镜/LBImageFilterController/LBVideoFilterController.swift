//
//  LBVideoFilterController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/27.
//

import UIKit
import GPUImage
import Combine

class LBVideoFilterController: UIViewController {
    
    // GPUImage组件
    var camera: GPUImageVideoCamera!
    // 录制视频写文件的
    var movieWriter: GPUImageMovieWriter!
    // 当前的滤镜
    var currentFilter: GPUImageFilter!
    // 滤镜组
    var filterGroup: GPUImageFilterGroup!
    
    // 文件路径
    var videoURL: URL!
    var isRecording = false
    
    var currentIndexRow = 0
    
    lazy var dataSources: [(title: String, filter: GPUImageFilter.Type)] = [
        ("无滤镜", GPUImageFilter.self),
        ("棕褐色复古", GPUImageSepiaFilter.self),
        ("黑百灰", GPUImageGrayscaleFilter.self),
        ("颜色反转", GPUImageColorInvertFilter.self),
        ("素描效果", GPUImageSketchFilter.self),
        ("卡通效果", GPUImageToonFilter.self),
        //        ("柔和卡通", GPUImageSmoothToonFilter.self),
        ("像素马赛克", GPUImagePixellateFilter.self),
        ("旋涡扭曲", GPUImageSwirlFilter.self),
        ("凸起放大", GPUImageBulgeDistortionFilter.self),
        ("凹陷变形", GPUImagePinchDistortionFilter.self),
        ("高斯模糊", GPUImageGaussianBlurFilter.self),
        ("运动模糊", GPUImageMotionBlurFilter.self),
        ("向外模糊", GPUImageZoomBlurFilter.self),
        ("边缘检测", GPUImageSobelEdgeDetectionFilter.self),
        //        ("高级边缘检测", GPUImageCannyEdgeDetectionFilter.self),
        ("假彩色", GPUImageFalseColorFilter.self),
    ]
    
    private lazy var collectionView: UICollectionView = {
        let col = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 15, miniInterItemSpacing: 15, itemSize: .init(width: 100, height: 50), scrollDirection: .horizontal, delegate: self, dataSource: self)
        col.showsHorizontalScrollIndicator = false
        col.blt.registerReusableCell(cell: LBTagCollectionCell.self)
        return col
    }()
    
    var imageObserverable = CurrentValueSubject<UIImage?, Never>.init(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let startItem = UIBarButtonItem(title: "开始 ", style: .done, target: self, action: #selector(startRecording))
        let saveItem = UIBarButtonItem(title: "保存 ", style: .done, target: self, action: #selector(stopRecording))
        self.navigationItem.rightBarButtonItems = [startItem, saveItem]
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-BLT_SCREEN_BOTTOM_SAFE_OFFSET() - 10)
            make.height.equalTo(50)
        }
        setupCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRecording()
    }
    
    func setupCamera() {
        // 1. 初始化摄像头
        camera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue,
                                     cameraPosition: .back)
        camera.outputImageOrientation = .portrait
        camera.horizontallyMirrorFrontFacingCamera = true
        
        // 2. 初始化默认滤镜
        currentFilter = GPUImageFilter() // 初始化为无滤镜
        
        filterGroup = GPUImageFilterGroup()
        filterGroup.addFilter(currentFilter)
        filterGroup.initialFilters = [currentFilter]
        filterGroup.terminalFilter = currentFilter
        
        // 3. 设置预览
        let preview = GPUImageView(frame: view.bounds)
        view.addSubview(preview)
        filterGroup.addTarget(preview)
        preview.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        
        // 4. 开始捕获
        camera.addTarget(filterGroup)
        camera.startCapture()
    }
}


extension LBVideoFilterController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBTagCollectionCell.self, indexPath: indexPath)
        let item = dataSources[indexPath.row]
        cell.title = item.title
        cell.contentView.backgroundColor = currentIndexRow == indexPath.row ? .systemPink : .blue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != currentIndexRow else {
            return
        }
        currentIndexRow = indexPath.row
        let item = dataSources[indexPath.row]
        let filter = item.filter.init()
        switchFilter(to: filter)
        currentFilter = filter
        collectionView.reloadData()
    }
    
    
}


extension LBVideoFilterController{
    
    func switchFilter(to newFilter: GPUImageFilter) {
        // 1. 暂停摄像头捕获
        camera.pauseCapture()
        
        // 2. 移除旧滤镜
        filterGroup.removeAllTargets()
        //        filterGroup.removeFilter(currentFilter)
        
        // 3. 添加新滤镜
        currentFilter = newFilter
        filterGroup.addFilter(currentFilter)
        filterGroup.initialFilters = [currentFilter]
        filterGroup.terminalFilter = currentFilter
        
        // 4. 重新连接预览和录制
        if let preview = view.subviews.first(where: { $0 is GPUImageView }) as? GPUImageView {
            filterGroup.addTarget(preview)
        }
        
        if isRecording {
            filterGroup.addTarget(movieWriter)
        }
        
        // 5. 恢复捕获
        camera.resumeCameraCapture()
    }
    
    @objc func startRecording() {
        guard isRecording == false else {
            return
        }
        // 1. 创建临时文件路径
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let outputPath = "\(documentsPath)/temp.mp4"
        videoURL = URL(fileURLWithPath: outputPath)
        
        // 2. 删除旧文件（如果存在）
        try? FileManager.default.removeItem(at: videoURL)
        
        // 3. 初始化MovieWriter
        movieWriter = GPUImageMovieWriter(movieURL: videoURL, size: CGSize(width: 720, height: 1280))
        movieWriter.encodingLiveVideo = true
        
        // 4. 添加写入目标
        filterGroup.addTarget(movieWriter)
        camera.audioEncodingTarget = movieWriter
        
        // 5. 开始录制
        movieWriter.startRecording()
        isRecording = true
    }
    
    @objc func stopRecording() {
        guard isRecording else { return }
        
        // 1. 停止录制
        filterGroup.removeTarget(movieWriter)
        camera.audioEncodingTarget = nil
        movieWriter.finishRecording { [weak self] in
            guard let self = self else { return }
            self.isRecording = false
            
            // 2. 保存到相册
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
            }) { saved, error in
                DispatchQueue.main.async {
                    if saved {
                        print("视频保存成功")
                        self.showHintTipContent("视频保存成功")
                    } else {
                        print("保存失败: \(error?.localizedDescription ?? "")")
                        self.showHintTipContent("保存失败: \(error?.localizedDescription ?? "")")
                    }
                }
            }
        }
    }
    
}



class LBTagCollectionCell: UICollectionViewCell{
    
    private lazy var titleLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(16), textColor: .white, textAlignment: .center)
    
    var title: String?{
        didSet{
            titleLab.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //        titleLab.backgroundColor = .blue
        titleLab.blt.addRegularCorner(raduis: 5)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
