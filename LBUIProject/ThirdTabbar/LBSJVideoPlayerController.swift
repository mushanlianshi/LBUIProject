//
//  LBSJVideoPlayerController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/5/20.
//

import UIKit
import SJVideoPlayer
import SnapKit

class LBSJVideoPlayerController: UIViewController {

    lazy var player: SJVideoPlayer = {
        let p = SJVideoPlayer()
        let path = Bundle.main.path(forResource: "vlc-hls.m3u8-.mp4", ofType: nil) ?? ""
//        let path = Bundle.main.path(forResource: "butterfly2.mp4", ofType: nil) ?? ""
//        let url = URL.init(fileURLWithPath: path)
        let url = URL.init(fileURLWithPath: path) 
        let asset = SJVideoPlayerURLAsset.init(url: url)
        p.urlAsset = asset
        return p
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "SJVideoPlayer"
        view.addSubview(player.view)
        player.view.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(200)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
