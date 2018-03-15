//
//  LJZBarrageManager.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJZBarrageView;

/**
 *  弹幕管理类，管理弹幕的一些设置，开始、结束等
 *
 */
@interface LJZBarrageManager : NSObject
/**
 *  弹幕轨道的个数
 */
@property(nonatomic) NSInteger trajectoryCount;

/**
 * 弹幕与弹幕间的间隔
 */
@property(nonatomic) NSInteger trajectoryPadding;

/**
 *  回调LJZBarrageView对象，可以对该对象进行一些处理
 */
@property(nonatomic, copy) void (^generateViewBlock)(LJZBarrageView *view);

/**
 创建弹幕管理类，并且进行初始化设置
 
 @param comments 传入评论的内容数组
 
 @return LJZBarrageView对象
 */
- (instancetype)initWithComments:(NSArray *)comments;


/**
 当有新的数据来时，进行追加
 
 @param data NSArray
 */
- (void)appendData:(NSArray *)data;

/**
 *  弹幕开始
 *
 */
- (void)start;

/**
 *  弹幕停止
 *
 */
- (void)stop;

@end
