//
//  BLTHStackView.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//

import UIKit


open class BLTBaseStackView: UIView{
    private let contentInsets: UIEdgeInsets
    
    public var stackView: UIStackView
    
    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    
    public convenience init(contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true) {
        self.init(distribution: .fill, alignment: .fill, spacing: 0, contentInsets: contentInsets, needScroll: needScroll)
    }
    
    public convenience init(spacing: CGFloat = 0, contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true) {
        self.init(distribution: .fill, alignment: .fill, spacing: spacing, contentInsets: contentInsets, needScroll: needScroll)
    }
    
    ///默认构造器
    public init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true){
        stackView = UIStackView()
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = alignment
        self.contentInsets = contentInsets
        super.init(frame: .zero)
    }
    
    ///带resultBuilder的构造器
    public convenience init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true, @BLTViewBuilder views: () -> [UIView]){
        self.init(distribution: distribution, alignment: alignment, spacing: spacing, contentInsets: contentInsets, needScroll: needScroll)
        views().forEach { view in
            stackView.addArrangedSubview(view)
        }
    }
    
    
    @discardableResult
    public func spacing(_ spacing: CGFloat) -> Self{
        stackView.spacing = spacing
        return self
    }
    
    @discardableResult
    public func distribution(_ distribution: UIStackView.Distribution) -> Self{
        stackView.distribution = distribution
        return self
    }
    
    @discardableResult
    public func alignment(_ alignment: UIStackView.Alignment) -> Self{
        stackView.alignment = alignment
        return self
    }
    
    @discardableResult
    public func addArrangeSubviews(_ views: [UIView]) -> Self{
        views.forEach { view in
            stackView.addArrangedSubview(view)
        }
        return self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


///横向的stackView   可以滑动  针对个数比较少的子view 子view不是一个样式的
///BLTHStackView 如果可以滚动注意横向的宽度要能推断出来   不然scrollView的contentSize会有问题(比如外层的VStackView的alignment是leading就推断不出来，需要添加BLTHStackView的宽度约束或则alignment设置成fill)
open class BLTHStackView: BLTBaseStackView {
    
    public override init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true) {
        super.init(distribution: distribution, alignment: alignment, spacing: spacing, contentInsets: contentInsets, needScroll: needScroll)
        stackView.axis = .horizontal
        if needScroll{
            addSubview(scrollView)
            scrollView.addSubview(stackView)
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(contentInsets)
            }
            
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalToSuperview()
            }
        }else{
            addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(contentInsets)
            }
        }
    }
    
    
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


///竖向的stackView   可以滑动  针对个数比较少的子view 子view不是一个样式的
public class BLTVStackView: BLTBaseStackView {
    
    public override init(distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, contentInsets: UIEdgeInsets = .zero, needScroll: Bool = true) {
        super.init(distribution: distribution, alignment: alignment, spacing: spacing, contentInsets: contentInsets, needScroll: needScroll)
        stackView.axis = .vertical
        
        if needScroll{
            addSubview(scrollView)
            scrollView.addSubview(stackView)
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(contentInsets)
            }
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
            }
        }else{
            addSubview(stackView)
            stackView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(contentInsets)
            }
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



///类似flutter里的间距view
open class BLTBaseSpacer: UIView{
    let spacing: CGFloat
    ///没有使用Snp  还没加到superView中
    public var axis: NSLayoutConstraint.Axis? {
        didSet{
            refreshAxis(axis)
        }
    }
    
    public var size: CGSize?{
        didSet{
            guard let size = size else { return }
            translatesAutoresizingMaskIntoConstraints = false
            self.removeConstraints(self.constraints)
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    public convenience init(_ spacing: CGFloat = 10) {
        self.init(spacing: spacing, backgroundColor: .clear)
    }
    
    public init(spacing: CGFloat = 10, axis: NSLayoutConstraint.Axis = .horizontal, backgroundColor: UIColor = .clear){
        self.spacing = spacing
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        //由于初始化中不调用didset  可以使用defer来延迟调用
//        defer{
//            self.axis = axis
//        }
        self.axis = axis
        refreshAxis(axis)
    }
    
    public func refreshAxis(_ axis: NSLayoutConstraint.Axis?){
        translatesAutoresizingMaskIntoConstraints = false
        self.removeConstraints(self.constraints)
        switch axis {
        case .horizontal:
            widthAnchor.constraint(equalToConstant: spacing).isActive = true
        case .vertical:
            heightAnchor.constraint(equalToConstant: spacing).isActive = true
        default:
            break
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class BLTSpacer: BLTBaseSpacer {
    
}


open class BLTDivider: BLTBaseSpacer{
    
    public convenience init(_ backgroundColor: UIColor = .lightGray) {
        self.init(backgroundColor: backgroundColor)
    }
    
    public convenience init(_ width: CGFloat = 1.0 / UIScreen.main.scale) {
        self.init(width: width)
    }
    
    public init(width: CGFloat = 1.0 / UIScreen.main.scale, axis: NSLayoutConstraint.Axis = .vertical, backgroundColor: UIColor = .lightGray){
        super.init(spacing: width, axis: axis, backgroundColor: backgroundColor)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
