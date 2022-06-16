//
//  CHTCollectionViewWaterfallFooter.m
//  Demo
//
//  Created by Neil Kimmett on 28/10/2013.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "CHTCollectionViewWaterfallFooter.h"

@interface CHTCollectionViewWaterfallFooter ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation CHTCollectionViewWaterfallFooter

#pragma mark - Accessors
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
//      self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
      [self addSubview:self.titleLab];
  }
  return self;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLab.text = title;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _titleLab.frame = CGRectMake(20, 0, self.bounds.size.width - 40, self.bounds.size.height);
}

- (UILabel *)titleLab{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont boldSystemFontOfSize:17];
        _titleLab.textColor = [UIColor blackColor];
    }
    return _titleLab;
}

@end
