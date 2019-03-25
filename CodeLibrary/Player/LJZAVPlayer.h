//
//  LJZAVPlayer.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LJZPlayer.h"
#import "LJZPlayerENUM.h"
@interface LJZAVPlayer : NSObject

@property (nonatomic, copy, nullable,readonly)NSURL *URL;
@property (nonatomic, assign, readonly) LJZPlayerStatus status;
@property (nonatomic, strong, nullable, readonly) UIView *playerView;
@property (nonatomic, strong, nullable, readonly) AVPlayer *player;
@property (nonatomic, strong, nullable, readonly) AVPlayerItem *playerItem;

@property (nonatomic, assign, readonly) CMTime  curTime;
@property (nonatomic, assign, readonly) CMTime  totalDuration;
@property (nonatomic, assign, readonly) CMTimeRange  loadedTimeRange;
@property (nonatomic, assign, readonly) CMTime  playTime;

@property (nonatomic, assign) BOOL isHaveLoaded;//是否开始播放（主要处理seekToTime）


/**
 AVPlayer 的 playerItem 添加输出、移除输出
 */
- (void)playerRemoveOutputObserver;
- (void)playerAddOutputOserver;

/**
 播放新视频
 
 @param URL url
 @param time 开始播放时间
 */
- (void)playerWithURL:(nonnull NSURL *)URL time:(CMTime)time;

/**
 恢复播放
 */
- (void)playerResume;

/**
 暂停播放
 */
- (void)playerPause;

/**
 停止播放，和暂停播放有区别
 */
- (void)playerStopPlay;

/**
 开始播放
 */
- (void)playerPlay;

/**
 跳到某个时间
 
 */
- (void)playerSeekTo:(CMTime)time;

/**
 切换码率
 
 @param URL url
 @param time 开始播放时间
 */
- (void)playerChangeBitRateWithURL:(nullable NSURL *)URL seekTime:(CMTime)time;

@end
