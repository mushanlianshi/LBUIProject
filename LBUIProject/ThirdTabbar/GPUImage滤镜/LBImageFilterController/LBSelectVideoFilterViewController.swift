import GPUImage
import Photos
import AVKit

class LBSelectVideoFilterViewController: UIViewController {
    // GPUImage组件
    var movieFile: GPUImageMovie!
    var currentFilter: GPUImageFilter!
    var filterView: GPUImageView!
    
    var movieWriter: GPUImageMovieWriter!
    
    var selectButton: UIButton!
    
    var savedProgress: Float = 0
    var isPaused = false
    
    // 文件路径
    var originalVideoURL: URL?
    var filteredVideoURL: URL?
    var isProcessing = false
    var isPlaying = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(playbackFinished),
                                             name: .AVPlayerItemDidPlayToEndTime,
                                             object: nil)
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopProcessing()
    }
    
    func setupUI() {
        // 初始化滤镜预览视图
        filterView = GPUImageView(frame: .init(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height * 0.7))
        view.addSubview(filterView)
        
        // 添加控制按钮
        selectButton = UIButton(frame: CGRect(x: 20, y: 40, width: 100, height: 40))
        selectButton.setTitle("选择视频", for: .normal)
        selectButton.backgroundColor = .blue
        selectButton.addTarget(self, action: #selector(selectVideo), for: .touchUpInside)
        view.addSubview(selectButton)
        
        // 其他按钮...
        let startItem = UIBarButtonItem(title: "开始 ", style: .done, target: self, action: #selector(startProcessing))
        let saveItem = UIBarButtonItem(title: "保存 ", style: .done, target: self, action: #selector(stopProcessing))
        self.navigationItem.rightBarButtonItems = [startItem, saveItem]
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-BLT_SCREEN_BOTTOM_SAFE_OFFSET() - 10)
            make.height.equalTo(50)
        }
    }
    
    @objc func selectVideo() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension LBSelectVideoFilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        
        guard let videoURL = info[.mediaURL] as? URL else { return }
        selectButton.isHidden = true
        originalVideoURL = videoURL
        
        // 初始化默认滤镜
        currentFilter = GPUImageFilter() // 初始无滤镜
        prepareRecording()
    }

}

extension LBSelectVideoFilterViewController{
    
    func prepareRecording() {
        guard let inputURL = originalVideoURL else { return }
        
        // 1. 创建输出路径（用于最终保存）
        let outputPath = NSTemporaryDirectory() + "filtered_video.mp4"
        filteredVideoURL = URL(fileURLWithPath: outputPath)
        try? FileManager.default.removeItem(at: filteredVideoURL!)
        
        // 2. 初始化GPUImage组件
        movieFile = GPUImageMovie(url: inputURL)
        movieFile.playAtActualSpeed = true
        
        // 3. 设置滤镜链
        currentFilter = GPUImageFilter() // 默认滤镜
        movieFile.addTarget(currentFilter)
        
        // 4. 连接预览视图 - 现在显示的是处理后的视频
        currentFilter.addTarget(filterView)
        
        // 5. 初始化视频写入器（用于保存）
        movieWriter = GPUImageMovieWriter(movieURL: filteredVideoURL!, size: CGSize(width: 720, height: 1280))
        currentFilter.addTarget(movieWriter)
        
        // 6. 配置音频
        movieWriter.shouldPassthroughAudio = true
        movieFile.audioEncodingTarget = movieWriter
        movieFile.enableSynchronizedEncoding(using: movieWriter)
        movieFile.startProcessing()
    }

    @objc func startProcessing() {
        
        // 7. 开始处理
        movieWriter.startRecording()
        isProcessing = true
    }
    
    // 播放完成回调
    @objc func playbackFinished() {
        stopProcessing()
    }

    @objc func stopProcessing() {
        guard isProcessing else { return }
        
        movieFile.endProcessing()
        movieFile.removeAllTargets()
        currentFilter.removeAllTargets()
        
        movieWriter.finishRecording { [weak self] in
            self?.isProcessing = false
            self?.saveToPhotoLibrary()
        }
    }
    
    func saveToPhotoLibrary() {
        guard let outputURL = filteredVideoURL else { return }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
        }) { saved, error in
            DispatchQueue.main.async {
                if saved {
                    print("视频保存成功")
                    self.showAlert(title: "成功", message: "视频已保存到相册")
                } else {
                    print("保存失败: \(error?.localizedDescription ?? "")")
                    self.showAlert(title: "错误", message: "保存失败: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}



extension LBSelectVideoFilterViewController{

    func pauseVideo() {
        guard !isPaused else { return }
        
        // 1. 保存当前进度
        savedProgress = movieFile.progress
        
        // 2. 停止处理
        movieFile.cancelProcessing()
        movieFile.removeAllTargets()
        
        isPaused = true
    }

    func resumeVideo() {
        guard isPaused else { return }
        
        // 1. 重新初始化movieFile（为了从指定位置开始）
        movieFile = GPUImageMovie(url: originalVideoURL!)
        movieFile.playAtActualSpeed = true
        
        
        // 2. 重新连接滤镜链
        movieFile.addTarget(currentFilter)
        currentFilter.addTarget(filterView)
        
        if isProcessing, let writer = movieWriter {
            currentFilter.addTarget(writer)
            movieFile.audioEncodingTarget = writer
            movieFile.enableSynchronizedEncoding(using: writer)
        }
        
        // 3. 开始处理
        movieFile.startProcessing()
        
        isPaused = false
    }
}



extension LBSelectVideoFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource{
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
    
    @IBAction func switchFilter( to filter: GPUImageFilter) {
        if isProcessing {
            // 正在处理时切换滤镜
            movieFile?.removeAllTargets()
            currentFilter?.removeAllTargets()
            
            currentFilter = filter
            movieFile?.addTarget(currentFilter)
            currentFilter.addTarget(filterView)
            currentFilter.addTarget(movieWriter)
        } else {
            // 未处理时只更新预览
            currentFilter = filter
        }
    }
    
}
