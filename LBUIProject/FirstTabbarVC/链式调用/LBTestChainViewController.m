//
//  LBTestChainViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/5/13.
//

#import "LBTestChainViewController.h"
#import "LBResponseChainViewController.h"
#import "LBUIProject-Swift.h"

static NSString * const idcardCharacterSet = @"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

@interface LBTestChainViewController ()<UITextFieldDelegate>

- (instancetype)play;

- (instancetype)sing;

- (void(^)(NSString *name))sayName;

- (LBTestChainViewController *(^)(NSString *age))sayAge;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, assign) NSInteger limtCharacters;

@end


@implementation LBTestChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    可以拆解来看 self.play.sing.sayName 返回的是一个带参数 block    sayName(@"liu") 我们在调用这个block(@"name")
    self.play.sing.sayName(@"liu");
    self.play.sing.sayAge(@"23").sayName(@"liu");


    NSLog(@"LBLog -----------------------------");
    self.play.sing.sayName;
    NSLog(@"LBLog -----------------------------");

    void(^sayNameBlock)(NSString *name) = self.play.sing.sayName;
    sayNameBlock(@"liu");
    
    NSInteger max = 2 << 64;
    NSUInteger maxu = 2 << 64;
    
    NSInteger maxu1 = 9223372036854775807;
    
    NSUInteger maxu2 = 9223372036854775807;
    
    NSLog(@"LBLog max maxu %ld  %ld", max, maxu);
    NSLog(@"LBLog max maxu %ld  %ld", maxu1, maxu2);
    NSLog(@"LBLog max maxu %ld  %ld", NSIntegerMax, NSUIntegerMax);
    
    _limtCharacters = 18;
    [self.view addSubview:self.textField];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"责任链模式" style:UIBarButtonItemStyleDone target:self action:@selector(pushResponseChainVC)];
}

- (void)pushResponseChainVC{
    BLTSwiftTaskViewController *vc = [BLTSwiftTaskViewController new];
    [self.navigationController pushViewController:vc animated:true];
}

- (instancetype)play{
    NSLog(@"LBLog play =======");
    return  self;
}

- (instancetype)sing{
    NSLog(@"LBLog sing =======");
    return  self;
}

- (LBTestChainViewController *(^)(NSString *age))sayAge{
    LBTestChainViewController *(^sayBlock)(NSString *age) = ^(NSString *age){
        NSLog(@"LBLog my age is %@ =======",age);
        return self;
    };
    return sayBlock;
}

- (void(^)(NSString *name))sayName{
    NSLog(@"LBLog sayName =======");
    void(^sayBlock)(NSString *name) = ^(NSString *name){
        NSLog(@"LBLog my name is %@ =======",name);
    };
    return sayBlock;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    UITextRange *textRange = [textField markedTextRange];
//    UITextPosition *position = [textField positionFromPosition:textRange.start offset:0];
//    NSLog(@"LBLog range  %@",textRange);
//    NSLog(@"LBLog posotion %@ ",position);
    if (self.limtCharacters > 0 && textField.text.length >= self.limtCharacters && ![string isEqualToString:@""]) {
        return NO;
    }
    else if (self.limtCharacters == 18 && ![idcardCharacterSet containsString:string] && ![string isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
        _textField.font = [UIFont systemFontOfSize:16];
        
        _textField.textColor = [UIColor blackColor];
        _textField.textAlignment = NSTextAlignmentLeft;
        _textField.delegate = self;
        _textField.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
    }
    return _textField;
}

@end
