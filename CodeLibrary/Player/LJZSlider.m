//
//  LJZSlider.m
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZSlider.h"

@implementation LJZSlider

- (CGRect)trackRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, (bounds.size.height - 2) * 0.5, CGRectGetWidth(self.frame),2);
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect newRect = [super thumbRectForBounds:bounds trackRect:rect value:value];
    if (newRect.origin.x + newRect.size.width >= rect.size.width) {
        newRect.origin.x = newRect.origin.x - newRect.size.width / 2.0;
    }
    return newRect;
}
@end
