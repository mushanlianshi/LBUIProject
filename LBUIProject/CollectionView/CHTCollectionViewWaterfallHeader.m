//
//  CHTCollectionViewWaterfallHeader.m
//  Demo
//
//  Created by Neil Kimmett on 21/10/2013.
//  Copyright (c) 2013 Nelson. All rights reserved.
//

#import "CHTCollectionViewWaterfallHeader.h"

@interface CHTCollectionViewWaterfallHeader ()

@property (nonatomic, strong) UILabel *titleLab;

@end

@implementation CHTCollectionViewWaterfallHeader

#pragma mark - Accessors
- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
//      self.backgroundColor = [UIColor lightGrayColor];
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
        _titleLab.textColor = [UIColor redColor];
    }
    return _titleLab;
}

@end
