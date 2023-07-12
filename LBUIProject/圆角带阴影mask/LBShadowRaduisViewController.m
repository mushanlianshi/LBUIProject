//
//  LBShadowRaduisViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/17.
//

#import "LBShadowRaduisViewController.h"
#import "Masonry.h"
#import <BLTUIKitProject/BLTUI.h>
#import "LBUIProject-Swift.h"


//添加阴影的view的背景色一定不能是clearColor   不然展示不出来阴影
@interface LBShadowRaduisViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIStackView *verticalStackView;

@property (nonatomic, strong) BLTCornerGradientShadowButton *cornerGradientShadowView;

@end

@implementation LBShadowRaduisViewController


- (BLTCornerGradientShadowButton *)cornerGradientShadowView{
    if (!_cornerGradientShadowView) {
        _cornerGradientShadowView = [[BLTCornerGradientShadowButton alloc] init];
//        [_cornerGradientShadowView setGradientParams:[UIColor blueColor] :[UIColor redColor] startLocation:CGPointMake(0, 0.5) endLocation:CGPointMake(1, 0.5) locations:nil];
        [_cornerGradientShadowView setGradientParams:[UIColor blueColor] :[UIColor redColor] direction:BLTGradientDirectionLeftToRight locations:nil];
        [_cornerGradientShadowView setShadowParams:[UIColor greenColor] shadowRadius:5 shadowOffset:CGSizeMake(0, 0) shadowOpacity:1 shadowPath:nil];
        _cornerGradientShadowView.customCornerRadius = 24;
        _cornerGradientShadowView.backgroundColor = [UIColor yellowColor];
    }
    return _cornerGradientShadowView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self addSubview];
    [self addShadowView];
    [self addMaskLayerView];
    [self addRasterizeView];
    [self addReciptView];
    [self customCornerRaduis];
    [self dealTextNotHiddenBelowImage];
}



//1.类似哔哩哔哩弹幕不遮挡视频的   弹幕的mask是AI下发生成的任务图像的image  设置弹幕的mask是人物图片的imageView  不透明部分就会展示文字   任务透明部分就不会遮住弹幕了
- (void)dealTextNotHiddenBelowImage{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = UIImageNamed(@"face");
    [self.view addSubview:imageView];
    [self.view insertSubview:imageView atIndex:0];
    imageView.frame = self.view.bounds;
}

- (void)addSubview{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.verticalStackView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.verticalStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.scrollView).mas_offset(40);
        make.bottom.mas_equalTo(self.scrollView).mas_offset(-100).priorityLow();
    }];
}


- (void)addShadowView{
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 10;
    view.layer.borderWidth = 1;
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.shadowColor = [UIColor blueColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,0);
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowRadius = 2;
    view.backgroundColor = [UIColor whiteColor];
    [self.verticalStackView addArrangedSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    
    
    [self.view addSubview:self.cornerGradientShadowView];
    [self.cornerGradientShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(100, 48));
        make.centerY.equalTo(self.view);
    }];
    
    
    UIView *view2 = [[UIView alloc] init];
    view2.layer.cornerRadius = 20;
    view2.layer.shadowColor = [UIColor blueColor].CGColor;
    view2.layer.shadowOffset = CGSizeMake(0,0);
    view2.layer.shadowOpacity = 0.8;
    view2.layer.shadowRadius = 2;
    view2.backgroundColor = [UIColor whiteColor];
    [self.verticalStackView addArrangedSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    
    //阴影带裁剪的  套一层
    UIView *shadowView = [[UIView alloc] init];
    shadowView.layer.cornerRadius = 10;
    shadowView.layer.shadowRadius = 5;
    shadowView.layer.shadowOpacity = 0.8;
    shadowView.layer.shadowColor = [UIColor blueColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.backgroundColor = [UIColor whiteColor];
    [self.verticalStackView addArrangedSubview:shadowView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"face"];
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = YES;
    [shadowView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(100);
        make.edges.mas_equalTo(shadowView);
    }];
}


