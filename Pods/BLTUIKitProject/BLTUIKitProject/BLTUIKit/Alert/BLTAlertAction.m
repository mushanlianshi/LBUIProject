//
//  BLTAlertAction.m
//  BLTUIKit 1.1.1
//
//  Created by liu bin on 2020/3/2.
//  Copyright © 2020 liu bin. All rights reserved.
//

#import "BLTAlertAction.h"

@interface BLTAlertAction ()

@property (nonatomic, copy, readwrite) NSString *title;

@property (nonatomic, assign, readwrite) BLTAlertActionStyle style;

@end

@implementation BLTAlertAction

+ (instancetype)actionWithTitle:(NSString *)title style:(BLTAlertActionStyle)style handler:(void(^) (BLTAlertAction *action))handler{
    BLTAlertAction *alertAction = [[BLTAlertAction alloc] init];
    alertAction.title = title;
    alertAction.style = style;
    alertAction.handler = handler;
    return alertAction;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _actionButton = [[UIButton alloc] init];
        [_actionButton addTarget:self action:@selector(alertActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)alertActionButtonClicked:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertActionDidClicked:)]) {
        [self.delegate alertActionDidClicked:self];
    }
}

@end
