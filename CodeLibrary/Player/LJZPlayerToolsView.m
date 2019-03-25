//
//  LJZPlayerToolsView.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZPlayerToolsView.h"
#import "LJZPlayerSlider.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kProportion [[UIScreen mainScreen] bounds].size.width /375//缩放因子

@interface LJZPlayerToolsView()<LJZPlayerSliderDelegate>
{
    LJZPlayerViewStatus _oldPlayerStatus;
}
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *vToolBottom;
@property (nonatomic, strong) UIButton *btnPlayOrPause;
@property (nonatomic, strong) UILabel *lblPlayedTime;
@property (nonatomic, strong) UILabel *lblTotalTime;
@property (nonatomic, strong) LJZPlayerSlider *slider;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isChanging;

/** 双击手势播放 */
@property (nonatomic, strong) UITapGestureRecognizer *doubleTap;

@end

@implementation LJZPlayerToolsView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUI];
        [self addGestures];
        [self addNotification];
    }
    return self;
}

- (void)setUI{
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(32);
        make.left.equalTo(self).offset(12);
        make.top.equalTo(self).offset(20);
    }];
    
    [self addSubview:self.vToolBottom];
    [self.vToolBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(80));
    }];
    
    self.isPlaying = NO;
    self.isShowTools = YES;
    
}


- (void)addGestures{
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.doubleTap];
    // 解决点击当前view时候响应其他控件事件
    [self.tapGestureRecognizer setDelaysTouchesBegan:YES];
    [self.doubleTap setDelaysTouchesBegan:YES];
    // 双击失败响应单击事件
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.doubleTap];
}
- (void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseNotification) name:@"" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ResumeNotification) name:@"" object:nil];
}

- (void)pauseNotification{
    _oldPlayerStatus = self.playViewStatus;
    self.isPlaying = NO;
    [self.delegate toolPause];
}
- (void)ResumeNotification{
    if (_oldPlayerStatus == LJZPlayerViewStatusPaused) {
        [self.delegate toolPause];
    }else{
        [self.delegate resume];
    }
}
#pragma mark - public Methods
- (void)dismiss{
    
}

#pragma mark - Event Methods
- (void)closeBtnEvent:(UIButton *)sender{
    [self.delegate toolPause];
    [self.delegate close];
}
- (void)btnPlayOrPauseAction:(id)sender{
    if (self.isPlaying == NO) {
        [self.delegate resume];
    }else{
        [self.delegate toolPause];
    }
}

- (void)tapAction{
    if (self.isShowTools == NO) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tapShowTools)]) {
            [self.delegate tapShowTools];
        }
        self.vToolBottom.alpha = 0.0;
        self.vToolBottom.hidden = NO;
        self.closeBtn.hidden = NO;
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.vToolBottom.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.isShowTools = YES;
        }];
    }else{
        [self dissmiss];
    }
}

- (void)doubleTapAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(doubleTapShowTools)]) {
        [self.delegate doubleTapShowTools];
    }
}

#pragma mark - DXSliderDelegate Methods
- (void)sliderChangedValue:(float)value{
    if (value > 1) {
        value = 1;
    }else{
        [self setIsPlaying:YES];
    }
    [self.delegate sliderChangedValue:value];
}

- (void)isDraging:(BOOL)isDraging{
    [self.delegate isDraging:isDraging];
}

- (void)sliderChangingValue:(float)value {
    if (value > 1) {
        value = 1;
    }else{
        [self setIsPlaying:NO];
    }
    [self.delegate sliderChangingValue:value];
}

#pragma mark - ToolSubViewDelegate Methods
- (void)dissmiss{
    if (self.isShowTools && self.isChanging == NO) {
        [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.vToolBottom.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.vToolBottom.hidden = YES;
            self.closeBtn.hidden = YES;
            self.vToolBottom.alpha = 1.0;
            self.isShowTools = NO;
        }];
    }
    
}

- (void)showTools{
    _isShowTools = NO;
    [self tapAction];
}

- (void)resetUI{
    self.closeBtn.hidden = NO;
    self.vToolBottom.hidden = NO;
    self.vToolBottom.alpha = 1.0;
    
    self.isShowTools = YES;
}

- (void)showFullScreenBtnInSmallScreenAndVTopFullScreen{
    //    self.btnPlayOrPause.hidden = YES;
    //    self.lblPlayedTime.hidden = YES;
    //    self.lblTotalTime.hidden = YES;
    //    self.slider.hidden = YES;
    //    self.btnShare.hidden=YES;
}

