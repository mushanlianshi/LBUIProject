//
//  LBTableViewNoStickyStyleController.m
//  LBUIProject
//
//  Created by liu bin on 2021/6/16.
//

#import "LBTableViewNoStickyStyleController.h"

@interface LBTableViewNoStickyStyleController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LBTableViewNoStickyStyleController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"label index is %zd",indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *sectionLasb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 55)];
    sectionLasb.text = @"不悬停label";
    sectionLasb.backgroundColor = [UIColor lightGrayColor];
    return sectionLasb;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 55;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"LBLog scroll %@",@(scrollView.contentOffset));
    if (scrollView.contentOffset.y > 0) {
        scrollView.contentInset  = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;;
}



@end
