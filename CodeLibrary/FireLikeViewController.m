//
//  LJZFireLikeViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/20.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "FireLikeViewController.h"
#import "LJZFireLikeView.h"

@interface FireLikeViewController ()

@property(nonatomic ,strong)LJZFireLikeView *likeView;

@end

@implementation FireLikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:bgView];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 300,SCREEN_HEIGHT - 200 , 100, 100)];
    [button setTitle:@"点赞" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:button];
    
    self.likeView = [[LJZFireLikeView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 300, SCREEN_HEIGHT - 500, 100, 300)];
    [bgView addSubview:self.likeView];
}

- (void)fire{
    [self.likeView fireLike];
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
