//
//  LBGrayViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/12/12.
//

import UIKit
import BLTUIKitProject
import RxSwift

/// view置灰或则整个App置灰  哪里置灰就挂在那个view上
///UIWindow *window = [UIApplication sharedApplication].keyWindow;
//CGFloat r,g,b,a;
//        [[UIColor lightGrayColor] getRed:&r green:&g blue:&b alpha:&a];
//        //创建滤镜
//        id cls = NSClassFromString(@"CAFilter");
//        id filter = [cls filterWithName:@"colorMonochrome"];
//        //设置滤镜参数
//        [filter setValue:@[@(r),@(g),@(b),@(a)] forKey:@"inputColor"];
//        [filter setValue:@(0) forKey:@"inputBias"];
//        [filter setValue:@(1) forKey:@"inputAmount"];
//        //设置给window
//        window.layer.filters = [NSArray arrayWithObject:filter];

class LBGrayViewController: UIViewController {
    
    lazy var stackView = UIStackView.blt_stackView(withSpacing: 15, distribution: .fill, alignment: .center, axis: .vertical)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        testEqual()
    }
    
    ///1.第一种是给view上添加一个置灰的view
    @objc private func addGrayViewOnTop(){
        let overlay = UIView.init(frame: stackView.bounds)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = .lightGray
        overlay.layer.compositingFilter = "saturationBlendMode"
        overlay.isUserInteractionEnabled = false
        stackView.addSubview(overlay)
    }
    
    ///2.用滤镜的方式  如果需要整个App置灰，就挂在Window上  需要哪里置灰挂在哪里
    @objc private func useFilterMethod(){
        let color = UIColor.lightGray
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        guard let filter = CIFilter.init(name: "colorMonochrome") else { return }
        filter.setValue([red, green, blue, alpha], forKey: "inputColor")
        filter.setValue(0, forKey: "inputBias")
        filter.setValue(1, forKey: "inputAmount")
        stackView.layer.filters = [filter]
    }
    
    private func testEqual(){
        let obj1 = LBTestEqualObject()
        let obj2 = obj1
        ///这个class没有继承NSObject  所以默认没有实现==（equal） 但可以用===来判断两个对象是否相等
//        if obj1 == obj2{
//            print("LBLog obj1 = obj2 1111")
//        }
        if obj1 === obj2{
            print("LBLog obj1 = obj2 2222")
        }
    }
}

class LBTestEqualObject{
    
}


extension LBGrayViewController{
    private func configUI(){
        self.view .addSubview(stackView)
        let imageView1 = UIImageView.init(image: UIImageNamed("alert_image"))
        let imageView2 = UIImageView.init(image: UIImageNamed("face"))
        stackView.addArrangedSubview(imageView1)
        stackView.addArrangedSubview(imageView2)
        
        stackView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        imageView1.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 200))
        }
        imageView2.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        let method1Btn: UIButton = {
            let button = UIButton.blt_button(with: nil, target: self, selector: #selector(addGrayViewOnTop))!
            button.setTitle("添加view盖上去", for: .normal)
            button.setTitleColor(.black, for: .normal)
            return button
        }()
        
        let method2Btn: UIButton = {
            let button = UIButton.blt_button(with: nil, target: self, selector: #selector(addGrayViewOnTop))!
            button.setTitle("滤镜的方式", for: .normal)
            button.setTitleColor(.black, for: .normal)
            return button
        }()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: method1Btn), UIBarButtonItem.init(customView: method2Btn)];
    }
    
    
    
    
}
