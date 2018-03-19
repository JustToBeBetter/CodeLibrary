//
//  PaomaViewController.m
//  CodeLibrary
//
//  Created by lijz on 2018/3/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "PaomaViewController.h"
#import "LJZPaomaView.h"

@interface PaomaViewController ()

@end

@implementation PaomaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}
- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
   LJZPaomaView *paomaView = [[LJZPaomaView alloc]initWithFrame:CGRectMake(40, 100, kScreenWidth - 100, 30)];
    paomaView.center = self.view.center;
    paomaView.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
    paomaView.textColor = [UIColor redColor];
    paomaView.text = @"我是一只小小小小鸟，想要飞飞飞飞飞飞飞飞飞飞飞飞";
    [self.view addSubview:paomaView];
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
