//
//  MMAvatarView.h
//  MurderMystery
//
//  Created by 李金柱 on 2020/7/30.
//  Copyright © 2020 YoKa. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^_Nullable AvatarTapBlock)(void);

@interface MMAvatarView : UIView

@property (nonatomic, strong) SDAnimatedImageView *micImgView;
@property (strong,nonatomic) SDAnimatedImageView *backgroundIV;
@property (strong,nonatomic) UIImageView * avatarIV;
@property (assign,nonatomic) NSInteger userid;
@property (assign,nonatomic) CGFloat scale;

@property (assign,nonatomic) BOOL existBackground;
@property (assign,nonatomic) BOOL largeKuang;
@property (copy,nonatomic)AvatarTapBlock clickBlock;

- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl backgroundAvatar:(NSString *_Nullable)backgroundUrl clickBlock:(AvatarTapBlock)clickBlock;
- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl placeholderAvatarImgName:(NSString * _Nullable)placeholerAvatar backgroundAvatar:(NSString *)backgroundUrl placeholderBackImgName:(NSString * _Nullable)imgName largeKuang:(BOOL)largeKuang clickBlock:(AvatarTapBlock)clickBlock;
- (void)showWithUid:(NSInteger)userid avatar:(NSString *)avatarUrl backgroundAvatar:(NSString *)backgroundUrl placeholderBackImgName:(NSString *_Nullable)imgName largeKuang:(BOOL)largeKuang clickBlock:(AvatarTapBlock)clickBlock;
- (void)reloadUI;

/**加载麦克风 showLevel 显示层级 0 头像框之上 1的 头像框之下*/
- (void)loadMicImgWithMicUrl:(NSString *)micUrl showLevle:(NSInteger)showLevel;
/**展示隐藏麦克风*/
- (void)showMicphoneImg:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
