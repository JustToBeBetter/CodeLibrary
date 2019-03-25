//
//  LJZPlayer.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayer.h"
#import "LJZAVPlayer.h"
@interface LJZPlayer()

@property (nonatomic, strong) id player;

@property (nonatomic, assign) LJZPlayType type;

@property (nonatomic, assign) LJZPlayerStatus status;

@property (nonatomic, copy, nullable)NSURL *URL;

@property (nonatomic, strong, nullable) UIView *playerView;

@property (nonatomic, assign) CMTime  currentTime;

@property (nonatomic, assign) CMTime  totalDuration;

@property (nonatomic, assign) BOOL isHaveLoaded;//是否开始播放（主要处理seekToTime）

@end

@implementation LJZPlayer

- (instancetype _Nullable )initWithPlayType:(LJZPlayType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        [self playerForType];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"----------------LJZPlayer 释放了");
    [self removeObserverForPlayer];
    self.player = nil;
}

- (id)playerForType
{
    Class class;
    if (_type == LJZPlayTypeAVPlayer) {
        class = NSClassFromString(@"LJZAVPlayer");
    } else {
        class = NSClassFromString(@"LJZAVPlayer");
    }
    
    self.player = [[class alloc] init];
    self.playerView = [self.player playerView];
    
    [self addObserverForPlayer];
    
    return self.player;
}

#pragma mark - Observer Methods
- (void)addObserverForPlayer
{
    [self.player addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self.player addObserver:self
                  forKeyPath:@"URL"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self.player addObserver:self
                  forKeyPath:@"loadedTimeRange"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self.player addObserver:self
                  forKeyPath:@"playTime"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    [self.player addObserver:self
                  forKeyPath:@"isHaveLoaded"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)removeObserverForPlayer
{
    [self.player removeObserver:self forKeyPath:@"status"];
    [self.player removeObserver:self forKeyPath:@"URL"];
    [self.player removeObserver:self forKeyPath:@"loadedTimeRange"];
    [self.player removeObserver:self forKeyPath:@"playTime"];
    [self.player removeObserver:self forKeyPath:@"isHaveLoaded"];
    
}

//监听获得消息
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"URL"]) {
        self.URL = change[@"new"];
    }
    else if ([keyPath isEqualToString:@"status"]) {
        
        self.status = [change[@"new"] intValue];
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:statusDidChange:)])
        {
            [self.delegate player:self.player statusDidChange:self.status];
            
            if (self.status == LJZPlayerStatusReady) {
                self.currentTime = [self.player curTime];
                self.totalDuration = [self.player totalDuration];
            }
            
            if (self.status == LJZPlayerStatusError && self.delegate && [self.delegate respondsToSelector:@selector(player:stoppedWithError:)]) {
                [self.delegate player:self.player stoppedWithError:nil];
            }
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRange"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:loadedTimeRange:)])
        {
            CMTimeRange loadedTimeRange = [change[@"new"] CMTimeRangeValue];
            [self.delegate player:self.player loadedTimeRange:loadedTimeRange];
        }
    }
    else if ([keyPath isEqualToString:@"playTime"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(player:playTime:)])
        {
            CMTime playTime = [change[@"new"] CMTimeValue];
            [self.delegate player:self.player playTime:playTime];
        }
    }
    else if ([keyPath isEqualToString:@"isHaveLoaded"]) {
        self.isHaveLoaded = [change[@"new"] boolValue];
    }
}

#pragma mark - Public Methods
- (void)playWithURL:(nonnull NSURL *)URL time:(CMTime)time{
    [self.player playerWithURL:URL time:time];
}

- (void)removeOutputObserver{
    [self.player playerRemoveOutputObserver];
}
- (void)addOutputOserver{
    [self.player playerAddOutputOserver];
}

- (void)seekTo:(CMTime)time{
    
    [self.player playerSeekTo:time];
}

- (void)changeBitRateWithURL:(nullable NSURL *)URL seekTime:(CMTime)time{
    [self.player playerChangeBitRateWithURL:URL seekTime:time];
}

- (void)pause{
    [self.player playerPause];
}

- (void)stopPlay{
    [self.player playerStopPlay];
}

- (void)resume{
    [self.player playerResume];
}

- (void)play{
    [self.player playerPlay];
}

- (CMTime)currentTime{
    _currentTime = [self.player curTime];
    return _currentTime;
}

- (CMTime)totalDuration{
    _totalDuration = [self.player totalDuration];
    return _totalDuration;
}

@end
