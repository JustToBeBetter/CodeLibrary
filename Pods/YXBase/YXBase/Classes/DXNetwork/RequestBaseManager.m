//
//  RequestBaseManager.m
//  YXBase
//
//  Created by wenjie hua on 2017/5/19.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import "RequestBaseManager.h"

@implementation RequestBaseManager

#pragma mark - Inialize Methods
+ (instancetype)shareInstance{
    static RequestBaseManager *shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[super allocWithZone:NULL] init];
    });
    return shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self shareInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone{
    return [self shareInstance];
}

- (id)copy{
    return self;
}

@end
