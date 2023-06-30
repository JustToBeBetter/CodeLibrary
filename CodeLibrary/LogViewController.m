//
//  LogViewController.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/9/15.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "LogViewController.h"
#import <SSZipArchive/SSZipArchive.h>

@interface LogViewController ()<UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;//文件分享

@end

@implementation LogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIButton *shareBtn = [[UIButton alloc]initWithFrame:CGRectMake(120, 180, 150, 40)];
    [shareBtn setTitle:@"发送日志" forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [shareBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.layer.cornerRadius = 4;
    shareBtn.layer.masksToBounds = YES;
    shareBtn.layer.borderColor = UIColor.blackColor.CGColor;
    shareBtn.layer.borderWidth = 1;
    
    [self.view addSubview:shareBtn];
    //测试日志
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
    NSArray *arr = @[@(1)];
//    NSNumber *num = [arr objectAtIndex:1];
}

- (void)shareBtnAction{
    for (DDAbstractLogger *logger in DDLog.sharedInstance.allLoggers) {
        if ([logger isKindOfClass:DDFileLogger.class]) {
            DDFileLogger *fileLogger  =  (DDFileLogger *)logger;
            DDLogFileInfo *fileInfo = fileLogger.currentLogFileInfo;
            DDLogInfo(@"%@",fileInfo.filePath);
            [self achiveLogWithPath:fileInfo.filePath];
        }
    }
}
- (void)achiveLogWithPath:(NSString *)filePath{
    NSString *fileName = [filePath componentsSeparatedByString:@"/"].lastObject;
    NSString *fileDir = [filePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",fileName] withString:@""];
    BOOL suc = [SSZipArchive createZipFileAtPath:[self logzipTempPath] withContentsOfDirectory:fileDir withPassword:@"1234"];
    if (suc) {
        NSString *filePath = [self logzipTempPath];
        if (!self.documentController) {
            self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
                self.documentController.delegate = self;
        }else{
            self.documentController.URL = [NSURL fileURLWithPath:filePath];
        }
        [self.documentController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    }
}

- (NSString *)logzipTempPath{
    NSString *zipPath = [NSString stringWithFormat:@"%@/templog.zip",NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject];
    return zipPath;
}

#pragma mark ---------UIDocumentInteractionControllerDelegate--------
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    [controller dismissMenuAnimated:YES];
}
@end
