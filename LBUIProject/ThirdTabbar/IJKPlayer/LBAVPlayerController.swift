//
//  LBAVPlayerController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/31.
//

import UIKit
import AVKit
import AudioToolbox

class LBAVPlayerController: UIViewController {
    
    lazy var player: AVPlayer = {
//        let url = URL.init(string: "https://dh2.v.netease.com/2017/cg/fxtpty.mp4")
//        let p = AVPlayer(url: url!)
//        return p
        
        guard let path = Bundle.main.path(forResource: "butterfly", ofType: "avi") else{
            return AVPlayer()
        }
        
        let url = URL(fileURLWithPath: path)
//        let url = URL.init(string: "https://dh2.v.netease.com/2017/cg/fxtpty.mp4")
        let p = AVPlayer(url: url)
        return p
            
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "AVPlayer 播放器"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "播放", style: .done, target: self, action: #selector(playOrPauseVideo))
        initAVPlayer()
        addCollectionPlayer()
        //展示当前支持的音视频格式
        let asset = AVURLAsset.audiovisualTypes()
        print("LBLog asset \(asset)")
//        AVURLAsset.isPlayableExtendedMIMEType("avi")
        //打印asset可以得到（已经转过展示格式）
//        asset type (
//            "audio/aacp",
//            "video/3gpp2",
//            "audio/mpeg3",
//            "audio/mp3",
//            "audio/x-caf",
//            "audio/mpeg",
//            "video/quicktime",
//            "audio/x-mpeg3",
//            "video/mp4",
//            "audio/wav",
//            "video/avi",
//            "audio/scpls",
//            "audio/mp4",
//            "audio/x-mpg",
//            "video/x-m4v",
//            "audio/x-wav",
//            "audio/x-aiff",
//            "application/vnd.apple.mpegurl",
//            "video/3gpp",
//            "text/vtt",
//            "audio/x-mpeg",
//            "audio/wave",
//            "audio/x-m4r",
//            "audio/x-mp3",
//            "audio/AMR",
//            "audio/aiff",
//            "audio/3gpp2",
//            "audio/aac",
//            "audio/mpg",
//            "audio/mpegurl",
//            "audio/x-m4b",
//            "application/mp4",
//            "audio/x-m4p",
//            "audio/x-scpls",
//            "audio/x-mpegurl",
//            "audio/x-aac",
//            "audio/3gpp",
//            "audio/basic",
//            "audio/x-m4a",
//            "application/x-mpegurl"
//        )
        
    }
   

    // 实现 KVO 监听方法
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status", let player = object as? AVPlayer {
            print("LBLog status \(player.status)")
            if player.status == .readyToPlay {
                // AVPlayer 变为 AVPlayerStatusReadyToPlay，执行 preroll 操作
                player.preroll(atRate: 1.0, completionHandler: { (finished) in
                    // preroll 完成后开始播放视频
//                    player.play()
                })
            }
        }
    }

    
    private func initAVPlayer(){
        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        let vc = AVPlayerViewController()
        vc.player = self.player
        view.addSubview(vc.view)
        ///必须addChildVC才可以播放
        addChild(vc)
        vc.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 300)
        self.player.play()
        checkError()
    }
    
    private func checkError(){
        print("LBLog error \(self.player.status)")
        print("LBLog error \(self.player.error)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.checkError()
        })
    }
    
    
    ///把avplayer添加到collectionView上  测试最多可以创建多少个avplayer
    private func addCollectionPlayer(){
        addLBCollectionView(.none)
        self.lb_collectionView?.blt.registerReusableCell(cell: LBAVPlayerCollectionCell.self)
        self.lb_collectionLayout?.minimumLineSpacing = 10
        self.lb_collectionLayout?.minimumInteritemSpacing = 10
        let width = (self.view.bounds.width - 40) / 2
        let height = width * 9 / 16
        self.lb_collectionLayout?.itemSize = CGSize(width: width, height: height)
        self.lb_collectionView?.delegate = self
        self.lb_collectionView?.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.lb_collectionView?.frame = CGRect(x: 0, y: 300, width: self.view.bounds.width, height: self.view.bounds.height - 300)
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "status")
    }

    
    @objc private func playOrPauseVideo(){
        self.player.play()
    }
}


extension LBAVPlayerController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBAVPlayerCollectionCell.self, indexPath: indexPath)
        if indexPath.row == 0{
            cell.videoUrl = "https://www.geektang.cn/proxy_mehaha/1-1%E5%BC%80%E5%AD%A6%E5%85%B8%E7%A4%BC%E5%8F%8A%E8%AF%BE%E7%A8%8B%E6%A6%82%E8%BF%B0%20-%20%E6%89%94%E7%89%A9%E7%BA%BF.mp4?targetUrl=https%3A%2F%2Fwww.geektang.cn%2Falist%2Fd%2Faliyun2%2Fandroid%2F%E6%89%94%E7%89%A9%E7%BA%BF%2FO3q7Hb507UUiaTqLCsxzDiLo1C2xgKWS2o1ch09Q77QXS8GpuOeV7lQ3TfGwW3pJPWyD.tf%3Fsign%3DCi3e5i6bl8NZ0bIIAzPBl2qV_ShnEf5_fByC_IwYDjI%3D%3A0&decrypt=1"
        }else if indexPath.row == 1{
            cell.videoUrl = "https://1500004543.vod2.myqcloud.com/a2771c87vodtranssh1500004543/de22f9e3243791579956583623/v.f1425612.mp4?t=64781f86&sign=cbd6fd97ed8f7329774be76e18cc5bd5"
        }else if indexPath.row == 2{
            cell.videoUrl = "https://1500004543.vod2.myqcloud.com/a2771c87vodtranssh1500004543/45fa391d243791581148282599/v.f1425612.mp4?t=64781f9f&sign=231ee669e056af6ae9898e4be2daf25e"
        }else if indexPath.row == 3{
            cell.videoUrl = "https://1500004543.vod2.myqcloud.com/a2771c87vodtranssh1500004543/d2cb8b023270835009265453375/v.f1425612.mp4?t=6478201b&sign=43dad543d5678737d6301af84dc1adc3"
        }
        else if indexPath.row == 4{
            cell.videoUrl = "https://1500004543.vod2.myqcloud.com/a2771c87vodtranssh1500004543/130053ab3270835009354696763/v.f1425612.mp4?t=64782034&sign=ef68e41be39335dd6bef41c7ed7e9240"
        }
        return cell
    }
    
    
}



class LBAVPlayerCollectionCell: UICollectionViewCell {
    
    var videoUrl: String?{
        didSet{
            guard let url = URL.init(string: videoUrl ?? "") else { return }
            let item = AVPlayerItem(url: url)
            player.pause()
            player.replaceCurrentItem(with: item)
            player.play()
        }
    }
    
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    
    override init(frame: CGRect) {
        player = AVPlayer()
        playerLayer = AVPlayerLayer.init(player: player)
        super.init(frame: frame)
        contentView.backgroundColor = .black
        contentView.backgroundColor = .white
        contentView.layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.videoGravity = .resizeAspectFill
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = self.contentView.bounds
    }
    
    required init?(coder: NSCoder) {
        let stringNumbers = ["1", "2", "3", "foo"]
        let x = stringNumbers.first.map { Int($0) } // Optional(Optional(1))
        let y = stringNumbers.first.flatMap { Int($0) } // Optional(1)
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
