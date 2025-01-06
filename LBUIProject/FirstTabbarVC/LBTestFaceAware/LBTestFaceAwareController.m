//
//  LBTestFaceAwareController.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/24.
//

#import "LBTestFaceAwareController.h"
#import "LBUIProject-Swift.h"
#import "Masonry.h"
#import <FaceAware/FaceAware-Swift.h>

@interface LBTestFaceAwareController ()

@property (nonatomic, strong) UIImageView *originIV;

@property (nonatomic, strong) UIImageView *faceIV;

@end

@implementation LBTestFaceAwareController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.originIV];
    [self.view addSubview:self.faceIV];
    [self.originIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(40);
        make.top.mas_offset(200);
        make.width.height.mas_equalTo(80);
    }];
    
    [self.faceIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-40);
        make.top.bottom.width.mas_equalTo(self.originIV);
    }];
}

- (UIImageView *)originIV{
    if (!_originIV) {
        _originIV = [[UIImageView alloc] init];
        _originIV.image = [UIImage imageNamed:@"face"];
        _originIV.contentMode = UIViewContentModeScaleAspectFill;
        _originIV.layer.cornerRadius = 40;
        _originIV.clipsToBounds = YES;
    }
    return _originIV;
}

- (UIImageView *)faceIV{
    if (!_faceIV) {
        _faceIV = [[UIImageView alloc] init];
        _faceIV.image = [UIImage imageNamed:@"face"];
        _faceIV.contentMode = UIViewContentModeScaleAspectFill;
        _faceIV.layer.cornerRadius = 40;
        _faceIV.clipsToBounds = YES;
        _faceIV.focusOnFaces = YES;
    }
    return _faceIV;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
