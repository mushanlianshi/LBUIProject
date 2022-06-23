//
//  LBPreventRepeatTouchUpInside.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

#import "LBPreventRepeatTouchUpInsideController.h"
#import "UIControl+LBExtension.h"

@interface LBPreventRepeatTouchUpInsideController()

@property (nonatomic, strong) UIButton *preventButton;

@property (nonatomic, strong) UIButton *normalButton;

@end

@implementation LBPreventRepeatTouchUpInsideController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.preventButton = [self createButton];
    self.normalButton = [self createButton];
    [self.view addSubview:self.preventButton];
    [self.view addSubview:self.normalButton];
    self.preventButton.tag = 1111;
    self.preventButton.lb_preventRepeatTouchUpInside = true;
    self.normalButton.tag = 2222;
    self.preventButton.frame = CGRectMake(0, 100, 200, 80);
    self.normalButton.frame = CGRectMake(0, 250, 200, 80);
}


- (void)buttonClicked:(UIButton *)button{
    NSLog(@"LBLog buttonClicked tag %@",@(button.tag));
}

- (void)buttonClickedTwoMethod:(UIButton *)button{
    NSLog(@"LBLog buttonClickedTwoMethod tag %@",@(button.tag));
}



- (UIButton *)createButton{
    UIButton *button = [[UIButton alloc] init];
    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = 10;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(buttonClickedTwoMethod:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
