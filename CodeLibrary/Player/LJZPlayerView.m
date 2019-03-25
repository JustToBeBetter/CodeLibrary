//
//  LJZPlayerView.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

static const int hiddeToolsViewTime = 5;

@interface LJZPlayerView ()<LJZPlayerDelegate,LJZPlayerToolsViewActionDelegate,UIGestureRecognizerDelegate>{
    
    BOOL _isHaveSeek;
    int _intTimer;
    BOOL _isDraging;//是否在拖动进度条
    BOOL _isBackground;
}

@property (nonatomic,strong) NSURL *url;
@property (nonatomic, assign) LJZPlayerViewStatus status;//UI展示用
@property (nonatomic, assign, readonly, getter=isCanPlay) BOOL canPlay;//是否可以播放
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) BOOL isCanPlayViaWWAN;
@property (nonatomic, assign) BOOL isTouchDraing;//拖动时候取消其他的setPlaytime
@property (nonatomic, strong) NSTimer *timer;
//touch events
@property (nonatomic,assign)CGPoint startPoint;///<起始位置坐标

@property (nonatomic, assign) CGFloat beginVolumeOrLight;
/**
 是否是主动停止播放(非手动)
 */
@property (nonatomic, assign) BOOL isSelfPause;
//-------------双击手势播放 平移手势，用来控制音量、亮度、快进快退------------
typedef NS_ENUM(NSInteger, PanDirection){
    PanDirectionHorizontalMoved, // 横向移动
    PanDirectionVerticalMoved    // 纵向移动
};

//平移手势，用来控制音量、亮度、快进快退
@property (nonatomic, strong) UIPanGestureRecognizer * panRecognizer;
/** 定义一个实例变量，保存手势方向枚举值 */
@property (nonatomic, assign) PanDirection           panDirection;
/** 用来保存快进的总时长 */
@property (nonatomic, assign) CGFloat                sumTime;
/** 是否在调节音量*/
@property (nonatomic, assign) BOOL                   isVolume;
/** 音量滑杆 */
@property (nonatomic, strong) UISlider               *volumeViewSlider;
@end

@implementation LJZPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setData];
        [self setUI];
    }
    return self;
}
- (void)setUI{
    self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1];
    [self addSubview:self.vTools];
    [self.vTools mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addPlayerView];
}
- (void)setData{
    [self.vTools setPlayed:0.0];
    [self.vTools setLoaded:0.0];
    _intTimer = 0;
    [self.timer setFireDate:[NSDate distantPast]];
    
}
- (void)deallocTimer{
    [self.timer invalidate];
    self.timer = nil;
}
#pragma mark - private
- (void)update{
    if (_isDraging == NO&&_isTouchDraing ==NO) {
        _intTimer ++;
        if (_intTimer == hiddeToolsViewTime && _status == LJZPlayerStatusPlaying) {
            _intTimer = 0;
            [self.vTools dismiss];
        }
    }
}
- (void)playWithUrl:(NSURL *)url{
    self.url = url;
    [self addPlayerView];
    [self playVideo];
}

