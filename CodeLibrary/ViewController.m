//
//  ViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
}
@property (strong,nonatomic)UITableView *table;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTitle:@"Code"];
    [self initData];
    [self.view addSubview:self.table];
}
- (void)initData{
    _dataArray = @[@"Barrage",@"FireLike",@"CountDown",@"Pages",@"GifMaker",@"FloatingView",@"Paoma",@"SegmentView",@"NetworkSpeed",@"Shake",@"PhotoMaker",@"StickyHeader"];
}
- (UITableView *)table{
    
    if (!_table) {
        _table = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _table.delegate = self;
        _table.dataSource = self;
        _table.tableFooterView = [[UIView alloc]init];
    }
    return _table;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *vcStr = [NSString stringWithFormat:@"%@ViewController",_dataArray[indexPath.row]];
    UIViewController *VC = [[NSClassFromString(vcStr) alloc]init];
    VC.title = _dataArray[indexPath.row];
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
