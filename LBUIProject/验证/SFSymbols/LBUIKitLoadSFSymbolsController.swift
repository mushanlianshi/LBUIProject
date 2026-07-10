//
//  LBUIKitLoadSFSymbolsController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/6/11.
//

import UIKit

class LBUIKitLoadSFSymbolsController: UIViewController {
    
    lazy var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical, alignment: .center)
    
    lazy var firstImageView: UIImageView = {
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
//        let image = UIImage(systemName: "hand.raised", withConfiguration: config)
        let image = UIImage.blt.imageWithSystemSymbols(name: "hand.raised", pointSize: 26, weight: .medium)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .red
        if #available(iOS 17.0, *) {
                imageView.addSymbolEffect(
                    .bounce,
                    options: .default
                )
            }
        return imageView
    }()
    
    lazy var firstImageView1: UIImageView = {
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
//        let image = UIImage(systemName: "hand.raised", withConfiguration: config)
        let image = UIImage.blt.imageWithSystemSymbols(name: "hand.raised", pointSize: 22, weight: .heavy)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .gray
        return imageView
    }()
    
    lazy var secondImageView: UIImageView = {
//        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .black)
//        let image = UIImage(systemName: "dot.radiowaves.left.and.right", withConfiguration: config)
        let image = UIImage.blt.imageWithSystemColorSymbols(name: "dot.radiowaves.left.and.right", color: .blue, pointSize: 30, weight: .bold)
        let imageView = UIImageView(image: image)
//        imageView.tintColor = .blue
        return imageView
    }()
    
    lazy var secondImageView2: UIImageView = {
//        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .black)
//        let image = UIImage(systemName: "dot.radiowaves.left.and.right", withConfiguration: config)
        let image = UIImage.blt.imageWithSystemColorSymbols(name: "dot.radiowaves.left.and.right", color: .systemPink, pointSize: 25, weight: .thin)
        let imageView = UIImageView(image: image)
//        imageView.tintColor = .blue
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        [firstImageView, firstImageView1, secondImageView, secondImageView2].forEach(stackView.addArrangedSubview(_:))
        stackView.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        
        // 如果返回了 也会在3秒后执行block， 内部估计block被copy了
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            self.title = "jhaje"
            print("LBLog LBUIKitLoadSFSymbolsController execute")
        })
    }
    
    deinit{
        print("LBLog LBUIKitLoadSFSymbolsController deinit ------")
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