- (void)addMaskLayerView{
    
    UIView *testView = [[UIView alloc] init];
    testView.backgroundColor = [UIColor lightGrayColor];
    
    
    //1.mask效果
    UIImageView *containerIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    containerIV.image = [UIImage imageNamed:@"face"];
    
//    layer 的内容中的才展示   会拿masklayer内容不透明的部分做遮罩  我们只展示五角星的mask内容
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = containerIV.bounds;
    layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"mask_five_star"].CGImage);
//    containerIV.layer.mask = layer;
    testView.layer.mask = layer;
    
    [self.verticalStackView addArrangedSubview:testView];
    [testView addSubview:containerIV];
    
    [testView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(150);
    }];
    
    [containerIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(100);
        make.center.equalTo(testView);
    }];
    
    

    //2.mask实现文字渐变  用label展示的文字内容不透明  做为遮罩  这样展示的正好是文字下的渐变layer
    UILabel *grandientLabel = [UILabel blt_labelWithTitle:@"文字渐变色文字渐变色文字渐变色" font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor]];
//    不能有不透明的背景色  不然就底下就都展示了
//    grandientLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
//    grandientLabel.alpha = 0.1;
    [grandientLabel sizeToFit];
    
    CAGradientLayer *grandientLayer = [[CAGradientLayer alloc] init];
    grandientLayer.startPoint = CGPointMake(0, 0);
    grandientLayer.endPoint = CGPointMake(1, 1);
    grandientLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor];
    grandientLayer.frame = grandientLabel.bounds;
    grandientLayer.mask = grandientLabel.layer;
    
    UIView *grandientView = [[UIView alloc] init];
    [grandientView.layer addSublayer:grandientLayer];
    
    [self.verticalStackView addArrangedSubview:grandientView];
    [grandientView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(grandientLabel.bounds.size);
    }];
    
    
//    3.用图片颜色实现渐变文字 这样更丰富
    UIColor *grandientColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_image_color"]];
    UILabel *imageGrandientLabel = [UILabel blt_labelWithTitle:@"文字渐变色文字渐变色文字渐变色文字渐变色文字渐变色文字渐变色" font:UIFontPFFontSize(14) textColor:grandientColor];
    imageGrandientLabel.preferredMaxLayoutWidth = self.view.blt_width - 60;
    imageGrandientLabel.numberOfLines = 0;
    [self.verticalStackView addArrangedSubview:imageGrandientLabel];
    [imageGrandientLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(grandientView.mas_bottom).mas_offset(40);
        make.centerX.mas_equalTo(self.view);
    }];
}


//测试shouldRasterize透明度问题
- (void)addRasterizeView{
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.spacing = 30;
    [self.verticalStackView addArrangedSubview:stackView];
    UIButton *normalBtn = [self customButton];
//    normalBtn.alpha = 0.5;
    [stackView addArrangedSubview:normalBtn];
    
    
    UIButton *rasterizeBtn = [self customButton];
    rasterizeBtn.alpha = 0.5;
    [stackView addArrangedSubview:rasterizeBtn];
//    rasterizeBtn.layer.shouldRasterize = YES;
//    rasterizeBtn.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    
    
//    UIButton *normalBtn = [[UIButton alloc] init];
//    normalBtn.alpha = 0.4;
//    normalBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
//    UILabel *label = [UILabel blt_labelWithTitle:@"label" font:UIFontPFFontSize(14) textColor:[UIColor blackColor]];
//    label.backgroundColor = [UIColor whiteColor];
//    [normalBtn addSubview:label];
//    [stackView addArrangedSubview:normalBtn];
//    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(normalBtn);
//    }];
//
//
//    UIButton *rasterizeBtn = [[UIButton alloc] init];
//    rasterizeBtn.alpha = 0.4;
//    rasterizeBtn.contentEdgeInsets = UIEdgeInsetsMake(10, 20, 10, 20);
//    rasterizeBtn.layer.shouldRasterize = YES;
//    rasterizeBtn.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    UILabel *rasterizeLabl = [UILabel blt_labelWithTitle:@"label" font:UIFontPFFontSize(14) textColor:[UIColor blackColor]];
//    rasterizeLabl.backgroundColor = [UIColor whiteColor];
//    [rasterizeBtn addSubview:rasterizeLabl];
//    [stackView addArrangedSubview:rasterizeBtn];
//    [rasterizeLabl mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(rasterizeBtn);
//    }];
}

