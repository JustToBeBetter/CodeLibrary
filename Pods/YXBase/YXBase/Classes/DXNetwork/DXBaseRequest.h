//
//  DXBaseRequest.h
//  Live
//
//  Created by wenjie hua on 2017/3/14.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "YTKRequest.h"

typedef void (^DXRequestSuccessBlock)(id result);
typedef void (^DXRequesrFailedBlock)(NSString *message, NSString *statusCode, NSError *error);

@interface DXBaseRequest : YTKRequest
@property (nonatomic, assign) BOOL isNeedAccessToken;

- (void)startRequestWithCompletionBlockWithSuccess:(DXRequestSuccessBlock)success failure:(DXRequesrFailedBlock)failure;
/**
 子类API可重写该方法构建自己需要的基础参数
 
 @return NSDictionary * 基础参数字典
 */
- (NSDictionary *)createBaseArgument;

@end
