//
//  LBTestAutoLayoutViewController.h
//  LBUIProject
//
//  Created by liu bin on 2021/5/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///布局会先调用Controller的viewdidlayoutsubviews -> 父View的layoutSubviews -> 各子view的layoutSubviews
///如果后面子view的frame发生了变化  会触发Controller的viewdidlayoutsubviews -> 父View的layoutSubview和当前发生宽高变化的子view的layoutSubview（父view里别的子view的layoutSubviews不会再调用  应为别的子view的宽高没变，不会触发别的view的子subview从新布局，如果影响到了别的子view的宽高，会导致别的子view的layoutSubviews也会调用）
///layoutSubviews顾明思议  布局子view的回调方法，当自己宽高会变的情况下才会调用来布局子控件
@interface LBTestAutoLayoutViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
