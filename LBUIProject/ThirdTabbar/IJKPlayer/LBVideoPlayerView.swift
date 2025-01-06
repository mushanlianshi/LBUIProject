//
//  LBVideoPlayerView.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/30.
//

import UIKit
import IJKMediaFramework
import RxSwift

class LBVideoPlayerView: UIView {
    
    lazy var disposeBag = DisposeBag()
    
    private var player: IJKAVMoviePlayerController?
    
    private lazy var toolbar = LBVideoPlayerBottomActionToolBar()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addVideoPlayer()
        addSubview(toolbar)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addVideoPlayer() {
//        let path = Bundle.main.path(forResource: "vlc-record-2024-05-20-15h25m17s-hls.m3u8-.mp4", ofType: nil) ?? ""
        let path = Bundle.main.path(forResource: "butterfly2.mp4", ofType: nil) ?? ""
        
        let options = IJKFFOptions.init()
        guard let url = URL.init(string: path) else { return }
//        guard let url = URL.init(string: "http://121.37.68.98:10080/rtp/31011500011320001339_31011500011320001339/hls.m3u8") else { return }
        
        self.player = IJKAVMoviePlayerController.init(contentURL: url)
        self.player?.view.backgroundColor = .black
        self.player?.prepareToPlay()
        self.player?.shouldAutoplay = true
        self.player?.scalingMode = .aspectFill
//        self.player?.shouldAutoplay = true
        guard let playerView = self.player?.view else { return }
        self.addSubview(playerView)
        NotificationCenter.default.rx.notification(NSNotification.Name.IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: nil).subscribe(onNext:{notification in
            print("LBLog notification IsPreparedToPlayDidChange \(notification)")
            self.refreshReadyUI()
            
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.IJKMPMoviePlayerPlaybackDidFinish, object: nil).subscribe(onNext:{
            [weak self] notification in
            self?.getCurrentPlayerState()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.IJKMPMoviePlayerPlaybackStateDidChange, object: nil).subscribe(onNext:{
            [weak self] notification in
            self?.getCurrentPlayerState()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.IJKMPMoviePlayerLoadStateDidChange, object: nil).subscribe(onNext:{
            [weak self] notification in
            self?.getCurrentPlayerState()
        }).disposed(by: disposeBag)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        player?.view.frame = self.bounds
        toolbar.frame = CGRect(x: 0, y: self.bounds.height - 44, width: self.bounds.width, height: 44)
    }
    
    
    ///准备好  设置状态
    private func refreshReadyUI(){
        print("LBlog duration \(self.player!.duration)")
        print("LBlog naturalSize \(self.player!.naturalSize)")
        self.toolbar.totalTimeLab.text = String(self.player!.duration)
    }
    
    private func getCurrentPlayerState(){
        let state = self.player!.playbackState
//        print("LBLog state \(state)")
    }
}
