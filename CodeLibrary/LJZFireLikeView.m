//
//  LJZFireLikeView.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/20.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "LJZFireLikeView.h"
#define ARC_RANDOM(range) (arc4random() % (range)) / 100.f

@interface LJZFireLikeView()<CAAnimationDelegate>

@end
@implementation LJZFireLikeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.clipsToBounds = NO;
    }
    return self;
}


- (void)fireLike
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.randomLikeImage];
    [imageView sizeToFit];
    imageView.bottom  = self.height;
    imageView.centerX = self.width * .5f;
    
    CALayer *transitionLayer = imageView.layer;
    [self.layer addSublayer:transitionLayer];
    
    NSTimeInterval trueDuration = 3.f;
    // 路径曲线
    CGFloat			toOffsetX		= ARC_RANDOM(100) * self.width;
    CGFloat			toOffsetY		= self.height * ARC_RANDOM(30);
    CGPoint			controlPonit	= CGPointMake(self.width * ARC_RANDOM(50), self.height * ARC_RANDOM(50));
    UIBezierPath	*movePath		= [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    CGPoint toPoint = CGPointMake(toOffsetX,toOffsetY);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:controlPonit];
    
    // 关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    // 放大
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = @(2.5f);
    
    // 旋转1
    CABasicAnimation *rotateAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation1.beginTime		= .0f * trueDuration;
    rotateAnimation1.duration		= .3f * trueDuration;
    rotateAnimation1.autoreverses	= NO;
    rotateAnimation1.fromValue		= [NSNumber numberWithFloat:0.0];
    
    CGFloat alpha                   = ARC_RANDOM(100) * 2 - 1.f; //正负1
    CGFloat middleRotateValue       = (M_PI / 10) * alpha;
    rotateAnimation1.toValue		= [NSNumber numberWithFloat:middleRotateValue];
    
    // 旋转2
    CABasicAnimation *rotateAnimation2 = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation2.beginTime		= .3f * trueDuration;
    rotateAnimation2.duration		= .7f * trueDuration;
    rotateAnimation2.autoreverses	= NO;
    rotateAnimation2.fromValue		= [NSNumber numberWithFloat:middleRotateValue];
    rotateAnimation2.toValue		= [NSNumber numberWithFloat:M_PI / 2 * alpha];
    
    // 渐隐
    CABasicAnimation *fadeAnimation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation1.beginTime	= .0f * trueDuration;
    fadeAnimation1.duration		= .3f * trueDuration;
    fadeAnimation1.fromValue	= @(1.0);
    fadeAnimation1.toValue		= @(1.0);
    fadeAnimation1.autoreverses = NO;
    
    CABasicAnimation *fadeAnimation2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation2.beginTime	= .3f * trueDuration;
    fadeAnimation2.duration		= .7f * trueDuration;
    fadeAnimation2.fromValue	= @(1.0);
    fadeAnimation2.toValue		= @(0.0);
    fadeAnimation2.autoreverses = NO;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime				= CACurrentMediaTime();
    group.duration				= 1.0 * trueDuration;
    group.animations			= [NSArray arrayWithObjects:positionAnimation, rotateAnimation1, rotateAnimation2, scaleAnimation, fadeAnimation1, fadeAnimation2, nil];
    group.timingFunction		= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate				= self;
    group.fillMode				= kCAFillModeForwards;
    group.removedOnCompletion	= YES;
    group.autoreverses			= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];
    
    transitionLayer.opacity = 0.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(group.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [transitionLayer removeFromSuperlayer];
    });
}



- (UIImage *)randomLikeImage
{
    NSInteger value = (arc4random() % 3) + 1;
    NSString *imageName = [NSString stringWithFormat:@"icon_heart_%zd",value];
    return [UIImage imageNamed:imageName];
}
@end
