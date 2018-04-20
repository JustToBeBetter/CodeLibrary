//
//  DXMediator+Share.h
//  YXCommon
//
//  Created by wenjie hua on 2017/5/4.
//  Copyright © 2017年 jcapp-gold-finance. All rights reserved.
//

#import "DXMediator.h"

@interface DXMediator (Share)
/**
 @prama platformType  分享平台类型
 @param model     DXShareModel
 @param success    分享成功
 @param failure    分享失败
 
 */
- (void)mobShareWithPlatformType:(NSString *)platformType
                      withTarget:(UIViewController *)target
                       withModel:(id)model
                     withSuccess:(void(^)())success
                     withFailure:(void(^)(NSError *error))failure;

/**
 新浪web分享
 @param model     DXShareModel
 @param success    分享成功
 @param failure    分享失败
 
 */
- (void)mobShareSinaPlatformModel:(id)model
                          success:(void(^)())success
                          failure:(void(^)(NSError *error))failure;
@end
