//
//  LBTestOffScreenController.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/7.
//

#import "LBTestOffScreenController.h"

@interface LBTestOffScreenController ()

@property (nonatomic, strong) UIButton *offScreenBtnOne;

@property (nonatomic, strong) UIButton *offScreenBtnTwo;

@property (nonatomic, strong) UIButton *noOffScreenBtnOne;

@property (nonatomic, strong) UIImageView *offScreenIVOne;

@property (nonatomic, strong) UIImageView *noOffScreenIVOne;

@property (nonatomic, strong) UIView *offScreenView;

@end

@implementation LBTestOffScreenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"离屏渲染";
    self.view.backgroundColor = [UIColor whiteColor];
    [self testOffScreen];
}

- (void)testOffScreen{
    _offScreenBtnOne = [UIButton buttonWithType:UIButtonTypeCustom];
    //1.图片一个图层
//    [_offScreenBtnOne setImage:[UIImage imageNamed:@"public_icon"] forState:UIControlStateNormal];
    _offScreenBtnOne.frame = CGRectMake(100, 100, 200, 44);
    //2.背景色一个图层
    _offScreenBtnOne.backgroundColor = [UIColor redColor];
    //当切圆角的时候有两个图层，苹果无法一起切   只能一个一个图层处理，所以就会在离屏缓冲区进行处理  导致离屏渲染  如果背景色没有  就一个图层就不需要离屏渲染了
    _offScreenBtnOne.layer.cornerRadius = 20;
    _offScreenBtnOne.layer.masksToBounds = YES;
    [self.view addSubview:_offScreenBtnOne];
    
    _offScreenBtnTwo = [UIButton buttonWithType:UIButtonTypeCustom];
    //1.图片一个图层
    [_offScreenBtnTwo setImage:[UIImage imageNamed:@"public_icon"] forState:UIControlStateNormal];
    _offScreenBtnTwo.frame = CGRectMake(100, 180, 200, 44);
    //2.边框一个图层
    _offScreenBtnTwo.layer.borderWidth = 1;
    _offScreenBtnTwo.layer.borderColor = [UIColor redColor].CGColor;
    _offScreenBtnTwo.layer.cornerRadius = 10;
    _offScreenBtnTwo.backgroundColor = [UIColor lightGrayColor];
    _offScreenBtnTwo.layer.masksToBounds = YES;
    [self.view addSubview:_offScreenBtnTwo];
    
    //只有图片一个图层  不会离屏渲染
    _noOffScreenBtnOne = [UIButton buttonWithType:UIButtonTypeCustom];
    [_noOffScreenBtnOne setImage:[UIImage imageNamed:@"public_icon"] forState:UIControlStateNormal];
    _noOffScreenBtnOne.frame = CGRectMake(100, 260, 200, 44);
    _noOffScreenBtnOne.backgroundColor = [UIColor clearColor];
    _noOffScreenBtnOne.layer.cornerRadius = 10;
    _noOffScreenBtnOne.layer.masksToBounds = YES;
    [self.view addSubview:_noOffScreenBtnOne];
    
    
    _offScreenIVOne = [[UIImageView alloc] initWithFrame:CGRectMake(100, 340, 60, 60)];
    //1.图片一个图层
    _offScreenIVOne.image = [UIImage imageNamed:@"public_icon"];
    _offScreenIVOne.layer.cornerRadius = 30;
    _offScreenIVOne.layer.masksToBounds = YES;
    //2.背景色一个图层 如果背景是透明色不会触发离屏
    _offScreenIVOne.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_offScreenIVOne];
    
    
    //1.只有图片一个图层
    _noOffScreenIVOne = [[UIImageView alloc] initWithFrame:CGRectMake(100, 420, 60, 60)];
    _noOffScreenIVOne.image = [UIImage imageNamed:@"public_icon"];
    _noOffScreenIVOne.layer.cornerRadius = 30;
    _noOffScreenIVOne.layer.masksToBounds = YES;
    [self.view addSubview:_noOffScreenIVOne];
    
    //1.父view一个图层
    _offScreenView = [[UIView alloc] initWithFrame:CGRectMake(100, 500, 100, 100)];
    //2.图片一个图层
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
    imageView.image = [UIImage imageNamed:@"public_icon"];
//    UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
//    imageView.backgroundColor = [UIColor blueColor];
    [_offScreenView addSubview:imageView];
    //切圆角的时候会触发离屏渲染  如果他们不是父子控件就不会
    _offScreenView.layer.cornerRadius = 15;
    _offScreenView.layer.masksToBounds = YES;
    _offScreenView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.offScreenView];
//    NSLog(@"LBLog imageView layer %@ %@",imageView.layer,imageView.layer.contents);
    
//    同时操作了边框和背景色 也只是一个图层backgroundColor 最终也是展示在layer上
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(300, 500, 60, 60)];
    view.layer.borderColor = [UIColor redColor].CGColor;
    view.layer.borderWidth = 1;
    view.layer.cornerRadius = 15;
    view.layer.masksToBounds = YES;
    view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:view];
    NSLog(@"LBLog view layer  %@   \n %@",view.layer.backgroundColor,view.backgroundColor);
    
}


@end