//重复指示的view
- (void)addReciptView{
    UIView *replicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    replicatorView.layer.cornerRadius = 50;
    replicatorView.backgroundColor = [UIColor whiteColor];
    [self.verticalStackView addArrangedSubview:replicatorView];
    [replicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.frame = replicatorView.bounds;
    [replicatorView.layer addSublayer:replicatorLayer];
    
    //重复的个数
    replicatorLayer.instanceCount = 10;
    CATransform3D transform = CATransform3DIdentity;
//    transform = CATransform3DTranslate(transform, 0, 10, 0);
    //10个围成一圈
    transform = CATransform3DRotate(transform, M_PI / 5, 0, 0, 1);
//    transform = CATransform3DTranslate(transform, 0, -10, 0);
    replicatorLayer.instanceTransform = transform;
    //颜色渐变
    replicatorLayer.instanceRedOffset = -0.1;
    replicatorLayer.instanceBlueOffset = -0.1;
    
    //创建子sublayer的样式
    CAShapeLayer *subCircleLayer = [CAShapeLayer layer];
    subCircleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    subCircleLayer.frame = CGRectMake(0, 0, 20, 20);
    subCircleLayer.cornerRadius = 10;
    subCircleLayer.masksToBounds = YES;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.duration = 2;
    scaleAnimation.repeatCount = NSIntegerMax;
    scaleAnimation.fromValue = @(1);
    scaleAnimation.toValue = @(0.7);
    scaleAnimation.removedOnCompletion = false;
    scaleAnimation.fillMode = kCAFillModeForwards;
    [subCircleLayer addAnimation:scaleAnimation forKey:nil];
    [replicatorLayer addSublayer:subCircleLayer];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 2;
    animation.repeatCount = NSIntegerMax;
    animation.fromValue = @(0);
    animation.toValue = @(M_PI * 2);
    [replicatorLayer addAnimation:animation forKey:@""];
}

- (void)customCornerRaduis{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    customView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    [self.verticalStackView addArrangedSubview:customView];
    [customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:customView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake((10), 10)];
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = customView.bounds;
    layer.path = path.CGPath;
//    默认是black  所以我们用mask做遮罩的时候    layer 用path做遮罩的时候   可以不设置颜色  默认就是black
//    layer.fillColor = [UIColor blackColor].CGColor;
    customView.layer.mask = layer;
    NSLog(@"LBLog layer background %@",layer.backgroundColor);
    
    UIView *customView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    customView2.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.4];
    [self.verticalStackView addArrangedSubview:customView2];
    [customView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    
    UIBezierPath *path2 = [UIBezierPath bezierPathWithRoundedRect:customView2.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake((10), 10)];
    CAShapeLayer *layer2 = [[CAShapeLayer alloc] init];
    layer2.frame = customView2.bounds;
//    注意  不要设置layer的backgroundColor  不然layer的背景色没有圆角 就没效果了 会真个mask到下一层级 就没效果了  要用layer的fillColor去做
//    layer2.cornerRadius = 10;
    layer2.backgroundColor = [UIColor whiteColor].CGColor;
//    layer2.fillColor = [UIColor clearColor].CGColor;
    layer2.path = path2.CGPath;
    customView2.layer.mask = layer2;
    NSLog(@"LBLog layer background %@",layer2.backgroundColor);
}


- (UIButton *)customButton
{
    //create button
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 10;
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(160, 50));
    }];
    
    //add label
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Hello World";
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(button);
    }];
    return button;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
    }
    return _scrollView;
}

- (UIStackView *)verticalStackView{
    if (!_verticalStackView) {
        _verticalStackView = [[UIStackView alloc] init];
        _verticalStackView.axis = UILayoutConstraintAxisVertical;
        _verticalStackView.spacing = 40;
        _verticalStackView.alignment = UIStackViewAlignmentCenter;
    }
    return _verticalStackView;
}

@end
