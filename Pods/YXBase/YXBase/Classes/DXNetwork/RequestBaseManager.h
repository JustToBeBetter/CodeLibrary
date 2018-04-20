//
//  RequestBaseManager.h
//  YXBase
//
//  Created by wenjie hua on 2017/5/19.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestBaseManager : NSObject
+ (instancetype)shareInstance;

@property (nonatomic, copy) void(^getBaseRequest)();
@property (nonatomic, copy) BOOL (^dealSuccessNetEerror)(NSDictionary *dicResponse);

@property (atomic, strong) NSDictionary *baseArgument;


@end
