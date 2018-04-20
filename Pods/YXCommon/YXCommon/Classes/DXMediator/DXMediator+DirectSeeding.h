//
//  DXMediator+DirectSeeding.h
//  Live
//
//  Created by wenjie hua on 2017/4/26.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXMediator.h"

@interface DXMediator (DirectSeeding)

- (UIViewController *)DXMediator_DirectSeedingVCByParams:(NSDictionary *)dicParams;
- (UIViewController *)DXMediator_DirectSeedingListVCByParams:(NSDictionary *)dicParams;

@end
