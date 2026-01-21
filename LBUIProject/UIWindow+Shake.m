//
//  UIWindow+Shake.m
//  chugefang
//
//  Created by liu bin on 2020/12/10.
//  Copyright © 2020 baletu123. All rights reserved.
//

#import "UIWindow+Shake.h"
#if DEBUG
#import "FLEXManager.h"
#endif


#if DEBUG
@implementation UIWindow (Shake)

- (BOOL)canBecomeFirstResponder {//默认是NO，所以得重写此方法，设成YES
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
        

    [[FLEXManager sharedManager] showExplorer];

}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
}

@end
#endif
