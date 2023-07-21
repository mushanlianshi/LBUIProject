//
//  LBExpandCloseLabelController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/12.
//

import UIKit
import BLTSwiftUIKit

class LBExpandCloseLabelController: UIViewController {
    
    lazy var expandLab: LBExpandCloseLabel = {
        let label = LBExpandCloseLabel.init(foldContent: .init(expandAttris: [.foregroundColor : UIColor.red, .font : UIFont.blt.mediumFont(14)]))
        label.preferredMaxLayoutWidth = self.view.bounds.width - 40
        label.foldNumberOfLines = 3
        label.foldChangeBlock = {
            [weak self] expand in
            label.sizeToFit()
            print("LBLog expand \(expand) \(label.size) \(label.isExpand)")
        }
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "展开收起label"
        self.view.addSubview(expandLab)
        self.expandLab.snp.makeConstraints { make in
            make.left.top.equalTo(20)
            make.right.equalTo(-20)
        }
        expandLab.text = "关于objective-c - swift 类 : Fatal error: Use of unimplemented initializer 'init()' for class，我们在Stack Overflow上找到一个类似的问题：关于objective-c - swift 类 : Fatal error: Use of unimplemented initializer 'init()' for class，我们在Stack Overflow上找到一个类似的问题：关于objective-c - swift 类 : Fatal error: Use of unimplemented initializer 'init()' for class，我们在Stack Overflow上找到一个类似的问题："
    }

}
