//
//  LBCutDownNumberAnimationController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/3.
//

import UIKit

class LBCutDownNumberAnimationController: UIViewController {

    var count: Int = 99
    
    var countFoldView: FoldAnimationView!
    var countDownFCV: FoldClockView!
    var dateFCV: FoldClockView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "倒计时动画"
        
        let w = view.bounds.size.width
        
        // 倒计数
        countFoldView = FoldAnimationView(frame: CGRectMake((w-100)*0.5, 100, 100, 120))
        countFoldView.backgroundColor = .gray
        countFoldView.textColor = .white
        countFoldView.font = UIFont.boldSystemFont(ofSize: 70)
        countFoldView.layer.masksToBounds = true
        countFoldView.layer.cornerRadius = 10
        view.addSubview(countFoldView)
        
        
        countFoldView.fold(current: "\(self.count)", next: "\(self.count-1)")
        

        // 倒计时
        countDownFCV = FoldClockView(frame: CGRect(x: 20, y: 300, width: w-40, height: 100))
        countDownFCV.sequenceType = .reduce
        view.addSubview(countDownFCV)

        
        
        // 时间
        dateFCV = FoldClockView(frame: CGRect(x: 20, y: 500, width: w-40, height: 100))
        dateFCV.sequenceType = .increase
        view.addSubview(dateFCV)
        
        
        // 简单的定时器，精准应使用GCD
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.startCutDown()
        }
    }
    
    private func startCutDown(){
        let calendar: Calendar = Calendar.current
        // 倒计时截止时间
        let endDate = Date(timeInterval: 60*60, since: Date.now)
        
        countFoldView.fold(current: "\(self.count)", next: "\(self.count-1)")
        self.count -= 1

        // 当前时间
        let nowDate = Date()
        // 相差秒数
        let duration: TimeInterval = ceil(endDate.timeIntervalSince1970 - nowDate.timeIntervalSince1970)
        // 更新
        countDownFCV.duration = Int(duration)

        let dateComponent = calendar.dateComponents([.hour,.minute,.second], from: Date.now)
        dateFCV.dateComponent = dateComponent
    }
    
    deinit{
        print("LBLog \(self) deinit")
    }

}
