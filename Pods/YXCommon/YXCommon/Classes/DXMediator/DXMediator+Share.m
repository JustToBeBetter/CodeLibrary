//
//  DXMediator+Share.m
//  YXCommon
//
//  Created by wenjie hua on 2017/5/4.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import "DXMediator+Share.h"

NSString * const kDXMediatorTargetShare = @"Share";
NSString * const kDXMediatorActionNativeShare= @"nativeAction";
NSString * const kDXMediatorActionNativeSinaWebShare= @"nativeActionSinaWeb";

@implementation DXMediator (Share)

- (void)mobShareWithPlatformType:(NSString *)platformType
                      withTarget:(UIViewController *)target
                       withModel:(id)model
                     withSuccess:(void(^)())success
                     withFailure:(void(^)(NSError *error))failure{
    NSDictionary *dic = @{@"platformType":platformType,@"target":target,@"model":model,@"success":success,@"failure":failure};
    [self performTarget:kDXMediatorTargetShare action:kDXMediatorActionNativeShare params:dic shouldCacheTarget:YES];
}


- (void)mobShareSinaPlatformModel:(id)model
                          success:(void(^)())success
                          failure:(void(^)(NSError *error))failure{
    
    NSDictionary *dic = @{@"model":model,@"success":success,@"failure":failure};
    [self performTarget:kDXMediatorTargetShare action:kDXMediatorActionNativeSinaWebShare params:dic shouldCacheTarget:YES];
}
@end
