//
//  LBAffineTransformController.m
//  LBUIProject
//
//  Created by liu bin on 2021/8/3.
//

#import "LBAffineTransformController.h"
#import <BLTUIKitProject/BLTUI.h>
#import "Masonry.h"
#import <GLKit/GLKit.h>

#define LIGHT_DIRECTION 0, 1, -0.5
#define AMBIENT_LIGHT 0.5


static NSInteger const kStartTag = 1000;

@interface LBAffineTransformController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIStackView *stackView;

@property (nonatomic, strong) UIImageView *transformIV;

@property (nonatomic, copy) NSArray *actionTitleArray;

@property (nonatomic, strong) UIView *faceContainerView;

@property (nonatomic, copy) NSArray <UIButton *>*faceBtnArray;

@end

@implementation LBAffineTransformController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"transform变换";
    self.view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
    [self addSubview];
    [self addActionButton];
}


- (void)addSubview{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.stackView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self.view).mas_offset(UIEdgeInsetsMake(0, 15, 0, 15));
        make.height.mas_equalTo(60);
    }];
    
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.scrollView);
        make.centerY.mas_equalTo(self.scrollView);
        make.right.mas_equalTo(self.scrollView).priorityLow();
    }];
    
    [self.view addSubview:self.transformIV];
    [self.transformIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(self.transformIV.mas_width).multipliedBy(self.transformIV.image.size.height / self.transformIV.image.size.width);
    }];
}


- (void)addActionButton{
    for (int i = 0; i < self.actionTitleArray.count; i++) {
        UIButton *actionBtn = [UIButton blt_buttonWithTitle:self.actionTitleArray[i] font:UIFontPFFontSize(14) titleColor:[UIColor blackColor] target:self selector:@selector(actionButtonClicked:)];
        actionBtn.contentEdgeInsets = UIEdgeInsetsMake(7, 15, 7, 15);
        actionBtn.layer.cornerRadius = 15;
        actionBtn.tag = kStartTag + i;
        actionBtn.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [self.stackView addArrangedSubview:actionBtn];
    }
}



- (void)actionButtonClicked:(UIButton *)button{
    NSInteger index = button.tag - kStartTag;
//    [self transformImageViewWitnActionIndex:index];
//    return;;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [self transformImageViewWitnActionIndex:index];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.transformIV.transform = CGAffineTransformIdentity;
        });
    }];
//    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        [self transformImageViewWitnActionIndex:index];
//    } completion:^(BOOL finished) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.transformIV.transform = CGAffineTransformIdentity;
//        });
//    }];
    
}


- (void)transformImageViewWitnActionIndex:(NSUInteger)index{
    switch (index) {
        case 0:
        {
            self.transformIV.layer.affineTransform = CGAffineTransformMakeRotation(M_PI_2);
        }
            break;
        case 1:
        {
            self.transformIV.layer.affineTransform = CGAffineTransformMakeScale(0.5, 0.8);
        }
            break;
        case 2:
        {
            self.transformIV.layer.affineTransform = CGAffineTransformMakeTranslation( 100, 100);
        }
            break;
//            位移旋转和旋转位移效果是不一样的
        case 3:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            //基于transform变换位移  transform变换后变成位移的  注意和CGAffineTransformMakeTranslation的区别
            transform = CGAffineTransformTranslate(transform, 100, 100);
            //基于transform旋转    transform变换后变成了 位移加旋转的
            transform = CGAffineTransformRotate(transform, M_PI_2);
            self.transformIV.layer.affineTransform = transform;
        }
            break;
        case 4:
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            transform = CGAffineTransformRotate(transform, M_PI_2);
            transform = CGAffineTransformTranslate(transform, 100, 100);
            self.transformIV.layer.affineTransform = transform;
        }
            break;
            
            //3D围绕Y周旋转  围绕Z轴旋转就是2d平面变换效果   x y轴是立体效果    翻转到背面看的效果
        case 5:
        {
            
            CATransform3D transform = CATransform3DMakeRotation(M_PI, 0, 1, 0);
            //调整m34  让看起来更立体
            transform.m34 = -1.0 / 500;
            self.transformIV.layer.transform = transform;
//            控制是否绘制两面的  如果设置NO即使旋转到背面也不会看到内容的
//            self.transformIV.layer.doubleSided = NO;
        }
            break;
            
        case 6:
        {
            [self makeShaiziView];
        }
            break;
            
        default:
            break;
    }
}


