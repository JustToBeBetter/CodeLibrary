//
//  DXMediator.h
//  Live
//
//  Created by wenjie hua on 2017/4/26.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const kYXTargetStr;
FOUNDATION_EXPORT NSString * const kYXActionStr;

@interface DXMediator : NSObject

+ (instancetype)sharedInstance;

// 远程App调用入口
- (id)performActionWithUrl:(NSURL *)url completion:(void(^)(NSDictionary *info))completion;

// 本地组件调用入口
- (id)performTarget:(NSString *)targetName action:(NSString *)actionName params:(NSDictionary *)params shouldCacheTarget:(BOOL)shouldCacheTarget;

- (void)releaseCachedTargetWithTargetName:(NSString *)targetName;
@end
