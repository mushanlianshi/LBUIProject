//
//  LBWidgetUpdateController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/8.
//

import Foundation
import WidgetKit

class LBWidgetUpdateController: UIViewController {
    
    private var timer: Timer?
    lazy var currentTime: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "widget数据更新"
        view.backgroundColor = .white
        beginRefreshWidget()
    }
    
    func beginRefreshWidget() {
//        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(refreshTime), userInfo: nil, repeats: true)
//        RunLoop.current.add(timer!, forMode: .common)
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] timer in
            self?.currentTime += 1
            self?.setTimeToAppShare()
        })
    }
    
    @objc private func refreshTime(){
        self.currentTime += 1
        self.setTimeToAppShare()
    }
    
    private func setTimeToAppShare(){
        guard var url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.lb.uiproject") else {
            return
        }
        url.appendPathComponent("widgetShareData.json")
        let dic = ["currentTime" : self.currentTime]
        let data = try? JSONSerialization.data(withJSONObject: dic, options: [])
        try? data?.write(to: url)
        print("LBLog refresh app widget time \(self.currentTime)")
        UserDefaults.standard.set(self.currentTime, forKey: "widgetTime")
//        data?.write(to: url)
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
