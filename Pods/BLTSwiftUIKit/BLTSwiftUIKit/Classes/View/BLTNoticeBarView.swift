//
//  BLTNoticeBarView.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//

import UIKit
import BLTUIKitProject
import JXMarqueeView
import SnapKit

//展示的类型
@objc public enum BLTNoticeBarViewType: Int {
    case show = 0  //正式展示
    case scroll = 1 //跑马灯
}

@objc public enum BLTNoticeBarViewActionType: Int {
    case background = 0
    case rightAction = 1
    case rightClose = 2
}

//CG_INLINE UIImage* UIImageNamedFromBLTUIKItBundle(NSString *imageName){
//    NSBundle *BLTUIKitBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:NSClassFromString(@"BLTAlertController")] pathForResource:@"BLTUIKitBundle" ofType:@"bundle"]];
//    NSString *imageFullName = [NSString stringWithFormat:@"%@@%zdx",imageName, (NSInteger)[UIScreen mainScreen].scale];
//    return [[UIImage imageWithContentsOfFile:[BLTUIKitBundle pathForResource:imageFullName ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//}

public func imageFromSwiftUIKitBundle(_ imageName: String?) -> UIImage? {
    guard let imageN = imageName else { return nil }
    
    let currentBundle = Bundle.init(for: BLTNoticeBarView.self)
    guard let path = currentBundle.path(forResource: "BLTSwiftUIKit", ofType: "bundle") else { return nil }
    
    let swiftBundle = Bundle.init(path: path)
    let imageName = imageN + "@\(Int(UIScreen.main.scale))" + "x"
    
    guard let imagePath = swiftBundle?.path(forResource: imageName, ofType: "png") else { return nil }
    return UIImage.init(contentsOfFile: imagePath)
}

public class BLTNoticeBarView: UIView {
    
    private static let shareInstance = BLTNoticeBarView()
    
    public override class func appearance() -> Self {
        return shareInstance as! Self
    }
    
    @objc public var customSensorDataBlock:((_ lookButton: UIButton?, _ closeButton: UIButton?, _ dismissControl: UIControl?) -> Void)?
    
