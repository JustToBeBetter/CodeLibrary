//
//  LJZAVPlayer.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//
#import "LJZAVPlayer.h"
#import "LJZPlayerShowView.h"

@interface LJZAVPlayer(){
    AVPlayer *_player;
    LJZPlayerStatus _status;
}

@property (nonatomic, strong) AVPlayerItemVideoOutput *avPlayerItemVideoOutput;
@property (nonatomic, strong)  LJZPlayerShowView *playerView;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, assign) CMTime chaseTime;
@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, assign) BOOL waitPlayerReadyToSeek;
@property (nonatomic, assign) BOOL changeBitRateToSeek;
@property (nonatomic, assign) CMTimeRange  loadedTimeRange;
@property (nonatomic, assign) CMTime playTime;

@end

@implementation LJZAVPlayer

- (instancetype)init{
    self = [super init];
    if (self) {
        self.isHaveLoaded = NO;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self registerNotifications];
    }
    return self;
}

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(playerItemDidReachEnd)
     
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
     
                                               object:nil];
}

- (void)applicationDidBecomeActive
{
    _isSeeking = NO;
}

- (void)applicationWillResignActive{
    
}

- (void)dealloc{
    
    NSLog(@"----------------LJZAVPlayer 释放了");
    
    [self removeObserversFromPlayerItem];
    [self.playerItem removeOutput:self.avPlayerItemVideoOutput];
    [self.player pause];
    [self.player removeTimeObserver:self.timeObserver];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)removeObserversFromPlayerItem{
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
        [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
}

#pragma mark - Public Methods
- (void)playerWithURL:(nonnull NSURL *)URL time:(CMTime)time{
    self.URL = URL;
    self.playerItem = [AVPlayerItem playerItemWithURL:URL];
//    [_playerView setImage:[self thumbnailImageForVideo:URL atTime:0]];
    if (CMTimeGetSeconds(time) > 0) {
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        [self stopPlayingAndSeekSmoothlyToTime:time];
        
    }else{
        self.isSeeking = NO;
        self.chaseTime = CMTimeMake(-1, 1);
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        self.status = LJZPlayerStatusCaching;
        
    }
}
- (UIImage*)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
    
    if(!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
    
    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
    return thumbnailImage;
}
- (void)playerRemoveOutputObserver{
    if (IOSVersion < 9) {
        if (self.playerItem && self.playerItem.outputs.count > 0) {
            [self.playerItem removeOutput:self.avPlayerItemVideoOutput];
        }
    }
}
- (void)playerAddOutputOserver{
    if (IOSVersion < 9) {
        if (self.playerItem && self.playerItem.outputs.count == 0) {
            [self.playerItem addOutput:self.avPlayerItemVideoOutput];
        }
    }
}

- (void)playerSeekTo:(CMTime)time{
    self.isHaveLoaded = NO;
    self.status = LJZPlayerStatusCaching;
    [self stopPlayingAndSeekSmoothlyToTime:time];
}

- (void)playerChangeBitRateWithURL:(nullable NSURL *)URL seekTime:(CMTime)time{
    self.URL = URL;
    [self.player pause];
    self.playerItem = [AVPlayerItem playerItemWithURL:URL];
    UIImage *currentImage = [self getCurrentImage];
    [_playerView setImage:currentImage];
    self.changeBitRateToSeek = YES;
    self.status = LJZPlayerStatusCaching;
    
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self stopPlayingAndSeekSmoothlyToTime:time];
}

- (void)playerPause{
    [self.player pause];
    self.status = LJZPlayerStatusPaused;
}

- (void)playerStopPlay{
    [self.player pause];
    self.status = LJZPlayerStatusStop;
}

- (void)playerResume{
    [self playerPlay];
}

- (void)playerPlay{
    if (_isSeeking == NO) {
        [self.player play];
        if (self.status != LJZPlayerStatusPlaying) {
            self.status = LJZPlayerStatusPlaying;
            self.isHaveLoaded = YES;
        }
    }
    
}

- (UIImage *)getCurrentImage{
    CMTime itemTime = self.player.currentItem.currentTime;
    CVPixelBufferRef pixelBuffer = [self.avPlayerItemVideoOutput copyPixelBufferForItemTime:itemTime itemTimeForDisplay:nil];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext
                             createCGImage:ciImage
                             fromRect:CGRectMake(0, 0,
                                                 CVPixelBufferGetWidth(pixelBuffer),
                                                 CVPixelBufferGetHeight(pixelBuffer))];
    
    //当前帧的画面
    UIImage *currentImage = [UIImage imageWithCGImage:videoImage];
    CVPixelBufferRelease(pixelBuffer);
    CGImageRelease(videoImage);
    return currentImage;
}

