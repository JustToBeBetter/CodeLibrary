//
//  LJZBarrageView.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "LJZBarrageView.h"

#define Padding 10.0f
#define HeadHeight  40.0f

#define kAnimationDuration  5.0

@interface LJZBarrageView  ()

@property(nonatomic, strong) UILabel *commentLab;

@property(nonatomic, strong) UIImageView *headImage;

/**
 动画时间
 */
@property(nonatomic, assign) NSTimeInterval duration;

@end

@implementation LJZBarrageView

- (instancetype)initWithComment:(NSString *)comment
{
    if(self = [super init]) {
        self.backgroundColor = [UIColor redColor];
        self.layer.cornerRadius = 15.0f;
        self.duration = kAnimationDuration;
        
        CGFloat width = [comment sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0f]}].width;
        self.bounds = CGRectMake(0, 0, width+2*Padding + HeadHeight, 30);
        self.commentLab.text = comment;
        self.commentLab.frame = CGRectMake(Padding+HeadHeight, 0, width, 30);
        
//        self.headImage.frame = CGRectMake(-Padding, -Padding, HeadHeight, HeadHeight);
//        self.headImage.layer.cornerRadius = (HeadHeight) /2.0;
//        self.headImage.layer.borderWidth = 1;
//        self.headImage.layer.borderColor = [UIColor grayColor].CGColor;
//        self.headImage.image = [UIImage imageNamed:@"head.jpg"];
    }
    return self;
}

- (void)startAnimation
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat totoalWidth = screenWidth + self.bounds.size.width;
    
    //弹幕开始
    if (self.BarrageStatusBlock) {
        self.BarrageStatusBlock(BarrageStart);
    }
    
    //速度
    CGFloat speed = totoalWidth / self.duration;
    CGFloat enterDuration = (CGRectGetWidth(self.bounds) + 2 *Padding) / speed;
    
    [self performSelector:@selector(enterScreen) withObject:nil afterDelay:enterDuration];
    
    __block CGRect frame = self.frame;
    [UIView animateWithDuration:self.duration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         frame.origin.x -= totoalWidth;
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         if (self.BarrageStatusBlock) {
                             self.BarrageStatusBlock(BarrageEnd);
                         }
                     }];
}

- (void)stopAnimation
{
    [self.layer removeAllAnimations];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)enterScreen
{
    //弹幕进入
    if (self.BarrageStatusBlock) {
        self.BarrageStatusBlock(BarrageEnter);
    }
    
}

#pragma mark - setter
- (void)setDuration:(NSTimeInterval)duration
{
    _duration = duration;
}

#pragma mark - getter
- (UILabel *)commentLab
{
    if (!_commentLab) {
        _commentLab = [[UILabel alloc] init];
        _commentLab.font = [UIFont systemFontOfSize:14.0f];
        _commentLab.textAlignment = NSTextAlignmentCenter;
        _commentLab.textColor = [UIColor whiteColor];
        [self addSubview:_commentLab];
    }
    return _commentLab;
}

- (UIImageView *)headImage
{
    if (!_headImage) {
        _headImage = [[UIImageView alloc] init];
        _headImage.clipsToBounds = YES;
    
        [self addSubview:_headImage];
    }
    return _headImage;
}


@end
