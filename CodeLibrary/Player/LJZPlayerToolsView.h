//
//  LJZPlayerToolsView.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LJZPlayerENUM.h"
@protocol LJZPlayerToolsViewActionDelegate <NSObject>
- (void)play;
- (void)toolPause;
- (void)resume;
- (void)tapShowTools;
- (void)doubleTapShowTools;
- (void)sliderChangedValue:(float)value;
- (void)sliderChangingValue:(float)value;
- (void)isDraging:(BOOL)isDraging;
- (void)replayVideo;
- (void)close;
@end

@interface LJZPlayerToolsView : UIView

@property (nonatomic, weak,) id<LJZPlayerToolsViewActionDelegate> delegate;

/**
 是否是主动停止播放（与其他原因播放区别）
 */
@property (nonatomic, assign) BOOL isSelfPause;
/**
 是否在显示工具条
 */
@property (nonatomic, assign) BOOL isShowTools;

@property (nonatomic, assign) LJZPlayerViewStatus playViewStatus;

- (void)setLoaded:(CGFloat)load;
- (void)setPlayed:(CGFloat)played;
- (CGFloat)getPlayed;
- (void)setPlayedTime:(int)playedTime;
- (void)setAllTime:(int)allTime;
- (void)dismiss;
- (void)initPlayed:(CGFloat)played;

@end
