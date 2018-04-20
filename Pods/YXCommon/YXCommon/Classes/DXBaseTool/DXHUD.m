//
//  DXHUD.m
//  Live
//
//  Created by 戴奕 on 2017/3/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXHUD.h"
#import "SVProgressHUD.h"

@implementation DXHUD

+ (void)showLoadingMessage:(NSString *)showMessage {
    if ([SVProgressHUD isVisible]) {
        return;
    }
    
    [self setDefaultStyle];
    if (showMessage) {
        [SVProgressHUD showWithStatus:showMessage];
    }else {
        [SVProgressHUD show];
    }
}

+ (void)dismissHud {
    [SVProgressHUD dismiss];
}

+ (void)showSuccessHud:(NSString *)title {
    [self showSuccessHud:title afterDelay:0.75];
}

+ (void)showSuccessHud:(NSString *)title afterDelay:(float)second {
    [self setDefaultStyle];
    [SVProgressHUD showSuccessWithStatus:title];
    
    [self delayDismissInSecond:second];
}

+ (void)showSuccessHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block {
    [self setDefaultStyle];
    [SVProgressHUD showSuccessWithStatus:title];
    
    [self delayDismissInSecond:second completion:^{
        if (block) {
            block();
        }
    }];
}

+ (void)showProgressHud:(NSString *)title progress:(float)progress {
    [self setDefaultStyle];
    if (title==nil) {
        [SVProgressHUD showProgress:progress];
    }else{
        [SVProgressHUD showProgress:progress status:title];
    }
}

+ (void)showErrorHud:(NSString *)title afterDelay:(float)second {
    [self setDefaultStyle];
    [SVProgressHUD showErrorWithStatus:title];
    
    [self delayDismissInSecond:second];
}

+ (void)showErrorHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block {
    [self setDefaultStyle];
    [SVProgressHUD showErrorWithStatus:title];
    
    [self delayDismissInSecond:second completion:^{
        if (block) {
            block();
        }
    }];
}


+ (void)showInfoHud:(NSString *)title afterDelay:(float)second {
    [self setDefaultStyle];
    [SVProgressHUD showInfoWithStatus:title];
    
    [self delayDismissInSecond:second];
}

+(void)showInfoHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block {
    [self setDefaultStyle];
    [SVProgressHUD showInfoWithStatus:title];
    
    [self delayDismissInSecond:second completion:^{
        if (block) {
            block();
        }
    }];
}

+ (void)setDefaultStyle{
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setBackgroundColor:[UIColor whiteColor]];
}

+ (void)showInforViewWithMessage:(NSString *)message withDelay:(CGFloat)second{
    
    [self setProgressHud];
    CGSize size = [self calculateTextLengthWithMessage:message];
    [SVProgressHUD setMinimumSize:CGSizeMake(size.width+40, 51)];
    [SVProgressHUD showImage:nil status:message];
    [self delayDismissInSecond:second];
    
}

+ (void)showErrorViewMessage:(NSString *)message withImagView:(NSString *)imgName withDelay:(CGFloat)second{
    
    [self setProgressHud];
    [SVProgressHUD setMinimumSize:CGSizeMake(130, 90)];
    
    [SVProgressHUD showImage:[UIImage imageNamed:imgName] status:message];
    
    [self delayDismissInSecond:second];
}
+ (void)showSuccessMessage:(NSString *)message withImagView:(NSString *)imgName withDelay:(CGFloat)second completion:(void (^)())block{
    [self setProgressHud];
    [SVProgressHUD setMinimumSize:CGSizeMake(130, 90)];
    
    [SVProgressHUD showImage:[UIImage imageNamed:imgName] status:message];
    
    [self delayDismissInSecond:second completion:^{
        if (block) {
            block();
        }
    }];
}

#pragma mark -- private Method
+ (void)setProgressHud{
    
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8f]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setBackgroundLayerColor:[UIColor clearColor]];
    [SVProgressHUD setFont:[UIFont systemFontOfSize:15.0f]];
    [SVProgressHUD setCornerRadius:6.0];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
}


+ (CGSize)calculateTextLengthWithMessage:(NSString *)message{
    return [message sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0f]}];
}

/**
 延迟多少s后消失
 */
+ (void)delayDismissInSecond:(float)second {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

+ (void)delayDismissInSecond:(float)second completion:(void (^)())block {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(second * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        if (block) {
            block();
        }
    });
}


@end
