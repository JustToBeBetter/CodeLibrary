//
//  DXMediator+Login.m
//  YXCommon
//
//  Created by wenjie hua on 2017/5/16.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import "DXMediator+Login.h"
NSString * const kDXMediatorTargetLogin = @"Login";

NSString * const kDXMediatorActionNativeShowLoginVC = @"nativeShowLogin";
NSString * const kDXMediatorActionNativeSignInVC = @"nativeSignInVC";
NSString * const kDXMediatorActionNativeCaptchaVC = @"nativeCaptchaVC";
NSString * const kDXMediatorActionNativePasswordVC = @"nativePasswordVC";

@implementation DXMediator (Login)

- (UINavigationController *)DXMediator_LoginShow:(NSDictionary *)params{
    UINavigationController *vcLoginShow = [self performTarget:kDXMediatorTargetLogin action:kDXMediatorActionNativeShowLoginVC params:params shouldCacheTarget:YES];
    if ([vcLoginShow isKindOfClass:[UINavigationController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return vcLoginShow;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return nil;
    }
}

- (UIViewController *)DXMediator_SignInVC:(NSDictionary *)params{
    UIViewController *vcSignIn = [self performTarget:kDXMediatorTargetLogin action:kDXMediatorActionNativeSignInVC params:params shouldCacheTarget:YES];
    if ([vcSignIn isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return vcSignIn;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return nil;
    }
}

- (UIViewController *)DXMediator_CaptchaVC:(NSDictionary *)params{
    UIViewController *vcCaptcha = [self performTarget:kDXMediatorTargetLogin action:kDXMediatorActionNativeCaptchaVC params:params shouldCacheTarget:YES];
    if ([vcCaptcha isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return vcCaptcha;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return nil;
    }
}

- (UIViewController *)DxMediator_PasswordVC:(NSDictionary *)params{
    UIViewController *vcPasswordVC = [self performTarget:kDXMediatorTargetLogin action:kDXMediatorActionNativePasswordVC params:params shouldCacheTarget:YES];
    if ([vcPasswordVC isKindOfClass:[UIViewController class]]) {
        return vcPasswordVC;
    }else {
        return nil;
    }
}
@end
