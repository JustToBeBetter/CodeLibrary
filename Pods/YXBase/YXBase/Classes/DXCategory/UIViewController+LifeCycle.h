//
//  UIViewController+LifeCycle.h
//  Live
//
//  Created by wenjie hua on 2017/3/14.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIViewController (LifeCycle)

/**
 设置VCView
 */
- (void)setUI;

/**
 设置初始值
 */
- (void)setInitialData;

/**
 请求数据
 */
- (void)requestData;

/**
 注册通知
 */
- (void)registerNotifications;

/**
 添加收势
 */
- (void)addGestures;

- (void)setIsPushVC:(BOOL)isPush;

- (BOOL)getIsPlayerVC;

@end
