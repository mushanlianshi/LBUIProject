//
//  LBWatchDogController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/27.
//

import UIKit
import Watchdog

//检测卡顿的  通过ping的方式   不是通过runloop的对比两次间隔的方式
class LBWatchDogController: UIViewController {
    
    var watchDog: Watchdog?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let onlyWatch = UIBarButtonItem.init(title: "只监控", style:.done, target: self, action: #selector(startWatchDog))
        let watchStop = UIBarButtonItem.init(title: "监控终止", style: .done, target: self, action: #selector(stopWhenWatchDog))
        navigationItem.rightBarButtonItems = [onlyWatch, watchStop]
    }

    
    @objc func startWatchDog(){
        watchDog = Watchdog.init(threshold: 0.5) {
            print("LBLog watch kandun--------");
        }
        Thread.sleep(forTimeInterval: 2)
    }
    
    @objc func stopWhenWatchDog(){
        watchDog = Watchdog.init(threshold: 0.5, strictMode: true)
        Thread.sleep(forTimeInterval: 2)
    }
    
    
    
    deinit {
        print("LBLog LBWatchDogController dealloc ==========")
    }
}
