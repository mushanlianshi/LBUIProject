//
//  UIStackViewInScrollViewController.m
//  LBUIProject
//
//  Created by liu bin on 2023/7/13.
//

#import "UIStackViewInScrollViewController.h"
#import "Masonry.h"

@interface UIStackViewInScrollViewController ()

@end

@implementation UIStackViewInScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"stackview嵌套scrollview";
    self.view.backgroundColor = [UIColor whiteColor];
    [self addScrollView];
}

- (void)addScrollView{
//    UIScrollView *scrollview = [[UIScrollView alloc] init];
//
//    [self.view addSubview:scrollview];
//    [scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
//
//    UIView*contentView = [[UIView alloc]init];
//    [scrollview addSubview:contentView];
//    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
//        //左右要约束能计算出宽度
//        make.left.right.equalTo(self.view);
//        //top要相对于ScrollView
//        make.top.equalTo(scrollview);
//        make.bottom.equalTo(scrollview);
//    }];
//
//    UIView*firstView = [[UIView alloc]init];
//    firstView.backgroundColor = [UIColor lightGrayColor];
//    [contentView addSubview:firstView];
//    [firstView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(contentView);
//        make.top.equalTo(contentView);
//        make.height.mas_equalTo(400);
//    }];
//
//    UIView*secondView = [[UIView alloc]init];
//    secondView.backgroundColor = [UIColor yellowColor];
//    [contentView addSubview:secondView];
//    [secondView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(firstView);
//        make.top.equalTo(firstView.mas_bottom);
//        make.height.mas_equalTo(400);
//
//    }];
//
//    UIView*thirdView = [[UIView alloc]init];
//    thirdView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    [contentView addSubview:thirdView];
//    [thirdView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(secondView);
//        make.top.equalTo(secondView.mas_bottom);
//        make.height.mas_equalTo(400);
//    }];
//
//    UIView*forthView = [[UIView alloc]init];
//    forthView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    [contentView addSubview:forthView];
//    [forthView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(thirdView);
//        make.top.equalTo(thirdView.mas_bottom);
//        make.height.mas_equalTo(400);
//        make.bottom.equalTo(contentView);
//    }];
    
    
    
    ///使用UIStackView其实就是换掉上面的contentView，只要ScrollView的约束能让其知道宽高，就能滚动起来。而StackView可以让我们省略子视图宽高方向的约束。代码如下：
    UIScrollView *scrollview = [[UIScrollView alloc] init];
    [self.view addSubview:scrollview];
    [scrollview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution=0;
    //靠左对齐  不设置就是子控件和父控件的宽度一样
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing=15;
    [scrollview addSubview:stackView];
    [stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(scrollview);
        make.bottom.lessThanOrEqualTo(scrollview);
    }];

    UILabel*firstLab = [[UILabel alloc]init];
    firstLab.backgroundColor = [UIColor lightGrayColor];
    firstLab.text = @"1111111111fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf1111111111111111111111111111fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf1111111111fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf1111111111fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf";
    firstLab.numberOfLines=0;
    [stackView addArrangedSubview:firstLab];

    UILabel*secondLab = [[UILabel alloc]init];
    secondLab.backgroundColor = [UIColor yellowColor];
    secondLab.text = @"111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf111\nfhwoefhwofhowefh\nfwjeohfwofhowe\n\n22222222222fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf";
    secondLab.numberOfLines=0;
    [stackView addArrangedSubview:secondLab];

//    UILabel*thirdLab = [[UILabel alloc]init];
//    thirdLab.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    thirdLab.text = @"33333333333333333333";
//    thirdLab.numberOfLines=0;
//    [stackView addArrangedSubview:thirdLab];



//    UILabel*forthLab = [[UILabel alloc]init];
//    forthLab.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
//    forthLab.text = @"4444444444444444444444fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf4444444444444444444444444444444444444444444444fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf4444444444444444444444444444444444444444444444fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf4444444444444444444444444444444444444444444444fwehfowefhowfhwoefhwoefiiiiiiiiiiiiiiiiiiwfowfhwofhwoefhwof\nwfehowfhwoehfowhfowf\nwfjhowfhwofhwofhowehfowfhwfwf444444444444444444444444";
//    forthLab.numberOfLines=0;
//    [stackView addArrangedSubview:forthLab];
}

@end