- (void)addPlayerView{
    if (self.player.status != LJZPlayerStatusError) {
        UIView *playerView = self.player.playerView;
        if (playerView != nil && playerView.superview == nil) {
            playerView.contentMode = UIViewContentModeScaleAspectFit;
            
            [self insertSubview:playerView belowSubview:self.vTools];
            [self.player.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
    }
}
- (void)playVideo{
    self.vTools.isShowTools = YES;
    self.time = 0;

    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:self.url options:opts];  // 初始化视频媒体文件
    int second = (int)urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
    [self.vTools setAllTime:second];
    [self.player playWithURL:self.url time:CMTimeMake((int)(self.time * 10000), 10000)];
}

- (void)verticalMoved:(CGFloat)value {
    self.isVolume ? (self.volumeViewSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}
- (void)initToolsTime{
    NSTimeInterval currentTime = CMTimeGetSeconds(self.player.currentTime);
    NSTimeInterval allTime = CMTimeGetSeconds(self.player.totalDuration);
    int time = (int)currentTime;
    int time2 = (int)allTime;
    [self.vTools setPlayedTime:time];
    [self.vTools setAllTime:time2];
    if (time==0) {
        [self.vTools initPlayed:0];
    }
}
/**
 *  pan水平移动的方法
 *
 *  @param value void
 */
- (void)horizontalMoved:(CGFloat)value {
    // 每次滑动需要叠加时间
    self.sumTime += value / 200;
    
    // 需要限定sumTime的范围
    CMTime totalTime           = self.player.totalDuration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.sumTime > totalMovieDuration) { self.sumTime = totalMovieDuration;}
    if (self.sumTime < 0) { self.sumTime = 0; }
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) { return; }
    
    
    [self.vTools setPlayedTime:_sumTime];
    float progress = _sumTime/totalMovieDuration;
    [self.vTools setPlayed:progress];

}
/**
 *  获取系统音量
 */
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
    
}
- (int)getDragingTimeByValue:(CGFloat)value{
    return (int)(CMTimeGetSeconds(self.player.totalDuration) * value);
}
- (void)playOrPause{
    if (self.player.status == LJZPlayerStatusPaused) {
        [self.player resume];
    }else {
        self.isSelfPause = NO;
        [self.player pause];
    }
}
- (void)playMedia{
    [self.player stopPlay];
    [self.player playWithURL:self.url time:CMTimeMake((int)(self.time * 10000), 10000)];
}
#pragma mark - LJZPlayerDelegate
- (void)player:(nonnull LJZPlayer *)player statusDidChange:(LJZPlayerStatus)state{
    switch (state) {
        case LJZPlayerStatusReady:
//            [self.vTools addGestureRecognizer:self.panRecognizer];
            break;
        case LJZPlayerStatusEndCaching:
            [self setStatus:LJZPlayerViewStatusEndCaching];
            break;
        case LJZPlayerStatusCaching:
            if (self.status != LJZPlayerViewStatusChangingBitRate && self.status != LJZPlayerViewStatusPrePare && self.status != LJZPlayerViewStatusPrePareLastTime) {
                [self setStatus:LJZPlayerViewStatusCaching];
            }
            break;
        case LJZPlayerStatusPaused:
            [self setStatus:LJZPlayerViewStatusPaused];
            break;
            
        case LJZPlayerStatusPlaying:
            self.isSuccessLoad = YES;
            [self initToolsTime];
            self.player.playerView.hidden = NO;
            [self setStatus:LJZPlayerViewStatusPlayingInWWAN];
            
            break;
        case LJZPlayerStatusError:
            break;
        case LJZPlayerStatusEnd:
            [self setStatus:LJZPlayerViewStatusPlayEnd];
            break;
        default:
            break;
    }
}

- (void)player:(nonnull LJZPlayer *)player stoppedWithError:(nullable NSError *)error{
    [self setStatus:LJZPlayerViewStatusFailed];
}
- (void)player:(nonnull LJZPlayer *)player loadedTimeRange:(CMTimeRange)timeRange{
    NSTimeInterval timeLoaded = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval allTime = CMTimeGetSeconds(self.player.totalDuration);
    if (allTime > 0) {
        double loadPercent = timeLoaded/allTime;
        if (loadPercent  < 0) {
            loadPercent  = 0;
        }else if (loadPercent  > 1){
            loadPercent  = 1;
        }
        [self.vTools setLoaded:loadPercent];
    }else{
        [self.vTools setLoaded:0.0];
    }

}

- (void)player:(nonnull LJZPlayer *)player playTime:(CMTime)time{
    
//    if (self.status == LJZPlayerViewStatusChangingBitRate || self.status == LJZPlayerViewStatusCaching || _isDraging||_isTouchDraing) {
//        return;
//    }
    NSTimeInterval allTime = CMTimeGetSeconds(self.player.totalDuration);
    NSTimeInterval currentTime = CMTimeGetSeconds(time);
    
    int timeSeconds = (int)currentTime;
    if (timeSeconds < 0) {
        timeSeconds = 0;
    }
    [self.vTools setPlayedTime:timeSeconds];
    if (allTime > 0 && currentTime > 0) {
        double playPercent = currentTime/allTime;
        if (playPercent < 0) {
            playPercent = 0;
        }else if (playPercent > 1){
            playPercent = 1;
        }
        [self.vTools setPlayed:playPercent];
    }else {
        [self.vTools setPlayed:0.0];
    }

}


#pragma mark - LJZPlayerToolsViewActionDelegate

