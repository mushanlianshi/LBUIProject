//
//  BLTCustomImageTitleButton.m
//  Baletoo_landlord
//
//  Created by liu bin on 2019/5/14.
//  Copyright © 2019 com.wanjian. All rights reserved.
//

#import "BLTCustomImageTitleButton.h"
#import "BLTUIKitFrameHeader.h"

@implementation BLTCustomImageTitleButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    if (!CGRectIsEmpty(self.titleRect) && !CGRectEqualToRect(self.titleRect, CGRectZero)) {
        return self.titleRect;
    }
    return [super titleRectForContentRect:contentRect];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    if (!CGRectIsEmpty(self.imageRect) && !CGRectEqualToRect(self.imageRect, CGRectZero)) {
        return self.imageRect;
    }
    return [super imageRectForContentRect:contentRect];
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
}

- (CGSize)sizeThatFits:(CGSize)size{
    if (self.imagePosition == BLTCustomButtonImagePositionDefault) {
        return [super sizeThatFits:size];
    }
     // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    
    BOOL hasImage = !!self.currentImage;
    BOOL hasTitle = !!self.currentTitle;
    
    CGSize imageTotalSize = CGSizeZero;
    CGSize titleTotalSize = CGSizeZero;
    CGFloat spacingBetweenImageTitle = hasImage && hasTitle ? self.imageTitleInnerMargin : 0;
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    
    switch (self.imagePosition) {
        case BLTCustomButtonImagePositionTop:
        case BLTCustomButtonImagePositionBottom:{
            if (hasImage) {
                CGFloat imageLimitWidth = contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                CGSize imageSize = self.currentImage.size;
                imageSize.width = fmin(imageSize.width, imageLimitWidth);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (hasTitle) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - imageTotalSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + fmax(imageTotalSize.width, titleTotalSize.width);
            resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + imageTotalSize.height + spacingBetweenImageTitle + titleTotalSize.height;
        }
            break;
        case BLTCustomButtonImagePositionLeft:
        case BLTCustomButtonImagePositionRight:
        {
            if (hasImage) {
                CGFloat imageLimitHeight = contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                CGSize imageSize = self.currentImage.size;
                imageSize.height = fmin(imageSize.height, imageLimitHeight);
                imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
            }
            
            if (hasTitle) {
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - spacingBetweenImageTitle - imageTotalSize.width, contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fmin(titleSize.height, titleLimitSize.height);
                titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            }
            resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + imageTotalSize.width + spacingBetweenImageTitle + titleTotalSize.width;
            resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + fmax(imageTotalSize.height, titleTotalSize.height);
        }
            break;
    }
    return resultSize;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        return;
    }
    if (self.imagePosition == BLTCustomButtonImagePositionDefault) {
        return;
    }
    BOOL hasImage = !!self.currentImage;
    BOOL hasTitle = !!self.currentTitle || !!self.currentAttributedTitle;
    CGSize imageLimitSize = CGSizeZero;
    CGSize titleLimitSize = CGSizeZero;
    
    CGFloat spacingBetweenImageTitle = (hasImage && hasTitle) ? self.imageTitleInnerMargin : 0;
    CGSize imageTotalSize = CGSizeZero; //包含imageEdgeInsets的间距
    CGSize titleTotalSize = CGSizeZero; //包含titleInsets的间距
    
    CGRect imageFrame = CGRectZero;
    CGRect titleFrame = CGRectZero;
    //内容的大小
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    
    if (hasImage) {
        imageLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
        CGSize imageSize = [self.imageView sizeThatFits:imageLimitSize];
        imageSize.width = fmin(imageLimitSize.width, imageSize.width);
        imageSize.height = fmin(imageLimitSize.height, imageSize.height);
        imageFrame = CGRectMake(0, 0, imageSize.width, imageSize.height);
        imageTotalSize = CGSizeMake(imageSize.width + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), imageSize.height + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets));
    }
    
    //图片是上下位置的
    if (self.imagePosition == BLTCustomButtonImagePositionTop || self.imagePosition == BLTCustomButtonImagePositionBottom) {
        if (hasTitle) {
            titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - imageTotalSize.height - spacingBetweenImageTitle - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = fmin(titleLimitSize.width, titleSize.width);
            titleSize.height = fmin(titleLimitSize.height, titleSize.height);
            titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
            titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        }
        //1.判断水平方向
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentCenter:
            {
                imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetCenterStartValue(imageLimitSize.width, CGRectGetWidth(imageFrame)) + self.contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                titleFrame = hasTitle ? CGRectSetX(titleFrame, CGRectGetCenterStartValue(titleLimitSize.width, CGRectGetWidth(titleFrame)) + self.contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
            }
                break;
            case UIControlContentHorizontalAlignmentLeft:
            {
                imageFrame = hasImage ? CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                titleFrame = hasTitle ? CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
            }
                break;
            case UIControlContentHorizontalAlignmentRight:
            {
                imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                titleFrame = hasTitle ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
            }
                break;
            case UIControlContentHorizontalAlignmentFill:
            {
                CGFloat imageScale = 0;
                CGFloat imageW = (UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets) + CGRectGetWidth(imageFrame));
                if (imageW != 0) {
                    imageScale = CGRectGetWidth(self.bounds) / imageW;
                }
                imageFrame = hasImage ? CGRectSetX(imageFrame, imageScale * (self.contentEdgeInsets.left + self.imageEdgeInsets.left)) : imageFrame;
                imageFrame = hasImage ? CGRectSetWidth(imageFrame, imageScale * CGRectGetWidth(imageFrame)) : imageFrame;
            }
                break;
        }
        //图片在上
        if (self.imagePosition == BLTCustomButtonImagePositionTop) {
            //2.判断竖直方向
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentCenter:
                {
                    CGFloat contentH = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageTitle;
                    CGFloat minY = CGRectGetCenterStartValue(contentSize.height, contentH) + self.contentEdgeInsets.top;
                    imageFrame = hasImage ? CGRectSetY(imageFrame, minY + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, minY + imageTotalSize.height + spacingBetweenImageTitle + self.titleEdgeInsets.top) : titleFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentTop:
                {
                    imageFrame = hasImage ? CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, self.contentEdgeInsets.top + imageTotalSize.height + spacingBetweenImageTitle) : titleFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:{
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    imageFrame = hasTitle ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - spacingBetweenImageTitle - titleTotalSize.height - self.imageEdgeInsets.bottom) : imageFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentFill:
                {
                    CGFloat scale = 0;
                    CGFloat contentH = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageTitle + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
                    if (contentH > 0) {
                        scale = CGRectGetHeight(self.bounds) / contentH;
                    }
                    imageFrame = CGRectSetY(imageFrame, (self.contentEdgeInsets.top + self.imageEdgeInsets.top) * scale);
                    imageFrame = CGRectSetHeight(imageFrame, CGRectGetHeight(imageFrame) * scale);
                    titleFrame = CGRectSetY(titleFrame, (imageTotalSize.height + self.contentEdgeInsets.top + spacingBetweenImageTitle + self.titleEdgeInsets.top) * scale);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(titleFrame) * scale);
                }
                    break;
            }
        }
        //图片在下边
        else{
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentCenter:
                {
                    CGFloat contentH = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageTitle;
                    CGFloat minY = CGRectGetCenterStartValue(contentSize.height, contentH) + self.contentEdgeInsets.top;
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, minY + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = hasImage ? CGRectSetY(imageFrame, minY + titleTotalSize.height + spacingBetweenImageTitle + self.imageEdgeInsets.top) : imageFrame;
                    
                }
                    break;
                case UIControlContentVerticalAlignmentTop:
                {
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
                    imageFrame = hasImage ? CGRectSetY(imageFrame, self.contentEdgeInsets.top + titleLimitSize.height + spacingBetweenImageTitle + self.imageEdgeInsets.top) : imageFrame;
                    
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:{
                    imageFrame = hasTitle ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - imageTotalSize.height - spacingBetweenImageTitle - self.titleEdgeInsets.bottom) : titleFrame;
                    
                    titleFrame = hasTitle ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
                    imageFrame = hasTitle ? CGRectSetY(imageFrame, CGRectGetMinY(titleFrame) - spacingBetweenImageTitle - CGRectGetHeight(imageFrame)) : imageFrame;
                }
                    break;
                case UIControlContentVerticalAlignmentFill:
                {
                    CGFloat scale = 0;
                    CGFloat contentH = imageTotalSize.height + titleTotalSize.height + spacingBetweenImageTitle + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
                    if (contentH > 0) {
                        scale = CGRectGetHeight(self.bounds) / contentH;
                    }
                    titleFrame = CGRectSetY(titleFrame, (self.contentEdgeInsets.top + self.titleEdgeInsets.top) * scale);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(titleFrame) * scale);
                    
                    imageFrame = CGRectSetY(imageFrame, (self.contentEdgeInsets.top + titleTotalSize.height + spacingBetweenImageTitle + self.imageEdgeInsets.top) * scale);
                    imageFrame = CGRectSetHeight(imageFrame, CGRectGetHeight(imageFrame) * scale);
                    
                    //                    if (hasImage && hasTitle) {
                    //                        imageFrame = CGRectSetY(imageFrame, (self.contentEdgeInsets.top + self.imageEdgeInsets.top) * scale);
                    //                        imageFrame = CGRectSetHeight(imageFrame, CGRectGetHeight(imageFrame) * scale);
                    //                        titleFrame = CGRectSetY(titleFrame, (imageTotalSize.height + self.contentEdgeInsets.top) * scale);
                    //                        titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(titleFrame) * scale);
                    //                    }else if(hasImage){
                    //                        imageFrame = CGRectSetY(imageFrame, <#CGFloat y#>)
                    //                    }
                }
                    break;
            }
        }
        
    }
    
    
    
    //图片左右的
    if (self.imagePosition == BLTCustomButtonImagePositionLeft || self.imagePosition == BLTCustomButtonImagePositionRight) {
        if (hasTitle) {
            titleLimitSize = CGSizeMake(contentSize.width - imageTotalSize.width - spacingBetweenImageTitle - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.width = fmin(titleLimitSize.width, titleSize.width);
            titleSize.height = fmin(titleLimitSize.height, titleSize.height);
            titleFrame = CGRectMake(0, 0, titleSize.width, titleSize.height);
            titleTotalSize = CGSizeMake(titleSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), titleSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentCenter:
            {
                imageFrame = hasImage ? CGRectSetY(imageFrame, CGRectGetCenterStartValue(contentSize.height, CGRectGetHeight(imageFrame)) + self.contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = hasTitle ? CGRectSetY(titleFrame, CGRectGetCenterStartValue(contentSize.height, CGRectGetHeight(titleFrame)) + self.contentEdgeInsets.top + self.titleEdgeInsets.top) : titleFrame;
            }
                break;
                
            case UIControlContentVerticalAlignmentTop:
            {
                imageFrame = hasImage ? CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
                titleFrame = hasTitle ? CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top) : imageFrame;
            }
                break;
            case UIControlContentVerticalAlignmentBottom:
            {
                imageFrame = hasImage ? CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame)) : imageFrame;
                titleFrame = hasTitle ? CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame)) : titleFrame;
            }
                break;
            case UIControlContentVerticalAlignmentFill:
            {
                CGFloat scale = 0;
                CGFloat contentW = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + imageTotalSize.width + titleTotalSize.height + spacingBetweenImageTitle;
                if (contentW > 0) {
                    scale = CGRectGetWidth(self.bounds) / contentW;
                }
                imageFrame = hasImage ? CGRectSetY(imageFrame, (self.contentEdgeInsets.top + self.imageEdgeInsets.top) * scale) : imageFrame;
                imageFrame = hasImage ? CGRectSetHeight(imageFrame, CGRectGetHeight(imageFrame) * scale) : imageFrame;
                titleFrame = hasTitle ? CGRectSetY(titleFrame, (self.contentEdgeInsets.top + self.titleEdgeInsets.top) * scale) : titleFrame;
                titleFrame = hasTitle ? CGRectSetHeight(titleFrame, CGRectGetHeight(titleFrame) * scale) : titleFrame;
            }
                break;
        }
        
        if (self.imagePosition == BLTCustomButtonImagePositionLeft) {
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter:
                {
                    CGFloat contentW = imageTotalSize.width + spacingBetweenImageTitle + titleTotalSize.width;
                    CGFloat minX = CGRectGetCenterStartValue(contentSize.width, contentW) + self.contentEdgeInsets.left;
                    imageFrame = hasImage ? CGRectSetX(imageFrame, minX + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, CGRectGetMaxX(imageFrame) + self.titleEdgeInsets.left + spacingBetweenImageTitle) : titleFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft:
                {
                    imageFrame = hasImage ? CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, self.contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageTitle + self.titleEdgeInsets.left) : titleFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight:
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                    imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetMinX(titleFrame) - spacingBetweenImageTitle - self.titleEdgeInsets.left - self.imageEdgeInsets.right - spacingBetweenImageTitle) : imageFrame;
                    break;
                case UIControlContentHorizontalAlignmentFill:
                {
                    CGFloat scale = 0;
                    CGFloat contentW = titleTotalSize.width + imageTotalSize.width + UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + spacingBetweenImageTitle;
                    if (contentW > 0) {
                        scale = CGRectGetWidth(self.bounds) / contentW;
                    }
                    imageFrame = hasImage ? CGRectSetX(imageFrame, (self.contentEdgeInsets.left + self.imageEdgeInsets.left) * scale) : imageFrame;
                    imageFrame = hasImage ? CGRectSetWidth(imageFrame, CGRectGetWidth(imageFrame) * scale) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, (self.contentEdgeInsets.left + imageTotalSize.width + spacingBetweenImageTitle + self.titleEdgeInsets.left)) : titleFrame;
                    titleFrame = hasTitle ? CGRectSetWidth(titleFrame, CGRectGetWidth(titleFrame)) : titleFrame;
                    
                }
                    break;
            }
        }
        //图片在右
        else{
            switch (self.contentHorizontalAlignment) {
                case UIControlContentHorizontalAlignmentCenter:
                {
                    CGFloat contentW = imageTotalSize.width + spacingBetweenImageTitle + titleTotalSize.width;
                    CGFloat minX = CGRectGetCenterStartValue(contentSize.width, contentW) + self.contentEdgeInsets.left;
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, minX + self.titleEdgeInsets.left) : titleFrame;
                    imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + spacingBetweenImageTitle + self.imageEdgeInsets.left) : imageFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentLeft:
                {
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left) : titleFrame;
                    imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + spacingBetweenImageTitle) : imageFrame;
                }
                    break;
                case UIControlContentHorizontalAlignmentRight:
                    imageFrame = hasImage ? CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame)) : imageFrame;
                    titleFrame = hasTitle ? CGRectSetX(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - spacingBetweenImageTitle - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame)) : titleFrame;
                    break;
                case UIControlContentHorizontalAlignmentFill:
                {
                    CGFloat scale = 0;
                    CGFloat contentW = titleTotalSize.width + imageTotalSize.width + UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + spacingBetweenImageTitle;
                    if (contentW > 0) {
                        scale = CGRectGetWidth(self.bounds) / contentW;
                    }
                    titleFrame = hasTitle ? CGRectSetX(imageFrame, (self.contentEdgeInsets.left + self.titleEdgeInsets.left) * scale) : titleFrame;
                    titleFrame = hasTitle ? CGRectSetX(imageFrame, CGRectGetWidth(titleFrame) * scale) : titleFrame;
                    imageFrame = hasImage ? CGRectSetX(imageFrame, (self.contentEdgeInsets.left + titleTotalSize.width + spacingBetweenImageTitle + self.imageEdgeInsets.left) * scale) : imageFrame;
                    imageFrame = hasImage ? CGRectSetWidth(imageFrame, CGRectGetWidth(imageFrame) * scale) : imageFrame;
                    
                }
                    break;
            }
        }
    }
    
    self.imageView.frame = imageFrame;
    self.titleLabel.frame = titleFrame;
}

@end