- (void)makeShaiziView{
    self.transformIV.layer.affineTransform = CGAffineTransformMakeScale(0, 0);
    [self.view addSubview:self.faceContainerView];
    [self.faceContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    
    
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0/ 500;
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
//    添加到所以子图层的变换中的transform
    self.faceContainerView.layer.sublayerTransform = perspective;
    
    //face1
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
    [self addFaceWithIndex:0 transform:transform];
//    return;
    
    //face2
    transform = CATransform3DMakeTranslation(100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addFaceWithIndex:1 transform:transform];
    
    //face3
    transform = CATransform3DMakeTranslation(0, -100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addFaceWithIndex:2 transform:transform];
    
    //add cube face 4
    transform = CATransform3DMakeTranslation(0, 100, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 1, 0, 0);
    [self addFaceWithIndex:3 transform:transform];
    
    //add cube face 5
    transform = CATransform3DMakeTranslation(-100, 0, 0);
    transform = CATransform3DRotate(transform, -M_PI_2, 0, 1, 0);
    [self addFaceWithIndex:4 transform:transform];
    //add cube face 6
    transform = CATransform3DMakeTranslation(0, 0, -100);
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    [self addFaceWithIndex:5 transform:transform];

}

//每个面添加transform
- (void)addFaceWithIndex:(NSInteger)index transform:(CATransform3D)transform{
    UIView *face = self.faceBtnArray[index];
    [self.faceContainerView addSubview:face];
    //center the face view within the container
    CGSize containerSize = self.faceContainerView.bounds.size;
    face.center = CGPointMake(containerSize.width / 2.0, containerSize.height / 2);
    // apply the transform
    face.layer.transform = transform;
    [self applyLightingToFace:face.layer];
}

//每个面添加光线
- (void)applyLightingToFace:(CALayer *)face
{
    //add lighting layer
    CALayer *layer = [CALayer layer];
    layer.frame = face.bounds;
    [face addSublayer:layer];
    //convert the face transform to matrix
    //(GLKMatrix4 has the same structure as CATransform3D)
    CATransform3D transform = face.transform;
    GLKMatrix4 matrix4 = *(GLKMatrix4 *)&transform;
    GLKMatrix3 matrix3 = GLKMatrix4GetMatrix3(matrix4);
    //get face normal
    GLKVector3 normal = GLKVector3Make(0, 0, 1);
    normal = GLKMatrix3MultiplyVector3(matrix3, normal);
    normal = GLKVector3Normalize(normal);
    //get dot product with light direction
    GLKVector3 light = GLKVector3Normalize(GLKVector3Make(LIGHT_DIRECTION));
    float dotProduct = GLKVector3DotProduct(light, normal);
    //set lighting layer opacity
    CGFloat shadow = 1 + dotProduct - AMBIENT_LIGHT;
    UIColor *color = [UIColor colorWithWhite:0 alpha:shadow];
    layer.backgroundColor = color.CGColor;
}


- (void)faceButtonClicked:(UIButton *)button{
    NSLog(@"LBLog face button clicked %@",button.currentTitle);
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIStackView *)stackView{
    if (!_stackView) {
        _stackView = [[UIStackView alloc] init];
        _stackView.spacing = 20;
        _stackView.alignment = UIStackViewAlignmentCenter;
    }
    return _stackView;
}


- (UIImageView *)transformIV{
    if (!_transformIV) {
        _transformIV = [UIImageView blt_imageViewWithImage:[UIImage imageNamed:@"face"]];
    }
    return _transformIV;
}

- (NSArray *)actionTitleArray{
    if (!_actionTitleArray) {
        _actionTitleArray = @[
            @"旋转角度",
            @"缩放比例",
            @"位移变换",
            @"位移旋转",
            @"旋转位移",
            @"3D围绕Y轴旋转",
            @"3D变换做个筛子",
        ];
    }
    return _actionTitleArray;
}


- (NSArray<UIButton *> *)faceBtnArray{
    if (!_faceBtnArray) {
        NSMutableArray *tmpArray = @[].mutableCopy;
        for (int i = 0; i < 6; i++) {
            UIButton *button = [UIButton blt_buttonWithTitle:[NSString stringWithFormat:@"%@",@(i + 1)] font:UIFontPFBoldFontSize(20) titleColor:[UIColor redColor] target:self selector:@selector(faceButtonClicked:)];
            button.backgroundColor = [UIColor whiteColor];
            button.frame = CGRectMake(0, 0, 200, 200);
            [tmpArray addObject:button];
        }
        _faceBtnArray = tmpArray.copy;
    }
    return _faceBtnArray;
}

- (UIView *)faceContainerView{
    if (!_faceContainerView) {
        _faceContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
//        _faceContainerView.backgroundColor = [UIColor whiteColor];
    }
    return _faceContainerView;
}

@end
