//
//  LBExpandCloseLabel.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/12.
//

import Foundation
import YYKit
import BLTSwiftUIKit



///需要设置preferredMaxLayoutWidth 宽度
class LBExpandCloseLabel: YYLabel {
    
    var foldChangeBlock: ((_ isExpand: Bool) -> Void)?
    
    fileprivate (set) var isExpand = false
    
    struct FoldContent {
        var expandText = "... 展开"
        var expandAttris = [NSAttributedString.Key : Any]()
        var closeText = "收起"
        var closeAttris = [NSAttributedString.Key : Any]()
        
        init(expandAttris: [NSAttributedString.Key : Any]) {
            self.expandAttris = expandAttris
            self.closeAttris = expandAttris
        }
        
        init(expandAttris: [NSAttributedString.Key : Any], closeAttris: [NSAttributedString.Key : Any]) {
            self.expandAttris = expandAttris
            self.closeAttris = closeAttris
        }
        
    }
    
    ///默认折叠超过机会
    var foldNumberOfLines = UInt(2){
        didSet{
            self.numberOfLines = foldNumberOfLines
        }
    }
    
    let foldContent: FoldContent
    
    init(foldContent: FoldContent){
        self.foldContent = foldContent
        super.init(frame: .zero)
        self.numberOfLines = foldNumberOfLines
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var text: String?{
        didSet{
            addExpandBtnIfNeeded()
        }
    }
    
    override var attributedText: NSAttributedString?{
        didSet{
            addExpandBtnIfNeeded()
        }
    }
    
    
    ///判断是否需要添加展开按钮
    private func addExpandBtnIfNeeded(){
        if(bltCheckStringIsEmpty(attributedText?.string) && bltCheckStringIsEmpty(text)){
            return
        }
        
        func originTotalHeight() -> CGFloat{
            let label = YYLabel()
            label.numberOfLines = 0
            if let attText = attributedText, attText.string.isNotEmpty(){
                label.attributedText = attText
            }else{
                label.text = text
            }
            let size = label.sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude))
            return size.height
        }
        
        ///是有富文本
        let height = self.sizeThatFits(CGSize(width: preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)).height
        let originalTotalHeight = originTotalHeight()
        ///大于默认的行数  才添加展开按钮
        guard originalTotalHeight > height else {
            self.isExpand = true
            return
        }
        
        self.isExpand = false
        let expandAttributeText = foldContent.expandText.blt.highLightText(highArray: [foldContent.expandText], attrs: foldContent.expandAttris)
        let highlight = YYTextHighlight()
        highlight.tapAction = {
            [weak self] view, text, range, rect in
            self?.addCloseBtn()
        }
        expandAttributeText?.setTextHighlight(highlight, range: foldContent.expandText.blt.rangeOfAll())
        let expandLab = YYLabel()
        expandLab.attributedText = expandAttributeText?.copy() as? NSAttributedString
        expandLab.sizeToFit()
        let truncationToken = NSAttributedString.attachmentString(withContent: expandLab, contentMode: .center, attachmentSize: expandLab.size, alignTo: expandAttributeText?.font ?? expandLab.font, alignment: .top)
        self.truncationToken = truncationToken
    }
    
    
    ///展开： 添加收起按钮
    private func addCloseBtn(){
        self.isExpand = true
        self.numberOfLines = 0
        var attText = self.attributedText?.mutableCopy() as? NSMutableAttributedString
        if attText == nil || attText!.string.isEmpty{
            attText = text!.blt.highLightText(highArray: [text!], attrs: [.font : self.font ?? UIFont.systemFont(ofSize: 14), .foregroundColor : self.textColor ?? UIColor.black])
        }
        
        let closeAttri = foldContent.closeText.blt.highLightText(highArray: [foldContent.closeText], attrs: foldContent.closeAttris)
        let highlight = YYTextHighlight()
        highlight.tapAction = {
            [weak self] view, text, range ,rect in
            self?.removeCloseBtn()
        }
        closeAttri?.setTextHighlight(highlight, range: foldContent.closeText.blt.rangeOfAll())
        attText!.append(closeAttri!)
        self.attributedText = attText
        self.foldChangeBlock?(true)
    }
    
    
    ///收起：移除收起按钮的
    private func removeCloseBtn(){
        self.isExpand = false
        self.numberOfLines = foldNumberOfLines
        guard let attText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        let range = (attText.string as NSString).range(of: foldContent.closeText, options: [.backwards])
        guard range.location != NSNotFound else {
            return
        }
        attText.deleteCharacters(in: range)
        self.attributedText = attText.copy() as? NSAttributedString
        self.foldChangeBlock?(false)
    }
    
    
}
