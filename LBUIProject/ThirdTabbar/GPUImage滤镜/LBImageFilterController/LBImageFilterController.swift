//
//  LBImageFilterController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/27.
//

import UIKit
import GPUImage
import Combine

class LBImageFilterController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var selectImageBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "选择照片", font: .blt.normalFont(16), color: .white, target: self, action: #selector(selectBtnClicked))
        button.backgroundColor = .blue
        button.contentEdgeInsets = .init(top: 10, left: 30, bottom: 10, right: 30)
        return button
    }()
    
    private lazy var filteredImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.blt_addTap {
            [weak self] in
            self?.selectBtnClicked()
        }
        return iv
    }()
    
    private var currentPicture: GPUImagePicture?  // 当前处理的图片
    private var currentFilter: GPUImageOutput & GPUImageInput = GPUImageSepiaFilter() // 当前滤镜
    
    
    var currentIndexRow = 0
    
    lazy var dataSources: [(title: String, filter: (GPUImageOutput & GPUImageInput).Type)] = [
        ("无滤镜", GPUImageFilter.self),
        ("棕褐色复古", GPUImageSepiaFilter.self),
        ("黑百灰", GPUImageGrayscaleFilter.self),
        ("颜色反转", GPUImageColorInvertFilter.self),
        ("素描效果", GPUImageSketchFilter.self),
        ("卡通效果", GPUImageToonFilter.self),
        ("柔和卡通", GPUImageSmoothToonFilter.self),
        ("像素马赛克", GPUImagePixellateFilter.self),
        ("旋涡扭曲", GPUImageSwirlFilter.self),
        ("凸起放大", GPUImageBulgeDistortionFilter.self),
        ("凹陷变形", GPUImagePinchDistortionFilter.self),
        ("高斯模糊", GPUImageGaussianBlurFilter.self),
        ("运动模糊", GPUImageMotionBlurFilter.self),
        ("向外模糊", GPUImageZoomBlurFilter.self),
        ("边缘检测", GPUImageSobelEdgeDetectionFilter.self),
        ("高级边缘检测", GPUImageCannyEdgeDetectionFilter.self),
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveToAlbum))
        [filteredImageView, selectImageBtn, collectionView].forEach(view.addSubview(_:))
        filteredImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        selectImageBtn.snp.makeConstraints { make in
            make.center.equalTo(filteredImageView)
        }
        
        collectionView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-BLT_SCREEN_BOTTOM_SAFE_OFFSET() - 10)
            make.height.equalTo(50)
        }
        bindUI()
    }

    
    @objc func selectBtnClicked(){
        self.blt.selectImage(maxCount: 1, allowTakePicture: true, allowPickingImage: true) { [weak self] imageList in
            self?.imageObserverable.send(imageList?.first)
        }
    }
    
    
    func bindUI() {
        imageObserverable.sink { [weak self] image in
            guard let self = self else{
                return
            }
            if let image = image{
                filteredImageView.isHidden = false
            }else{
                filteredImageView.isHidden = true
            }
            selectImageBtn.isHidden = !filteredImageView.isHidden
//            previewImage.image = image
            applyCurrentFilter()
        }.store(in: &cancellables)
    }
}


extension LBImageFilterController: UICollectionViewDelegate, UICollectionViewDataSource{
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
        currentFilter = filter
        applyCurrentFilter()
        collectionView.reloadData()
    }
    
    
}


extension LBImageFilterController{
    /// 应用滤镜
    private func applyCurrentFilter() {
        guard let image = self.imageObserverable.value else { return }
        currentPicture = GPUImagePicture(image: image)
        // 清除旧的滤镜
        currentFilter.removeAllTargets()
        // 重新加滤镜
        currentPicture?.addTarget(currentFilter)
        currentFilter.useNextFrameForImageCapture()
        currentPicture?.processImage()
        
        if let filteredImage = currentFilter.imageFromCurrentFramebuffer() {
            filteredImageView.image = filteredImage
        }
    }
    
//    @objc private func changeFilter() {
//        // 简单轮换滤镜
//        if currentFilter is GPUImageSepiaFilter {
//            currentFilter = GPUImageSketchFilter()
//        } else if currentFilter is GPUImageSketchFilter {
//            currentFilter = GPUImageToonFilter()
//        } else {
//            currentFilter = GPUImageSepiaFilter()
//        }
//        
//        applyCurrentFilter()
//    }
    
    
    @objc private func saveToAlbum() {
            guard let filteredImage = filteredImageView.image else { return }
            UIImageWriteToSavedPhotosAlbum(filteredImage, self, #selector(saveImageFinished(_:didFinishSavingWithError:contextInfo:)), nil)
        }

        @objc private func saveImageFinished(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if error == nil {
                print("保存成功 ✅")
                self.showHintTipContent("保存成功 ✅")
            } else {
                print("保存失败 ❌", error!.localizedDescription)
                self.showHintTipContent("保存失败 ❌")
            }
        }
}


