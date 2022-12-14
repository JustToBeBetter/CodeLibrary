//
//  UploadToPhoneViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/12/13.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "UploadToPhoneViewController.h"
#import "MyHTTPConnection.h"

@interface UploadToPhoneViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation UploadToPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新文件" style:(UIBarButtonItemStylePlain) target:self action:@selector(rightBarButtonItemAction:)];
    [self initServer];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self reloadData];
}
- (void)rightBarButtonItemAction:(UIBarButtonItem *)bar{
    [self reloadData];
}
// 初始化本地服务器
- (void)initServer {
    HTTPServer *httpServer = [[HTTPServer alloc] init];
    [httpServer setType:@"_http._tcp."];
    //HTML文件的路径
    NSString *docRoot = [[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html" inDirectory:@"web"] stringByDeletingLastPathComponent];
    [httpServer setDocumentRoot:docRoot];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    NSError *error;
    if ([httpServer start:&error]) {
        NSLog(@"IP: %@:%hu", [LJZTool getIPAddress:YES], [httpServer listeningPort]);
    }else {
        NSLog(@"%@", error);
    }
    //保证在同一局域网内输入 ip:端口 即可开始上传
    //可电脑连接手机热点测试
}
- (void)reloadData{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSError *error = nil;
    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
    [self.dataArray  removeAllObjects];
    for (NSString *fileName in fileList) {
        [self.dataArray addObject:fileName];
    }
    [self.tableView reloadData];
}

#pragma mark ---------UITableView Delegate--------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

#pragma mark ---------lazy--------
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 100;
    }
    return _tableView;
}
- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}
@end
