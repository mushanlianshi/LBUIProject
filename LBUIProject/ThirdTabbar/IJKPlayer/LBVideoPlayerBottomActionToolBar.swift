//
//  LBVideoPlayerBottomActionToolBar.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/30.
//

import UIKit


enum LBVideoPlayerBottomAction{
    case playOrPause
    case full
}

fileprivate func imageFromVideoBundle(name: String) -> UIImage?{
    guard let path = Bundle.main.path(forResource: "video_resources", ofType: "bundle") else{
        return nil
    }
    let bundle = Bundle.init(path: path)
    guard let imagePath = bundle?.path(forResource: name + "@2x", ofType: "png") else {
        return nil
    }
    let image = UIImage.init(contentsOfFile: imagePath)
    return image
}

fileprivate extension UIImage {
//    let playImage =
}

class LBVideoPlayerBottomActionToolBar: UIView {
    
    private lazy var stackView = UIStackView.blt_stackView(withSpacing: 10)!
    
    lazy var playOrPauseBtn = UIButton.blt.initWithImage(image: UIImage(named: ""), target: self, action: #selector(playOrPauseButtonClicked))
    
    lazy var currentTimeLab = UILabel.blt.initWithText(text: "00:00", font: .blt.normalFont(12), textColor: .white)
    
    ///用progressview来实现缓冲进度条
    lazy var progressView: UIProgressView = {
       let view = UIProgressView()
        view.progressTintColor = .red
        view.trackTintColor = .lightGray
        view.progress = 0
        return view
    }()
    
    ///来实现播放进度条
    lazy var progressSlider: UISlider = {
        let slider = UISlider.init(frame: .zero)
        slider.value = 0.0
        slider.minimumTrackTintColor = .lightGray
        slider.maximumTrackTintColor = .red
        slider.thumbTintColor = .yellow
        return slider
    }()
    
    lazy var totalTimeLab = UILabel.blt.initWithText(text: "00:00", font: .blt.normalFont(12), textColor: .white)
    
    lazy var fullBtn = UIButton.blt.initWithImage(image: UIImage(named: ""), target: self, action: #selector(fullButtonClicked))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        [playOrPauseBtn, currentTimeLab, progressSlider, totalTimeLab, fullBtn].forEach(stackView.addArrangedSubview(_:))
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints(){
        self.blt.setCompressHugging(lowPriorityViews: [progressSlider], highPriorityViews: [playOrPauseBtn, currentTimeLab, totalTimeLab, fullBtn])
        stackView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(44)
        }
    }
    
    
    
    @objc private func playOrPauseButtonClicked(){
        
    }
    
    
    @objc private func fullButtonClicked(){
        
    }
    
    
}
