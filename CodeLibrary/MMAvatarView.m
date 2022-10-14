//
//  MMAvatarView.m
//  MurderMystery
//
//  Created by 李金柱 on 2020/7/30.
//  Copyright © 2020 YoKa. All rights reserved.
//

#import "MMAvatarView.h"

#define kScale      (8.0f/11.0f)

#define kMicScale    (3.0f/4.0f)

@implementation MMAvatarView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
         self.largeKuang = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.largeKuang = YES;
    }
    return self;
}

- (void)reloadUI {
    self.backgroundColor = UIColor.clearColor;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setUI];
    });
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl backgroundAvatar:(NSString *_Nullable)backgroundUrl clickBlock:(AvatarTapBlock)clickBlock
 {
     [self showWithUid:userid avatar:avatarUrl backgroundAvatar:backgroundUrl placeholderBackImgName:nil largeKuang:YES clickBlock:clickBlock];;
}

- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl backgroundAvatar:(NSString *)backgroundUrl placeholderBackImgName:(NSString * _Nullable)imgName largeKuang:(BOOL)largeKuang clickBlock:(AvatarTapBlock)clickBlock {
    
    [self showWithUid:userid avatar:avatarUrl placeholderAvatarImgName:nil backgroundAvatar:backgroundUrl placeholderBackImgName:imgName largeKuang:largeKuang clickBlock:clickBlock];
}

- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl placeholderAvatarImgName:(NSString * _Nullable)placeholerAvatar backgroundAvatar:(NSString *)backgroundUrl placeholderBackImgName:(NSString * _Nullable)imgName largeKuang:(BOOL)largeKuang clickBlock:(AvatarTapBlock)clickBlock {

    [self.avatarIV sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:placeholerAvatar]];
    self.existBackground = (backgroundUrl.length > 0 || imgName);
    self.largeKuang = largeKuang;         //是缩小头像 还是扩大外框
    
    if (backgroundUrl.length > 0) {
        if ([backgroundUrl hasPrefix:@"http"]) {
            [self.backgroundIV sd_setImageWithURL:[NSURL URLWithString:backgroundUrl] placeholderImage:imgName ? [UIImage imageNamed:imgName] : nil];
            [self bringSubviewToFront:self.backgroundIV];
        }else{
            self.backgroundIV.image = [UIImage imageNamed:backgroundUrl];
            [self bringSubviewToFront:self.backgroundIV];
        }
    }else {
        self.backgroundIV.image =  [UIImage imageNamed:imgName];
        [self bringSubviewToFront:self.backgroundIV];
    }
    
    self.clickBlock = clickBlock;
    self.userid = userid;
    
    [self setUI];
}

- (void)setUI {
    self.backgroundColor = UIColor.clearColor;
    self.layer.masksToBounds = NO;
    CGFloat scale = self.scale > 0 ? self.scale : kScale;
    if (self.largeKuang) {
        scale = kScale;
        self.avatarIV.frame = self.bounds;
        self.backgroundIV.frame = CGRectMake(0, 0, self.width / scale, self.height / scale);
        self.backgroundIV.center = self.avatarIV.center;
    }else {
        self.backgroundIV.frame = self.bounds;
        self.avatarIV.frame = CGRectMake(0, 0, self.width * scale, self.height * scale);
        self.avatarIV.center = self.backgroundIV.center;
    }
    [self.avatarIV setCornerRadius:self.avatarIV.width/2];
    self.avatarIV.layer.masksToBounds = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarTap)];
    [self addGestureRecognizer:tap];
    
    if (_micImgView) {
        self.micImgView.frame = CGRectMake(0, 0, self.avatarIV.width / kMicScale, self.avatarIV.height / kMicScale);
        self.micImgView.center = self.avatarIV.center;
    }
}

- (void)loadMicImgWithMicUrl:(NSString *)micUrl showLevle:(NSInteger)showLevel{
    if (!micUrl) return;
    [self.micImgView sd_setImageWithURL:[NSURL URLWithString:micUrl]];
    if (showLevel) {
        [self insertSubview:self.micImgView belowSubview:self.backgroundIV];
    }else{
        [self insertSubview:self.micImgView aboveSubview:self.backgroundIV];
    }
    if (_micImgView) {
        self.micImgView.frame = CGRectMake(0, 0, self.avatarIV.width / kMicScale, self.avatarIV.height / kMicScale);
        self.micImgView.center = self.avatarIV.center;
    }
}

- (void)showMicphoneImg:(BOOL)show{
    if (_micImgView) {
        self.micImgView.hidden = !show;
    }
}

#pragma mark - avatarTap
- (void)avatarTap {
    self.clickBlock ? self.clickBlock() : nil;
}

#pragma mark - private
- (UIImageView *)avatarIV {
    if (_avatarIV == nil) {
        _avatarIV = [[UIImageView alloc] init];
        _avatarIV.layer.masksToBounds = YES;
        [self addSubview:_avatarIV];
    }
    return _avatarIV;
}

- (SDAnimatedImageView *)backgroundIV {
    if (_backgroundIV == nil) {
        _backgroundIV = [[SDAnimatedImageView alloc] init];
        [self addSubview:_backgroundIV];
    }
    return _backgroundIV;
}
- (SDAnimatedImageView *)micImgView{
    if (!_micImgView) {
        _micImgView = [[SDAnimatedImageView alloc]init];
        _micImgView.hidden = YES;
        _micImgView.userInteractionEnabled = NO;
    }
    return _micImgView;
}
@end
