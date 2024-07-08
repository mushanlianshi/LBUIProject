//
//  LBResponseChainViewController.m
//  LBUIProject
//
//  Created by liu bin on 2022/7/25.
//

#import "LBResponseChainViewController.h"
#import "LBResponseChainManager.h"

@interface LBResponseChainViewController ()

@property (nonatomic, strong) LBResponseChainManager *chainManager;

@end

@implementation LBResponseChainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LBResponseChainResultData *data = [[LBResponseChainResultData alloc] init];
        data.type = @"3";
        LBResponseChainAAA *a = LBResponseChainAAA.new;
        LBResponseChainBBB *b = LBResponseChainBBB.new;
        LBResponseChainCCC *c = LBResponseChainCCC.new;
        LBResponseChainDDD *d = LBResponseChainDDD.new;
        self.chainManager.addData(data).addChain(a).addChain(b).addChain(c).addChain(d);
        self.chainManager.throwDataBlock = ^(id  _Nonnull data) {
            NSLog(@"LBLog data : %@",data);
        };
    });
}


- (LBResponseChainManager *)chainManager{
    if (!_chainManager) {
        _chainManager = [[LBResponseChainManager alloc] init];
    }
    return _chainManager;
}

@end
