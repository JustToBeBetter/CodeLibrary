//
//  ViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "ViewController.h"
#import "LJZDeveiceInfo.h"
#import <CodeLibrary-Swift.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *_dataArray;
}
@property (strong,nonatomic)UITableView *table;

@property (nonatomic, strong) UIView *headView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setTitle:@"Code"];
    [self initData];
    [self.view addSubview:self.table];
    //轻微震动
    if (@available(iOS 11.0, *))
    {
        UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [feedBackGenertor impactOccurred];
     }
    
    NSLog(@"\n device:%@\n safeTop:%f \n safeBtm:%f \n statusBarH:%f\n navBarHeight:%f",LJZDeveiceInfo.phoneType,LJZDeveiceInfo.safe_top,LJZDeveiceInfo.safe_bottom,LJZDeveiceInfo.statusBarHeight,LJZDeveiceInfo.navBarHeight);
    [self loadL2dData];
}
- (void)initData{
    _dataArray = @[@"ASR",@"UIDynamicAnimator",@"Barrage",@"FireLike",@"CountDown",@"Pages",@"GifMaker",@"FloatingView",@"Paoma",@"SegmentView",@"NetworkSpeed",@"Shake",@"PhotoMaker",@"StickyHeader",@"LJZRecord",@"LJZPlayer",@"BlurEffect",@"GifWebPImg",@"Log",@"AudioConvert",@"AppGray",@"UploadToPhone"];
}
- (void)loadL2dData{
    NSArray *dataArray = @[@"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/fayi04.zip",
          @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/luoli.zip",
          @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/xiaomi4.zip",
          @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/gzszt4.zip",
          @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/3/xiaowu.zip",
          @"https://jqsj-oss-online.oss-cn-hangzhou.aliyuncs.com/md2/live2d/1/xiaomi.zip",
    ];
    for (NSString *url in dataArray) {
        [LJZTool downLoadL2dModelWithUrl:url complete:nil];
    }
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
    
    if ([_dataArray[indexPath.row] isEqualToString:@"LJZRecord"] ||
        [_dataArray[indexPath.row] isEqualToString:@"LJZPlayer"]) {
        
        [self presentViewController:VC animated:YES completion:nil];
    }if ([_dataArray[indexPath.row] isEqualToString:@"ASR"]) {
        UIViewController *asrVC = [[ASRViewController alloc]init];
        [self.navigationController pushViewController:asrVC animated:YES];
//        asrVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
//        [self presentViewController:asrVC animated:YES completion:nil];
     }else{
        VC.title = _dataArray[indexPath.row];
        [self.navigationController pushViewController:VC animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
