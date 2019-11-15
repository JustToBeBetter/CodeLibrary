//
//  LJZShakeManager.h
//  CodeLibrary
//
//  Created by 李金柱 on 2018/12/8.
//  Copyright © 2018年 李金柱. All rights reserved.
//
/*后台播放需打开后台音乐播放模式*/
#import <Foundation/Foundation.h>

@interface LJZShakeManager : NSObject

+ (instancetype)sharedInstance;
/** 开始震动*/
- (void)beginShake;
/** 停止震动*/
- (void)stopShake;
/** 开始播放音乐*/
- (void)playSound;
/** 停止播放音乐*/
- (void)stopPlaySound;
@end