- (void)play{
    if (self.status == LJZPlayerViewStatusPlayEnd) {
        [self playMedia];
    }else{
        [self.player resume];
    }
}
- (void)close{
    if (self.closeBlock) {
        [self deallocTimer];
        self.closeBlock();
    }
}
- (void)toolPause{
    self.isSelfPause = NO;
    _intTimer = 0;
    [self.player pause];
}
- (void)resume{
     _intTimer = 0;
    if (self.status == LJZPlayerViewStatusPlayEnd) {
        [self playMedia];
    }else{
        [self.player resume];
    }
}
- (void)tapShowTools{
    _intTimer = 0;
}
- (void)doubleTapShowTools{
    [self playOrPause];
}
- (void)sliderChangedValue:(float)value{
    self.status = LJZPlayerViewStatusCaching;
    CMTime time = CMTimeMultiplyByFloat64(self.player.totalDuration, value);
    if (CMTIME_COMPARE_INLINE(time, ==, self.player.totalDuration)) {
    
    }else{
        [self.player seekTo:time];
    }
     [self.vTools setPlayedTime:[self getDragingTimeByValue:value]];
}
- (void)sliderChangingValue:(float)value{
     [self.vTools setPlayedTime:[self getDragingTimeByValue:value]];
}
- (void)isDraging:(BOOL)isDraging{
     _isDraging = isDraging;
}
- (void)replayVideo{
    self.time = 0;
    self.status = LJZPlayerViewStatusPrePare;
    [self playMedia];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if ([touch.view isKindOfClass:[UISlider class]]) {
        return NO;
    }
    
    return YES;
}

#pragma mark - UIPanGestureRecognizer 手势方法

/**
 *  pan手势事件
 *
 *  @param pan UIPanGestureRecognizer
 */
- (void)panDirection:(UIPanGestureRecognizer *)pan {
    
    
    //根据在view上Pan的位置，确定是调音量还是亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
    
    //打点记录初始值
    CGFloat begin = 0;
    
    // 判断是垂直移动还是水平移动
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{ // 开始移动
            
            _isDraging = YES;
            
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                // 取消隐藏
                
                self.panDirection = PanDirectionHorizontalMoved;
                // 给sumTime初值
                CMTime time       = self.player.totalDuration;
                self.sumTime      = [self.vTools getPlayed]*time.value/time.timescale;
            }
            else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 开始滑动的时候,状态改为正在控制音量
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                    begin = self.volumeViewSlider.value;
                    self.beginVolumeOrLight = begin;
                }else { // 状态改为显示亮度调节
                    self.isVolume = NO;
                    begin = [UIScreen mainScreen].brightness;
                    self.beginVolumeOrLight = begin;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{ // 正在移动
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case UIGestureRecognizerStateEnded:{ // 移动停止
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            _isDraging = NO;
            
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    
                    CMTime totalTime           = self.player.totalDuration;
                    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
                    float value = _sumTime/totalMovieDuration;
                    [self sliderChangedValue:value];
                    
                    // 把sumTime滞空，不然会越加越多
                    self.sumTime = 0;
                    break;
                }
                case PanDirectionVerticalMoved:{
                    // 垂直移动结束后，把状态改为不再控制音量
                    self.isVolume = NO;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}
#pragma mark setter and getter Methods
- (void)setStatus:(LJZPlayerViewStatus)status{
    _status = status;
    [self.vTools setPlayViewStatus:status];
}
- (NSTimer *)timer{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (LJZPlayer *)player{
    if (_player == nil) {
        _player = [[LJZPlayer alloc] initWithPlayType:LJZPlayTypeAVPlayer];
        _player.delegate = self;
    }
    return _player;
}

- (LJZPlayerToolsView *)vTools{
    if (_vTools == nil) {
        _vTools = [[LJZPlayerToolsView alloc] init];
        _vTools.delegate = self;
        _vTools.hidden = NO;
    }
    return _vTools;
}

- (UIPanGestureRecognizer *)panRecognizer{
    if (_panRecognizer == nil) {
        
        // 添加平移手势，用来控制音量、亮度、快进快退
        _panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        _panRecognizer.delegate = self;
        [_panRecognizer setMaximumNumberOfTouches:1];
        [_panRecognizer setDelaysTouchesBegan:YES];
        [_panRecognizer setDelaysTouchesEnded:YES];
        [_panRecognizer setCancelsTouchesInView:YES];
        
        // 获取系统音量
        [self configureVolume];
        
        
    }
    return _panRecognizer;
}


@end
