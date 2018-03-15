//
//  LJZBarrageView.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BarrageStatus) {
    BarrageStart,
    BarrageEnter,
    BarrageEnd
};

@interface LJZBarrageView : UIView

/**
 *  当前弹幕显示在第几个轨道上
 */
@property(nonatomic, assign) NSInteger trajectory;

/**
 *  弹幕状态回调，弹幕开始（弹幕还未进入屏幕前），弹幕中（完全进入屏幕），弹幕结束（弹幕移除屏幕）
 */
@property(nonatomic, copy) void(^BarrageStatusBlock)(BarrageStatus status);

/**
 初始化弹幕
 
 @param comment 弹幕内容，后期可根据需要扩充弹幕内容，如头像
 
 @return 返回FFBarrageView对象
 */
- (instancetype)initWithComment:(NSString *)comment;

/**
 *   弹幕开始滚动动画
 */
- (void)startAnimation;


/**
 *  停止动画
 */
- (void)stopAnimation;


@end
