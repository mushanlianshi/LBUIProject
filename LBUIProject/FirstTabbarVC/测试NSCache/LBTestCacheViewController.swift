//
//  LBTestCacheViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/1/26.
//

import UIKit

class LBTestCacheViewController: UIViewController {
    
    public static let willTerminateNotification22 = NSNotification.Name.init(rawValue: "haha")
    
    lazy var cache: NSCache<AnyObject, AnyObject> = {
        let c = NSCache<AnyObject,AnyObject>()
        c.countLimit = 5
        c.delegate = self
        return c
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(memoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        fullCache()
    }
    
    private func fullCache(){
        for i in 0...10 {
            let key = "\(i)" as NSString
            let obj = "object \(i)" as NSString
            cache.setObject(obj, forKey: key)
        }
    }
    
    @objc func willEnterBackground(){
        print("LBLog willEnterBackground ===============================")
    }

    @objc func memoryWarning(){
        print("LBLog memoryWarning ===============================")
    }
    
}


extension LBTestCacheViewController: NSCacheDelegate{
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        print("LBLog will remove object is \(obj)")
    }
}
