//
//  LJZPlayer.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LJZPlayerENUM.h"

#define IOSVersion [[UIDevice currentDevice].systemVersion floatValue]

typedef NS_ENUM(NSUInteger, LJZPlayType) {
    LJZPlayTypeError,
    LJZPlayTypeAVPlayer,
};

@class LJZPlayer;

@protocol LJZPlayerDelegate <NSObject>
@optional
/**
 告知代理对象播放器状态变更
 
 @param player 调用该方法的 Player 对象
 @param state  变更之后的 Player 状态

 */
- (void)player:(nonnull LJZPlayer *)player statusDidChange:(LJZPlayerStatus)state;

/**
 告知代理对象播放器因错误停止播放
 
 @param player 调用该方法的 Player 对象
 @param error  携带播放器停止播放错误信息的 NSError 对象
 
 */
- (void)player:(nonnull LJZPlayer *)player stoppedWithError:(nullable NSError *)error;

/**
 点播已缓冲区域
 
 @param timeRange  CMTimeRange , 表示当前缓冲区域，单位秒。
 
 @waring 仅对 AVPlayer 点播有效
 

 */
- (void)player:(nonnull LJZPlayer *)player loadedTimeRange:(CMTimeRange)timeRange;

- (void)player:(nonnull LJZPlayer *)player playTime:(CMTime)time;

@end



@interface LJZPlayer : NSObject

//播放器类型
@property (nonatomic, assign, readonly) LJZPlayType type;

@property (nonatomic, assign, readonly) LJZPlayerStatus status;

@property (nonatomic, weak, nullable) id <LJZPlayerDelegate> delegate;

@property (nonatomic, copy, nullable,readonly)NSURL *URL;

@property (nonatomic, strong, nullable, readonly) UIView *playerView;

@property (nonatomic, assign, readonly) CMTime  currentTime;

@property (nonatomic, assign, readonly) CMTime  totalDuration;

@property (nonatomic, assign, readonly) BOOL isHaveLoaded;//是否开始播放（主要处理seekToTime）

/**
 仅AVPlayer使用
 AVPlayer 的 playerItem 添加输出、移除输出
 */
- (void)removeOutputObserver;
- (void)addOutputOserver;

/**
 初始化
 
 @type 播放器类型
 */
- (instancetype _Nullable )initWithPlayType:(LJZPlayType)type;

/**
 播放新视频
 
 @param URL url
 @param time 开始播放时间
 */
- (void)playWithURL:(nonnull NSURL *)URL time:(CMTime)time;

/**
 恢复播放
 */
- (void)resume;

/**
 暂停播放
 */
- (void)pause;

/**
 停止播放，和暂停播放有区别
 */
- (void)stopPlay;

/**
 开始播放
 */
- (void)play;

/**
 跳到某个时间
 
 */
- (void)seekTo:(CMTime)time;

/**
 切换码率
 
 @param URL url
 @param time 开始播放时间
 */
- (void)changeBitRateWithURL:(nullable NSURL *)URL seekTime:(CMTime)time;


@end
