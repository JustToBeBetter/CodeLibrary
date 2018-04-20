//
//  DXHUD.h
//  Live
//
//  Created by 戴奕 on 2017/3/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXHUD : NSObject

/**
 风火轮
 */
+(void)showLoadingMessage:(NSString *)showMessage;

/**
 进度信息
 */
+(void)showProgressHud:(NSString *)title progress:(float)progress;

/**
 成功信息
 */

+(void)showSuccessHud:(NSString *)title;
+(void)showSuccessHud:(NSString *)title afterDelay:(float)second;
+(void)showSuccessHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block;

/**
 错误提示信息
 */
+(void)showErrorHud:(NSString *)title afterDelay:(float)second;

/**
 提示信息
 
 */
+(void)showInfoHud:(NSString *)title afterDelay:(float)second;
+(void)showInfoHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block;

+(void)showErrorHud:(NSString *)title afterDelay:(float)second completion:(void (^)())block;

+(void)dismissHud;

/**
 错误提示信息（只有文字）
 second 持续多少秒
 */
+ (void)showInforViewWithMessage:(NSString *)message withDelay:(CGFloat)second;

/**
 @prama message 错误信息
 @prama imgName 图片名称
 @prama second 持续多少秒
 */
+ (void)showErrorViewMessage:(NSString *)message withImagView:(NSString *)imgName withDelay:(CGFloat)second;

/**
 @prama message 成功信息
 @prama imgName 图片名称
 @prama second 持续多少秒
 */
+ (void)showSuccessMessage:(NSString *)message withImagView:(NSString *)imgName withDelay:(CGFloat)second completion:(void (^)())block;

@end
