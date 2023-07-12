//
//  LBIJKPlayerController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/30.
//

import UIKit
import IJKMediaFramework
import WebKit


class LBIJKPlayerController: UIViewController {
    
    lazy var playerView = LBVideoPlayerView()
    
    lazy var webView: WKWebView = {
        let wb = WKWebView.init(frame: .zero)
        let path = Bundle.main.path(forResource: "testExcel", ofType: "xlsx")
        let url = URL.init(fileURLWithPath: path!)
        let requet = URLRequest.init(url: url)
        wb.load(requet)
        return wb
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "IJKPlayer 播放器"
        view.addSubview(playerView)
        playerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(220)
        }
        
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(playerView.snp_bottom)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "AVPlayer", style: .done, target: self, action: #selector(pushAVPlayerVC))
    }
    
    
    @objc private func pushAVPlayerVC(){
        let vc = LBAVPlayerController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

}
