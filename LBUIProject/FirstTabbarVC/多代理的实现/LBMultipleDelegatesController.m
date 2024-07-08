//
//  LBMultipleDelegatesController.m
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

#import "LBMultipleDelegatesController.h"
#import "NSObject+LBMultipleDelegate.h"

@interface LBMultipleDelegatesExecutor : NSObject<UITextFieldDelegate>



@end


@implementation LBMultipleDelegatesExecutor

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"LBLog %@ textFieldShouldBeginEditing", NSStringFromClass([self class]));
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"LBLog %@ shouldChangeCharactersInRange", NSStringFromClass([self class]));
    return true;
}

@end



@interface LBMultipleDelegatesController ()<UITextFieldDelegate>

@property (nonatomic, strong) LBMultipleDelegatesExecutor *secondDelegator;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UITextField *normalTextField;

@end

@implementation LBMultipleDelegatesController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"多代理";
    [self.view addSubview:self.textField];
    self.textField.frame = CGRectMake(100, 100, 200, 80);
    self.textField.lb_multipleDelegatesEnable = true;
    self.textField.delegate = self;
    self.textField.delegate = self.secondDelegator;
    
    [self.view addSubview:self.normalTextField];
    self.normalTextField.frame = CGRectMake(100, 250, 200, 80);
    self.normalTextField.delegate = self;
}



- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSLog(@"LBLog %@ textFieldShouldBeginEditing", NSStringFromClass([self class]));
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"LBLog %@ shouldChangeCharactersInRange", NSStringFromClass([self class]));
    return true;
}

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    }
    return _textField;
}

- (UITextField *)normalTextField{
    if (!_normalTextField) {
        _normalTextField = [[UITextField alloc] init];
        _normalTextField.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    }
    return _normalTextField;
}

- (LBMultipleDelegatesExecutor *)secondDelegator{
    if (!_secondDelegator) {
        _secondDelegator = [[LBMultipleDelegatesExecutor alloc] init];
    }
    return _secondDelegator;
}



@end

