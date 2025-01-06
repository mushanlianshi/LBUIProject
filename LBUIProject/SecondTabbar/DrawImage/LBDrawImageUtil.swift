//
//  LBDrawImageUtil.swift
//  Runner
//
//  Created by liu bin on 2023/10/13.
//

import Foundation
import YYKit


//画图片的工具
class LBDrawImageUtil {
    static func drawCircleImage(text: String, backgroundColor: UIColor, circleSize: CGSize = .init(width: 68, height: 68), textColor: UIColor = .white, font: UIFont = .systemFont(ofSize: 14)) -> UIImage?{
        
        UIGraphicsBeginImageContextWithOptions(circleSize, false, 0.0)
        // 绘制圆形图片背景色
        let circleRect = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        backgroundColor.setFill()
        circlePath.fill()
        
        // 绘制text文本
        let attributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: textColor
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(x: circleSize.width/2 - textSize.width/2, y: circleSize.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    static func drawBottomArrowImage(text: String, backgroundColor: UIColor, textColor: UIColor = .white, textInset: UIEdgeInsets = .init(top: 5, left: 15, bottom: 5, right: 15), font: UIFont = UIFont.systemFont(ofSize: 12)) -> UIImage?{
        
        let width = floor((text as NSString).width(for: font)) + textInset.left + textInset.right
        let height = floor((text as NSString).height(for: font, width: CGFloat.greatestFiniteMagnitude)) + textInset.top + textInset.bottom
        
        let arrowSize = CGSize(width: 10, height: 10)
        
        
        let imageSize = CGSize(width: width, height: height + arrowSize.height)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        
        let path = UIBezierPath()
        // 左上角圆弧
        path.move(to: CGPoint(x: height / 2.0, y: 0.0))
        path.addArc(withCenter: CGPoint(x: height / 2.0, y: height / 2.0), radius: height / 2.0, startAngle: CGFloat.pi/2, endAngle: -CGFloat.pi/2, clockwise: true)

        // 下边线
        path.addLine(to: CGPoint(x: height / 2.0, y: height))

        // 尖角
        path.addLine(to: CGPoint(x: width / 2.0 - arrowSize.width / 2, y: height))
        path.addLine(to: CGPoint(x: width / 2.0, y: imageSize.height))
        path.addLine(to: CGPoint(x: width / 2.0 + arrowSize.width / 2, y: height))
        path.addLine(to: CGPoint(x: width - height / 2.0, y: height))

        // 右上角圆弧
        path.addArc(withCenter: CGPoint(x: width - height / 2.0, y: height / 2.0), radius: height / 2.0, startAngle: -CGFloat.pi/2, endAngle: CGFloat.pi/2, clockwise: true)

        // 右边线
        path.addLine(to: CGPoint(x: width - height / 2.0, y: 0.0))

        // 关闭路径
        path.close()
        backgroundColor.setFill()
        path.fill()
        
        // 绘制文本
        let text = text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: textColor
        ]
        let textSize = text.size(withAttributes: textAttributes)
        let textRect = CGRect(x: (width - textSize.width) / 2, y: (height - textSize.height) / 2, width: textSize.width, height: textSize.height)
        text.draw(in: textRect, withAttributes: textAttributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}


