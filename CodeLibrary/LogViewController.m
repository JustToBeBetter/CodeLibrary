//
//  LogViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/9/15.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    //测试日志
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
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