    @objc public convenience init(content: String) {
        self.init(content: content, leftNoticeImage: imageFromSwiftUIKitBundle("blt_notice_bar_alarm"), type: .show, rightImage: imageFromSwiftUIKitBundle("blt_notice_bar_close"), rightActionTitle: nil, contentInsets: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15))
    }
    
    @objc public convenience init(content: String, leftNoticeImage: UIImage? = imageFromSwiftUIKitBundle("blt_notice_bar_alarm"), type: BLTNoticeBarViewType = .show, rightImage: UIImage? = imageFromSwiftUIKitBundle("blt_notice_bar_close"), rightActionTitle: String? = nil, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)) {
        self.init(frame: .zero)
        self.backgroundColor = UIColor.blt.hexColor(0xFFFBE8)
        self.addSubview(self.stackView)
        if let image = leftNoticeImage {
            leftImageView = UIImageView()
            leftImageView!.image = image
            self.stackView.addArrangedSubview(leftImageView!)
        }
        
        self.contentLab.text = content
        if type == .show {
            self.stackView.addArrangedSubview(self.contentLab)
        }else{
            scrollLab = JXMarqueeView()
            self.contentLab.sizeToFit()
            scrollLab!.contentView = self.contentLab
            self.stackView.addArrangedSubview(scrollLab!)
            scrollLab!.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
            scrollLab!.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
            scrollLab!.snp.makeConstraints({ (make) in
                make.height.equalTo(contentLab.bounds.size.height)
            })
        }
        
        if let actionTitle = rightActionTitle {
            rightActionButton = BLTUIResponseAreaButton()
            rightActionButton!.blt_layerCornerRaduis = 13
            rightActionButton!.backgroundColor = UIColor.blt.hexColor(0xF5A623)
            rightActionButton!.setTitleColor(.white, for: .normal)
            rightActionButton!.titleLabel?.font = UIFontPFMediumFontSize(13)
            rightActionButton!.addTarget(self, action: #selector(rightActionButtonClicked), for: .touchUpInside)
            rightActionButton!.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            rightActionButton!.setTitle(actionTitle, for: .normal)
            stackView.addArrangedSubview(rightActionButton!)
            rightActionButton!.snp.makeConstraints { (make) in
                make.height.equalTo(26)
            }
        }
        
        if let image = rightImage {
            rightCloseButton = BLTUIResponseAreaButton()
            rightCloseButton!.responseAreaInsets = UIEdgeInsets(top: -10, left: -15, bottom: -10, right: -15)
            rightCloseButton!.addTarget(self, action: #selector(rightCloseButtonClicked), for: .touchUpInside)
            rightCloseButton!.setImage(image, for: .normal)
            self.stackView.addArrangedSubview(rightCloseButton!)
        }
        
        self.contentLab.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        self.contentLab.setContentHuggingPriority(.fittingSizeLevel, for: .horizontal)
        
        self.stackView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(contentInsets.left)
            make.top.equalToSuperview().offset(contentInsets.top)
            make.right.equalToSuperview().offset(-contentInsets.right)
            make.bottom.equalToSuperview().offset(-contentInsets.bottom)
        }
    }
    
    @objc public var appearanceConfigBlock: ((_ barView:BLTNoticeBarView, _ letImageView: UIImageView?, _ contentLab: UILabel, _ scrollLab: JXMarqueeView?, _ rightActionButton: BLTUIResponseAreaButton?, _ rightCloseButton: BLTUIResponseAreaButton?) -> Void)?
    
    @objc public var barClickBlock: ((_ actionType: BLTNoticeBarViewActionType) -> Void)? = nil
    
    
    @objc public var autoDismissWhenTapClose: Bool = true
    
    @objc public var backgroundCanClick: Bool = false{
        didSet{
            self.addSubview(self.backgroundControl)
            self.sendSubviewToBack(self.backgroundControl)
            self.backgroundControl.isEnabled = backgroundCanClick
            self.backgroundControl.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard let _ = newWindow else { return }
        if self.customSensorDataBlock == nil{
            self.customSensorDataBlock = BLTNoticeBarView.shareInstance.customSensorDataBlock
        }
        self.customSensorDataBlock?(rightActionButton, rightCloseButton, backgroundControl)
        self.appearanceConfigBlock?(self,leftImageView, self.contentLab, scrollLab, rightActionButton, rightCloseButton)
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        
//        扩大stackView的响应区域
        if let closeBtn = rightCloseButton{
            let convertFrame = closeBtn.convert(closeBtn.bounds, to: self)
            let newFrame = CGRectFromEdgeInsetsSwift(frame: convertFrame, insets: rightCloseButton!.responseAreaInsets)
            if newFrame.contains(point){
                return rightCloseButton
            }
        }
//        点击stackView上  让control去响应
        if self.backgroundCanClick == true && view == stackView {
            return backgroundControl
        }
        return view
    }
    
    
    
    
    private lazy var backgroundControl: UIControl = {
       let control = UIControl()
        control.addTarget(self, action: #selector(backgroundClicked), for: .touchUpInside)
        return control
    }()
    
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    
    private var rightCloseButton: BLTUIResponseAreaButton?

    private var rightActionButton: BLTUIResponseAreaButton?
    
    private var scrollLab: JXMarqueeView?
    
    private lazy var contentLab: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.blt.hexColor(0xEF7A25)
        label.font = UIFontPFFontSize(13)
        return label
    }()
    
    private var leftImageView: UIImageView?
    
    
    @objc private func backgroundClicked(){
        self.barClickBlock?(.background)
    }
    
    @objc private func rightActionButtonClicked(){
        self.barClickBlock?(.rightAction)
    }
    
    @objc private func rightCloseButtonClicked(){
        if autoDismissWhenTapClose {
            self.removeFromSuperview()
        }
        self.barClickBlock?(.rightClose)
    }
}





