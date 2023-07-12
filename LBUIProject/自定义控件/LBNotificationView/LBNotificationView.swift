//
//  LBNotificationView.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/15.
//

import Foundation
import UIKit

open class LBNotificationView: UIControl, LBNotificationViewProtocol{
    public var notification: LBNotification?
    
    public var contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15){
        didSet{
            setConstraints()
        }
    }
    
    public var backgroundView = UIVisualEffectView.init(effect: UIBlurEffect.init(style: .light))
    public var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    public var titleLab: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.blt.hexColor(0x333333)
        return label
    }()
    
    public var contentLab: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.blt.hexColor(0x999999)
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundView.layer.cornerRadius = 10
        backgroundView.layer.masksToBounds = true
        backgroundView.backgroundColor = .white.withAlphaComponent(0.6)
        backgroundView.isUserInteractionEnabled = false
        addSubview(backgroundView)
        self.addSubview(imageView)
        self.addSubview(titleLab)
        self.addSubview(contentLab)
        setConstraints()
    }
    
    private func setConstraints(){
        backgroundView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(contentInset.left)
            make.top.equalToSuperview().offset(contentInset.top)
        }
        
        titleLab.snp.remakeConstraints { make in
            make.left.equalTo(imageView.snp_right).offset(10)
            make.top.equalTo(imageView)
            make.right.equalTo(-contentInset.right)
        }
        contentLab.snp.remakeConstraints { make in
            make.left.equalTo(imageView)
            make.right.equalTo(titleLab)
            make.top.equalTo(titleLab.snp_bottom).offset(10)
            make.bottom.equalTo(-contentInset.bottom)
        }
        
        self.blt.setCompressHugging(lowPriorityViews: [titleLab], highPriorityViews: [imageView])
    }
    
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let s = super.sizeThatFits(size)
        return s
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("LBLog draw =======")
    }
}