- (void)setLoaded:(CGFloat)load{
    [self.slider setLoaded:load];
}

- (void)setPlayed:(CGFloat)played{
    [UIView animateWithDuration:0.1 animations:^{
        [self.slider setPlayed:played];
    }];
}

- (CGFloat)getPlayed{
    return [self.slider getPlayed];
}

- (void)initPlayed:(CGFloat)played{
    [self.slider initPlayed:played];
}

- (void)setAllTime:(int)allTime{
    self.lblTotalTime.text = [self minSecTimeFromSeconds:allTime];
}

- (void)setPlayedTime:(int)playedTime{
    self.lblPlayedTime.text = [self minSecTimeFromSeconds:playedTime];
}


- (NSString *)minSecTimeFromSeconds:(int)seconds{
    int secs = seconds % 60;
    int mins = ((seconds - secs) % 3600)/60+seconds/3600*60;
    NSString *strSecs = [self addZeroByInt:secs];
    NSString *strMins = [self addZeroByInt:mins];
    return [NSString stringWithFormat:@"%@:%@",strMins,strSecs];
    
}
- (NSString *)addZeroByInt:(int)num{
    if (num < 10) {
        if (num == 0) {
            return @"00";
        }else {
            return [NSString stringWithFormat:@"0%d",num];
        }
    }else {
        return [NSString stringWithFormat:@"%d",num];
        
    }
}

#pragma mark - UI Methods
- (void)showUIByPlaying{
    self.isChanging = NO;
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.closeBtn.hidden = NO;
        self.vToolBottom.hidden = NO;
        self.vToolBottom.alpha = 1.0;
        self.isPlaying = YES;
        [self othersUINoFullScreenIsHidden:NO];
    } completion:^(BOOL finished) {
    }];
}

- (void)showUIByPaused{
    self.isPlaying = NO;
}

- (void)showUIByEnd{
    self.closeBtn.hidden = NO;
    self.vToolBottom.hidden = NO;
    self.vToolBottom.alpha = 1.0;
    self.isChanging = NO;
     self.isPlaying = NO;
}

- (void)showUIByChangingBitRate{
    self.isChanging = YES;
    self.closeBtn.hidden = NO;
    self.vToolBottom.hidden = NO;
    self.vToolBottom.alpha = 1.0;
    
    [self othersUINoFullScreenIsHidden:YES];
}

- (void)justShowFullScreenBtn{
    self.closeBtn.hidden = NO;
    self.vToolBottom.hidden = NO;
    self.vToolBottom.alpha = 1.0;
    self.isChanging = NO;
    [self othersUINoFullScreenIsHidden:YES];
}

- (void)showUIByCaching{
    self.closeBtn.hidden = NO;
    self.vToolBottom.hidden = NO;
    self.vToolBottom.alpha = 1.0;
    self.isChanging = NO;
    [self othersUINoFullScreenIsHidden:NO];
}

- (void)othersUINoFullScreenIsHidden:(BOOL)isHidden{
    self.btnPlayOrPause.hidden = isHidden;
    self.lblTotalTime.hidden = isHidden;
    self.slider.hidden = isHidden;
    self.lblPlayedTime.hidden =isHidden;
    if (isHidden) {
        self.btnPlayOrPause.alpha = 0.0;
        self.lblPlayedTime.alpha = 0.0;
        self.lblTotalTime.alpha = 0.0;
        self.slider.alpha = 0.0;
    }else {
        self.btnPlayOrPause.alpha = 1.0;
        self.lblPlayedTime.alpha = 1.0;
        self.lblTotalTime.alpha = 1.0;
        self.slider.alpha = 1.0;
    }
}


