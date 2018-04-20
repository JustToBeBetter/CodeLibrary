//
//  DXGradientView.m
//  Live
//
//  Created by wenjie hua on 2017/4/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "DXGradientView.h"

@implementation DXGradientView

+ (Class)layerClass {
    return [CAGradientLayer class];
}

#pragma mark Init Methods
- (instancetype)initWithBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor{
    self = [super init];
    if (self) {
        CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
        self.bottomColor = bottomColor;
        self.topColor = topColor;
        gradientLayer.colors = @[(__bridge id)bottomColor.CGColor,(__bridge id)topColor.CGColor];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0);
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    gradientLayer.colors = @[(__bridge id)self.bottomColor.CGColor,(__bridge id)self.topColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0);
}


@end
