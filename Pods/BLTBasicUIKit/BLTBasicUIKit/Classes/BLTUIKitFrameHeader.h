//
//  BLTUIKitFrameHeader.h
//  Pods
//
//  Created by liu bin on 2020/7/3.
//

#ifndef BLTUIKitFrameHeader_h
#define BLTUIKitFrameHeader_h

/** 取UIEdgeInset的水平方向的值 */
CG_INLINE CGFloat BLTUIEdgeInsetsGetHorizontalValue(UIEdgeInsets insets){
    return insets.left + insets.right;
}

/** 去UIEdgeInst竖直方向的值 */
CG_INLINE CGFloat BLTUIEdgeInsetsGetVerticalValue(UIEdgeInsets insets){
    return insets.top + insets.bottom;
}

/** 根据Inset内间距返回一个新的Rect */
CG_INLINE CGRect BLTCGRectFromUIEdgeInsets(CGRect frame, UIEdgeInsets insets){
    frame = CGRectMake(CGRectGetMinX(frame) + insets.left,
                       CGRectGetMinY(frame) + insets.top,
                       CGRectGetWidth(frame) - BLTUIEdgeInsetsGetHorizontalValue(insets),
                       CGRectGetHeight(frame) - BLTUIEdgeInsetsGetVerticalValue(insets));
    return frame;
}

/** 设置frame的宽度 */
CG_INLINE CGRect BLTCGRectSetWidth(CGRect frame, CGFloat width){
    frame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
    return frame;
}

/** 设置frame的高度 */
CG_INLINE CGRect BLTCGRectSetHeight(CGRect frame, CGFloat height){
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
    return frame;
}

CG_INLINE CGRect BLTCGRectSetX(CGRect frame, CGFloat x){
    frame = CGRectMake(x, frame.origin.y, frame.size.width, frame.size.height);
    return frame;
}

CG_INLINE CGRect BLTCGRectSetY(CGRect frame, CGFloat y){
    frame = CGRectMake(frame.origin.x, y, frame.size.width, frame.size.height);
    return frame;
}

/** 获取居中显示  需要开始位置的值*/
CG_INLINE CGFloat BLTCGRectGetCenterStartValue(CGFloat parentW, CGFloat childW){
    return (parentW - childW) / 2;
}

#endif /* BLTUIKitFrameHeader_h */