#pragma mark - setter and getter Methods
- (UIView *)vToolBottom{
    if (_vToolBottom == nil) {
        _vToolBottom = [[UIView alloc] init];
        _vToolBottom.backgroundColor = [UIColor clearColor];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor,(__bridge id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1.0);
        gradientLayer.frame = CGRectMake(0, 0, kScreenWidth, 80);
        [_vToolBottom.layer addSublayer:gradientLayer];
        
        [_vToolBottom addSubview:self.btnPlayOrPause];
        [self.btnPlayOrPause mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(6));
            make.centerY.equalTo(self.vToolBottom).offset(3+15);
            make.width.equalTo(@(25));
            make.height.equalTo(self.vToolBottom).offset(-3);
        }];
        
        
        [_vToolBottom addSubview:self.lblPlayedTime];
        [self.lblPlayedTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnPlayOrPause).offset(1);
            make.left.equalTo(self.btnPlayOrPause.mas_right).offset(5);
            make.width.equalTo(@(52));
        }];
        
        [_vToolBottom addSubview:self.lblTotalTime];
        [self.lblTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnPlayOrPause).offset(1);
            make.width.equalTo(@(52));
            make.right.equalTo(self.vToolBottom).offset(-6*kProportion);

        }];
        
        [_vToolBottom addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.btnPlayOrPause).offset(1);
            make.right.equalTo(self.lblTotalTime.mas_left).offset(-3*kProportion);
            make.left.equalTo(self.lblPlayedTime.mas_right).offset(5);
            make.height.equalTo(@(20));
        }];
        
    }
    return _vToolBottom;
}

- (UIButton *)btnPlayOrPause{
    if (_btnPlayOrPause == nil) {
        _btnPlayOrPause = [[UIButton alloc] init];
        [_btnPlayOrPause setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [_btnPlayOrPause addTarget:self action:@selector(btnPlayOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPlayOrPause;
}
- (UIButton *)closeBtn{
    if (_closeBtn == nil) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"player_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)setIsPlaying:(BOOL)isPlaying{
    if (_isPlaying != isPlaying) {
        if (isPlaying) {
            self.btnPlayOrPause.hidden = NO;
            [self.btnPlayOrPause setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        }else {
            [self.btnPlayOrPause setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateNormal];
        }
        _isPlaying = isPlaying;
    }
}

- (void)setPlayViewStatus:(LJZPlayerViewStatus)playViewStatus{
    switch (playViewStatus) {
        case LJZPlayerViewStatusCannotPlayerNotInWiFi:
        case LJZPlayerViewStatusPrePareLastTime:
        case LJZPlayerViewStatusPrePare:
        case LJZPlayerViewStatusFailed:
            [self justShowFullScreenBtn];
            break;
        case LJZPlayerViewStatusChangingBitRate:
            [self showUIByChangingBitRate];
            break;
        case LJZPlayerViewStatusPlayingInWWAN:
        case LJZPlayerViewStatusPlayingInWiFi:
            
            [self showUIByPlaying];
            break;
        case LJZPlayerViewStatusPaused:
            [self showUIByPaused];
            break;
        case LJZPlayerViewStatusPlayEnd:
            [self showUIByEnd];
            break;
        case LJZPlayerViewStatusEndCaching:
            break;
        case LJZPlayerViewStatusCaching:
            break;
    }
    _playViewStatus = playViewStatus;
}

- (UILabel *)lblPlayedTime{
    if (_lblPlayedTime == nil) {
        _lblPlayedTime = [[UILabel alloc] init];
        _lblPlayedTime.textColor = [UIColor whiteColor];
        _lblPlayedTime.font = [UIFont systemFontOfSize:11];
        _lblPlayedTime.text = @"00:00";
    }
    return _lblPlayedTime;
}

- (UILabel *)lblTotalTime{
    if (_lblTotalTime == nil) {
        _lblTotalTime = [[UILabel alloc] init];
        _lblTotalTime.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        _lblTotalTime.font = [UIFont systemFontOfSize:11];
        _lblTotalTime.textAlignment = NSTextAlignmentRight;
        _lblTotalTime.text = @"00:00";
    }
    return _lblTotalTime;
}

- (LJZPlayerSlider *)slider{
    if (_slider == nil) {
        _slider = [[LJZPlayerSlider alloc] init];
        _slider.delegate = self;
    }
    return _slider;
}

- (UITapGestureRecognizer *)tapGestureRecognizer{
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] init];
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [_tapGestureRecognizer addTarget:self action:@selector(tapAction)];
    }
    return _tapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction)];
        _doubleTap.numberOfTouchesRequired = 1; //手指数
        _doubleTap.numberOfTapsRequired    = 2;
        
    }
    return _doubleTap;
}

- (void)setIsShowTools:(BOOL)isShowTools{
    NSLog(@"-----------isShowTool:%d---------------",isShowTools);
    _isShowTools = isShowTools;
    self.vToolBottom.hidden = !isShowTools;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
