//
//  DXMediator+DirectSeeding.m
//  Live
//
//  Created by wenjie hua on 2017/4/26.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXMediator+DirectSeeding.h"

NSString * const kDXMediatorTargetDirectSeeding = @"DirectSeeding";
NSString * const kDXMediatorActionNativeAllocDirectSeedingVC = @"nativeAllocDirectSeedingVC";
NSString * const kDXMediatorActionNativeAllocDirectSeedingListVC = @"nativeAllocDirectSeedingListVC";

@implementation DXMediator (DirectSeeding)
- (UIViewController *)DXMediator_DirectSeedingVCByParams:(NSDictionary *)dicParams{
    UIViewController *vcDirectSeeding = [self performTarget:kDXMediatorTargetDirectSeeding action:kDXMediatorActionNativeAllocDirectSeedingVC params:dicParams shouldCacheTarget:YES];
    if ([vcDirectSeeding isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return vcDirectSeeding;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return nil;
    }
}

- (UIViewController *)DXMediator_DirectSeedingListVCByParams:(NSDictionary *)dicParams{
    UIViewController *vcDirectSeedingList = [self performTarget:kDXMediatorTargetDirectSeeding action:kDXMediatorActionNativeAllocDirectSeedingListVC params:dicParams shouldCacheTarget:YES];
    if ([vcDirectSeedingList isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return vcDirectSeedingList;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return nil;
    }

}
@end
