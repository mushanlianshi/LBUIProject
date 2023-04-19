//
//  UIView+BLTCatetory.m
//  BLTUIKitProject
//
//  Created by liu bin on 2022/9/5.
//

#import "UIView+BLTCatetory.h"
#import "BLTOnceManager.h"
#import <objc/runtime.h>
#import "BLTUICommonDefines.h"

@implementation UIView (BLTCatetory)

- (void)setBlt_responseInset:(UIEdgeInsets)blt_responseInset{
    objc_setAssociatedObject(self, @selector(blt_responseInset), [NSValue valueWithUIEdgeInsets:blt_responseInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [BLTOnceManager executeBlock:^{
        swizzleInstanceMethod([self class], @selector(pointInside:withEvent:), @selector(blt_pointInside:withEvent:));
        NSLog(@"LBLog exchange method ");
    } onceIdentifier:@"UIView setBlt_responseInset"];
}

- (UIEdgeInsets)blt_responseInset{
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}

- (BOOL)blt_pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    if (UIEdgeInsetsEqualToEdgeInsets(self.blt_responseInset, UIEdgeInsetsZero)) {
        return [self blt_pointInside:point withEvent:event];
    }
    CGRect newFrame = CGRectMake(self.bounds.origin.x + self.blt_responseInset.left, self.bounds.origin.y + self.blt_responseInset.top, self.bounds.size.width - self.blt_responseInset.left - self.blt_responseInset.right, self.bounds.size.height  - self.blt_responseInset.top - self.blt_responseInset.bottom);
    return CGRectContainsPoint(newFrame, point);
}

@end
