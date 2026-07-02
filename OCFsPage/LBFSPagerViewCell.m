//
//  LBFSPagerViewCell.m
//  LBUIProject
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//  Converted to Objective-C with LB prefix
//

#import "LBFSPagerViewCell.h"

@interface LBFSPagerViewCell ()

@property (nonatomic, weak, nullable) UILabel *privateTextLabel;
@property (nonatomic, weak, nullable) UIImageView *privateImageView;
@property (nonatomic, weak, nullable) UIView *privateSelectedForegroundView;

@end

@implementation LBFSPagerViewCell {
    void *_kvoContext;
    UIColor *_selectionColor;
}

- (UILabel *)textLabel {
    if (self.privateTextLabel) {
        return self.privateTextLabel;
    }

    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    backgroundView.userInteractionEnabled = NO;
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];

    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [self.contentView addSubview:backgroundView];
    [backgroundView addSubview:textLabel];

    [textLabel addObserver:self
                forKeyPath:@"font"
                   options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                   context:&_kvoContext];

    self.privateTextLabel = textLabel;
    return textLabel;
}

- (UIImageView *)imageView {
    if (self.privateImageView) {
        return self.privateImageView;
    }

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:imageView];
    self.privateImageView = imageView;
    return imageView;
}

- (UIView *)selectedForegroundView {
    if (self.privateSelectedForegroundView) {
        return self.privateSelectedForegroundView;
    }

    UIImageView *imageView = self.privateImageView;
    if (!imageView) {
        return nil;
    }

    UIView *view = [[UIView alloc] initWithFrame:imageView.bounds];
    [imageView addSubview:view];
    self.privateSelectedForegroundView = view;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _kvoContext = &_kvoContext;
    _selectionColor = [[UIColor colorWithWhite:0.2 alpha:0.2] retain];

    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 0.75;
    self.contentView.layer.shadowOffset = CGSizeZero;
}

- (void)dealloc {
    [_selectionColor release];
    if (self.privateTextLabel) {
        [self.privateTextLabel removeObserver:self forKeyPath:@"font" context:&_kvoContext];
    }
    [super dealloc];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.selectedForegroundView.layer.backgroundColor = _selectionColor.CGColor;
    } else if (!self.isSelected) {
        self.selectedForegroundView.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedForegroundView.layer.backgroundColor = selected ? _selectionColor.CGColor : [UIColor clearColor].CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.privateImageView) {
        self.privateImageView.frame = self.contentView.bounds;
    }

    if (self.privateTextLabel) {
        UIView *backgroundView = self.privateTextLabel.superview;
        CGRect rect = self.contentView.bounds;
        CGFloat height = self.privateTextLabel.font.pointSize * 1.5;
        rect.size.height = height;
        rect.origin.y = self.contentView.frame.size.height - height;
        backgroundView.frame = rect;

        rect = backgroundView.bounds;
        rect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 8, 0, 8));
        rect.size.height -= 1;
        rect.origin.y += 1;
        self.privateTextLabel.frame = rect;
    }

    if (self.privateSelectedForegroundView) {
        self.privateSelectedForegroundView.frame = self.contentView.bounds;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if (context == &_kvoContext) {
        if ([keyPath isEqualToString:@"font"]) {
            [self setNeedsLayout];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end