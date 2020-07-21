//
//  ShakeViewController.m
//  CodeLibrary
//
//  Created by 李金柱 on 2018/12/8.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "ShakeViewController.h"
#import "LJZShakeManager.h"
@interface ShakeViewController ()

@end

@implementation ShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [LJZShakeManager sharedInstance];
    [self performSelector:@selector(beginShake) withObject:nil afterDelay:600];
}
- (void)beginShake{
    [[LJZShakeManager sharedInstance]beginShake];
    [[LJZShakeManager sharedInstance]playSound];
    [self performSelector:@selector(stopShake) withObject:nil afterDelay:20];
}
- (void)stopShake{
       [[LJZShakeManager sharedInstance]stopShake];
       [[LJZShakeManager sharedInstance]stopPlaySound];
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
