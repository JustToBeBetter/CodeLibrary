//
//  DXMediator+Login.h
//  YXCommon
//
//  Created by wenjie hua on 2017/5/16.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import "DXMediator.h"

@interface DXMediator (Login)
- (UINavigationController *)DXMediator_LoginShow:(NSDictionary *)params;
- (UIViewController *)DXMediator_SignInVC:(NSDictionary *)params;
- (UIViewController *)DXMediator_CaptchaVC:(NSDictionary *)params;
- (UIViewController *)DxMediator_PasswordVC:(NSDictionary *)params;
@end
