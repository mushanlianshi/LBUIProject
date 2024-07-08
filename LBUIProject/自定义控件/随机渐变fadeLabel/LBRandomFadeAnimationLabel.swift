//
//  LBRandomFadeAnimationLabel.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/17.
//

import UIKit

///FNBlingBlingLabel github
///随机渐变文字的label
open class LBRandomFadeAnimationLabel: UILabel {
    ///是不是需要动画
    public var needAnimating = true
    ///展示的总时长
    public var appearAnimatingDuration = 1.5
    ///消失动画的总时长
    public var disappearAnimatingDuration = 1.5
    
    ///动画开始的时间  用来计算大于动画时间后就直接展示的
    var beginTime: CFTimeInterval = 0
    ///动画结束的时间
    var endTime: CFTimeInterval = 0
    
    ///是不是正在开始展示动画
    var isAppearAnimating = false
    
    ///是不是正在disappear 上次text小时动画
    var isDisappearAnimating = false
    
    ///记录文字颜色的透明度的   设置变化的时候不能大于原透明住   以及动画结束还原用的
    var textColorAlpha: CGFloat = 1
    
    ///上次展示的文本  用来做消失动画的
    var lastText: String?
    ///当前的富文本  做动画用的
    var currentAttributeString: NSAttributedString?
    
    var alphaList = [CGFloat]()
    
    lazy var displayLink: CADisplayLink = {
        let timer = CADisplayLink(target: self, selector: #selector(refreshAttributeText))
        timer.isPaused = true
        timer.add(to: RunLoop.current, forMode: .common)
        return timer
    }()
    
    open override var text: String?{
        didSet{
            if needAnimating {
                startAnimating(text)
            }
        }
    }
    
    open override var textColor: UIColor!{
        didSet{
            self.textColorAlpha = self.textColor.alpha
        }
    }
    
    ///开始动画  判断是否有上次文本  有就先消失上次的文本  在开始下次的文本动画
    public func startAnimating(_ text: String?){
        //////1.这里记录一下text  不然获取的self.text会是disappear消失动画的text  就改变不了了
        lastText = text
        guard self.currentAttributeString?.length ?? 0 > 0 else {
            if let t = text, t.isEmpty == false{
                startAppearAnimating()
            }
            return
        }
        
        startDisappearLastTextAnimating()
        
    }
    
    ///随机透明度
    private func randomAlphaDurationList(_ duration: CFTimeInterval){
        guard let contentText = self.currentAttributeString?.string, contentText.isEmpty == false else{
            return
        }
        alphaList.removeAll()
        for _ in 0..<(contentText.length){
            let randomAlpha = (CGFloat(arc4random_uniform(100)) / 100) * self.textColorAlpha * 0.5
            alphaList.append(randomAlpha)
        }
    }
    
    ///开始展示新的文字动画
    private func startAppearAnimating(){
        print("LBlog startAppearAnimating");
        currentAttributeString = NSMutableAttributedString.init(string: self.lastText ?? "")
        attributedText = currentAttributeString
        randomAlphaDurationList(appearAnimatingDuration)
        isAppearAnimating = true
        beginTime = CACurrentMediaTime()
        displayLink.isPaused = false
    }
    
    ///开始隐藏上次的文字动画
    private func startDisappearLastTextAnimating(){
        print("LBlog startDisappearLastTextAnimating");
        randomAlphaDurationList(disappearAnimatingDuration)
        isDisappearAnimating = true
        beginTime = CACurrentMediaTime()
        displayLink.isPaused = false
    }
    
    @objc private func refreshAttributeText(){
        let offsetTime = CACurrentMediaTime() - beginTime
        ///隐藏动画
        if isDisappearAnimating  {
            ///如果时间大于结束动画时间了  就开始新的文字动画
            if(offsetTime > disappearAnimatingDuration){
                isDisappearAnimating = false
                displayLink.isPaused = true
                startAppearAnimating()
                return
            }
        }
        
        if(isAppearAnimating){
            if(offsetTime > appearAnimatingDuration){
                isAppearAnimating = false
                displayLink.isPaused = true
//                return
            }
        }
        
        changeTextAlpha(offsetTime)
    }
    
    
    ///修改每一个内容的alpha
    private func changeTextAlpha(_ offsetTime: TimeInterval){
        guard isDisappearAnimating || isAppearAnimating else {
            return
        }
        let attri = self.currentAttributeString?.mutableCopy() as? NSMutableAttributedString
        for index in 0..<(attri?.length ?? 0){
            var alpha = (offsetTime - self.alphaList[index])
            alpha = min(1, alpha)
            alpha = max(0, alpha)
            if isDisappearAnimating{
                alpha = 1 - alpha
            }
            var dic = (attri?.attributes as? [NSAttributedString.Key : Any]) ?? [NSAttributedString.Key : Any]()
            dic[.foregroundColor] = self.textColor.withAlphaComponent(alpha * self.textColorAlpha)
            attri?.addAttributes(dic, range: NSRange(location: index, length: 1))
        }
        print("LBlog attributedText");
        attributedText = attri?.copy() as? NSAttributedString
    }
    
    
    
    deinit {
        displayLink.invalidate()
    }
    
    
}



