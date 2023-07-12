//
//  LBLocaleViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/5.
//

import UIKit

class LBLocaleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "本地化"
        view.backgroundColor = .white
        testAutoLocale()
        getCurrentLocale()
        getCurrentLanguage()
    }
    
    
    private func testAutoLocale() {
        let text = NSLocalizedString("localTitle", comment: "")
        let label = UILabel.blt.initWithText(text: text, font: .blt.mediumFont(16), textColor: .black)
        self.view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
    }
    
    ///en_CN中国大陆  //en_HK香港
    private func getCurrentLocale() {
        print("LBLog current locale \(NSLocale.current.identifier)")
        print("LBLog current locale \(NSLocale.autoupdatingCurrent.identifier)")
    }
    
//    zh-Hans-CN,   zh-Hans-HK//中国香港
//    en-CN,
//    en-GB
//    )
    private func getCurrentLanguage()  {
        let languages = UserDefaults.standard.value(forKey: "AppleLanguages")
        print("LBLog current languages \(languages)")
    }

}
