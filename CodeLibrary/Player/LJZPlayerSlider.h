//
//  LJZPlayerSlider.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJZPlayerSliderDelegate <NSObject>

- (void)sliderChangedValue:(float)value;

- (void)sliderChangingValue:(float)value;

- (void)isDraging:(BOOL)isDraging;

@end


@interface LJZPlayerSlider : UIView


@property (nonatomic, weak) id <LJZPlayerSliderDelegate> delegate;

- (instancetype)init;

- (void)setLoaded:(CGFloat)load;

- (void)setPlayed:(CGFloat)played;

- (CGFloat)getPlayed;

- (void)initPlayed:(CGFloat)played;

@end
