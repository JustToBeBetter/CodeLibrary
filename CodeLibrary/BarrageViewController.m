//
//  BarrageViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "BarrageViewController.h"
#import "LJZBarrageManager.h"
#import "LJZBarrageView.h"

@interface BarrageViewController ()

@property(nonatomic, strong) LJZBarrageManager *manager;

@end

@implementation BarrageViewController
- (void)dealloc
{
    [_manager stop];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addbutton];
    [self initBarrage];
    

}
- (void)initBarrage{
    _manager = [[LJZBarrageManager alloc] initWithComments:@[@"弹幕1", @"弹幕2", @"弹幕3~~~~~~~~~~~~~~~~~~~",
                                                             @"弹幕4~~~~~~~~~~", @"弹幕5~~~~~~~~~~~~~~~~~", @"弹幕6~~~~~~~~~~~~~~~",
                                                             @"弹幕7~~~~~~~~~~", @"弹幕8~~~~8~~=~~~~~~~~", @"弹幕9~~8~~~~"]];
    __weak typeof (self) weakSelf = self;
    _manager.trajectoryCount = 1;
    _manager.generateViewBlock = ^(LJZBarrageView *barrageView){
        barrageView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, barrageView.trajectory * 50 + 100, barrageView.frame.size.width, 30);
        [weakSelf.view addSubview:barrageView];
        
        [barrageView startAnimation];
    };
}
- (void)addbutton{
    UIButton *start = [[UIButton alloc]initWithFrame:CGRectMake(0, 500, 100, 50)];
    [start setTitle:@"start" forState:UIControlStateNormal];
    [start addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [start setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:start];
    
    UIButton *stop = [[UIButton alloc]initWithFrame:CGRectMake(110, 500, 100, 50)];
    [stop setTitle:@"stop" forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [stop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:stop];
    UIButton *append = [[UIButton alloc]initWithFrame:CGRectMake(210, 500, 100, 50)];
    [append setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [append setTitle:@"append" forState:UIControlStateNormal];
    [append addTarget:self action:@selector(append) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:append];
}
- (void)start{
    [_manager start];
}
- (void)stop{
    [_manager stop];
}
- (void)append{
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i<10; i++) {
        int value = arc4random()%1000;
        [array addObject:[NSString stringWithFormat:@"弹幕%d~", value]];
    }
    
    [_manager appendData:array];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
