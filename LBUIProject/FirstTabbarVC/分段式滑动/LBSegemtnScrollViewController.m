//
//  LBSegemtnScrollViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/7.
//

#import "LBSegemtnScrollViewController.h"

@interface LBSegemtnScrollViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, copy) NSArray *dataSources;

@end

@implementation LBSegemtnScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.tableview];
    self.tableview.frame = CGRectMake(0, 300, self.view.bounds.size.width, self.view.bounds.size.height - 300);
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NSLog(@"LBLog tableview frame %@",@(self.tableview.frame));
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@",self.dataSources[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = self.tableview.contentOffset.y;
    NSLog(@"LBLog offsetY %@",@(offsetY));
    //向下滚
    if (offsetY < 0) {
        if (self.tableview.frame.origin.y < 300) {
            self.tableview.frame = CGRectMake(0, self.tableview.frame.origin.y - offsetY, self.tableview.frame.size.width, self.tableview.frame.size.height + offsetY);
            self.tableview.contentOffset = CGPointZero;
        }
        return;
    }
    if (self.tableview.frame.origin.y <100) {
        
    }else{
        self.tableview.frame = CGRectMake(0, self.tableview.frame.origin.y - offsetY, self.tableview.frame.size.width, self.tableview.frame.size.height + offsetY);
        self.tableview.contentOffset = CGPointZero;
    }
}
 
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc] init];
        _tableview.backgroundColor = [UIColor lightGrayColor];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

- (NSArray *)dataSources{
    if (!_dataSources) {
        NSMutableArray *tmpArray = @[].mutableCopy;
        for ( int i = 0 ; i < 100; i++) {
            [tmpArray addObject:@(i)];
        }
        _dataSources = tmpArray.copy;
    }
    return _dataSources;
}

@end