#pragma mark - Observer Methods
//监听获得消息
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (playerItem.status) {
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"播放器数据准备好了");
                if (_waitPlayerReadyToSeek == YES) {
                    [self trySeekToChaseTime];
                }
                if (self.status != LJZPlayerStatusEnd ) {
                    self.status = LJZPlayerStatusReady;
                }
                break;
            case AVPlayerItemStatusUnknown:
                break;
            case AVPlayerItemStatusFailed:
                NSLog(@"播放器失败了");
                if (self.status != LJZPlayerStatusEnd) {
                    self.status = LJZPlayerStatusError;
                }
                if (self.status != LJZPlayerStatusEnd) {
                    self.status = LJZPlayerStatusError;
                }
                break;
            default:
                break;
        }
        
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        //监听播放器的下载进度
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        if (_isSeeking == NO)
        {
            self.loadedTimeRange = timeRange;
        }
        
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //监听播放器在缓冲数据的状态
        NSLog(@"缓冲不足暂停了");
        if (self.status != LJZPlayerStatusEnd && _isSeeking == NO && playerItem.playbackLikelyToKeepUp == NO && self.status != LJZPlayerStatusPaused) {
            [self.player pause];
            self.status = LJZPlayerStatusCaching;
            NSLog(@"缓冲不足暂停了,进入加载中状态");
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        NSLog(@"缓冲达到可播放程度了");
        if (self.status != LJZPlayerStatusEnd && self.status != LJZPlayerStatusPaused && _isSeeking == NO) {
            self.status = LJZPlayerStatusEndCaching;
            self.status = LJZPlayerStatusCaching;
            [self playerPlay];
            NSLog(@"结束加载页面");
        }
    }
}

- (void)playerItemDidReachEnd {
    NSLog(@"播放结束了");
    self.status = LJZPlayerStatusEnd;
}

- (void)updatePlayedTime:(CMTime)time{
    if (_isSeeking == NO) {
        self.playTime = time;
    }
}

#pragma mark - private Methods
- (void)stopPlayingAndSeekSmoothlyToTime:(CMTime)newChaseTime{
    NSLog(@"?????!!!%f|||%f",CMTimeGetSeconds(newChaseTime),CMTimeGetSeconds(self.chaseTime));
    if (CMTIME_COMPARE_INLINE(newChaseTime, !=, self.chaseTime) ) {
        [self.player pause];
        self.chaseTime = newChaseTime;
        _isSeeking = YES;
        [self trySeekToChaseTime];
    }
}

- (void)trySeekToChaseTime{
    if (self.player.status == AVPlayerStatusReadyToPlay && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self actuallySeekToTime];
    }else{
        // wait until item becomes ready (KVO player.currentItem.status)
        _waitPlayerReadyToSeek = YES;
    }
}

- (void)actuallySeekToTime{
    _waitPlayerReadyToSeek = NO;
    CMTime seekTimeInProgress = self.chaseTime;
    NSLog(@"----------seekTimeInProgress:%0.2f",CMTimeGetSeconds(seekTimeInProgress));
    
    if (seekTimeInProgress.timescale == 0 || seekTimeInProgress.value == -1) return;
    
    WeakSelf(self)
    [self.playerItem seekToTime:seekTimeInProgress toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        NSLog(@"+++++++++++seekTimeInProgress:%0.2f",CMTimeGetSeconds(seekTimeInProgress));
        
        if (seekTimeInProgress.value == -1) return;
        
        if (CMTIME_COMPARE_INLINE(seekTimeInProgress, ==, weakself.chaseTime))
        {
            weakself.isSeeking = NO;
            weakself.chaseTime = CMTimeMake(-1, 1);
             [(LJZPlayerShowView *)weakself.playerView setImage:nil];
            if (weakself.changeBitRateToSeek) {
                weakself.status = LJZPlayerStatusPlaying;
                weakself.changeBitRateToSeek = NO;
            }
        }
        else
        {
            [weakself trySeekToChaseTime];
        }
    }];
    if (self.player.rate == 0) {
        [self.player play];
    }
}

#pragma mark - setter and getter Methods
- (AVPlayer *)player{
    if (_player == nil) {
        _player = [[AVPlayer alloc] init];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        WeakSelf(self)
        self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [weakself updatePlayedTime:time];
        }];
    }
    return _player;
}

- (void)setPlayer:(AVPlayer * _Nullable)player{
    _player = player;
}

- (void)setPlayerItem:(AVPlayerItem * _Nullable)playerItem{
    if (_playerItem != nil) {
        [self removeObserversFromPlayerItem];
        [_playerItem removeOutput:self.avPlayerItemVideoOutput];
    }
    _playerItem = playerItem;
    if (playerItem != nil) {
        //监听PlayerItem这个类
        [_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [_playerItem addOutput:self.avPlayerItemVideoOutput];
    }
}

- (void)setURL:(NSURL * _Nullable)URL{
    _URL = URL;
}
- (LJZPlayerShowView *)playerView{
    if (_playerView == nil) {
        _playerView = [[LJZPlayerShowView alloc] init];
        _playerView.player = self.player;
    }
    return _playerView;
}

- (void)setStatus:(LJZPlayerStatus)status{
    _status = status;
}

- (CMTime)curTime{
    return self.playerItem.currentTime;
}

- (CMTime)totalDuration{
    return self.playerItem.duration;
}

- (AVPlayerItemVideoOutput *)avPlayerItemVideoOutput{
    if (_avPlayerItemVideoOutput == nil) {
        _avPlayerItemVideoOutput = [[AVPlayerItemVideoOutput alloc] init];
        [_avPlayerItemVideoOutput hasNewPixelBufferForItemTime:CMTimeMake(1, 10)];
    }
    return _avPlayerItemVideoOutput;
}

@end
