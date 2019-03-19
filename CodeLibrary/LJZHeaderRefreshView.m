//
//  LJZHeaderRefreshView.m
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import "LJZHeaderRefreshView.h"


@interface LJZHeaderRefreshView ()

@property (nonatomic,strong) UIColor *dotColor;//圆点颜色
@property (strong, nonatomic) UIImageView *dotViewLeft;//左圆点
@property (strong, nonatomic) UIImageView *dotViewCenter;//中心圆点
@property (strong, nonatomic) UIImageView *dotViewRight;//右圆点


@end

@implementation LJZHeaderRefreshView

- (instancetype)initWithFrame:(CGRect)frame  {
    
    self = [super initWithFrame:frame ];
    if (self) {
        self.dotColor = [UIColor redColor];
        [self setupViews];
    }
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor clearColor];
    self.dotViewLeft.backgroundColor = self.dotColor;
    self.dotViewCenter.backgroundColor = self.dotColor;
    self.dotViewRight.backgroundColor = self.dotColor;
    [self addSubview:self.dotViewLeft];
    [self addSubview:self.dotViewCenter];
    [self addSubview:self.dotViewRight];
    
}

- (void)updateAnimationWithOffsetY:(CGFloat)offsetY{
    
    
    CGFloat  startCentterHeight = 10.0;//拖动到多高后,中心点将保持Y方向居中
    CGFloat  maxCenterHeight = 54;//拖动到多高以后,中心点将不再保持Y方向居中, 而是跟随view下移
    CGFloat dotCenterY = 0;//点的Y中心
    CGFloat centerDotWidth= 0;//中心点的宽度
    CGFloat maxCenterDotWidth = 10.0;//中心点最大宽度
    CGFloat centerDotAlpha= 0.0;//中心点的不透明度
    CGFloat centerDotStartAlpha= 0.0;//中心点初始不透明度
    CGFloat sideDotWidth= 6.0;//旁边点的宽度
    CGFloat sideDotOffsetX= 0;//旁边点相对中心点的距离
    CGFloat sideDotAlpha= 1.0;//旁边点的不透明度
    CGFloat maxSideDotOffsetX= 25.0;//旁边点X方向最大偏移长度
    CGFloat maxSideDotOffsetHeight= 60.0;//拖动到多高后, 旁边点X方向上偏移达到最大
    
    if (offsetY < maxCenterHeight) {
        if (offsetY < startCentterHeight) {
            centerDotWidth = offsetY/startCentterHeight*maxCenterDotWidth;
            centerDotAlpha = centerDotStartAlpha+offsetY/startCentterHeight*(1.0-centerDotStartAlpha);
            sideDotAlpha = 0.0;
        } else {
            centerDotAlpha = 1.0;
            sideDotAlpha = 1.0;
            if ( offsetY < maxSideDotOffsetHeight){
                sideDotOffsetX = (maxSideDotOffsetX-2.0)*(offsetY-startCentterHeight)/(maxSideDotOffsetHeight-startCentterHeight)+2.0;
                centerDotWidth = maxCenterDotWidth-(maxCenterDotWidth-sideDotWidth)*(offsetY-startCentterHeight)/(maxSideDotOffsetHeight-startCentterHeight);
            } else {
                sideDotOffsetX = maxSideDotOffsetX;
                centerDotWidth = sideDotWidth;
                
            }
        }
    } else {
        
        centerDotWidth = sideDotWidth;
        sideDotOffsetX = maxSideDotOffsetX;
        centerDotAlpha = 1.0;
    }
    
    dotCenterY = self.bounds.size.height-centerDotWidth-startCentterHeight;
    
    self.dotViewCenter.frame = CGRectMake(self.bounds.size.width/2.0-centerDotWidth/2.0, dotCenterY, centerDotWidth, centerDotWidth);
    self.dotViewCenter.layer.cornerRadius = centerDotWidth/2.0;
    self.dotViewCenter.alpha = centerDotAlpha;
    self.dotViewLeft.frame = CGRectMake(self.bounds.size.width/2.0-sideDotOffsetX, dotCenterY+(centerDotWidth-sideDotWidth)/2.0, sideDotWidth, sideDotWidth);
    self.dotViewLeft.alpha = sideDotAlpha;
    self.dotViewLeft.layer.cornerRadius = sideDotWidth/2.0;
    self.dotViewRight.frame = CGRectMake(self.bounds.size.width/2.0+sideDotOffsetX-sideDotWidth, dotCenterY+(centerDotWidth-sideDotWidth)/2.0, sideDotWidth, sideDotWidth);
    self.dotViewRight.alpha = sideDotAlpha;
    self.dotViewRight.layer.cornerRadius = sideDotWidth/2.0;
    
}

#pragma mark
#pragma mark =====================lazy=====================

- (UIImageView *)dotViewLeft{
    if (_dotViewLeft == nil) {
        _dotViewLeft = [[UIImageView alloc]init];
        _dotViewLeft.layer.masksToBounds = YES;
    }
    return _dotViewLeft;
}

- (UIImageView *)dotViewCenter{
    if (_dotViewCenter == nil) {
        _dotViewCenter = [[UIImageView alloc]init];
        _dotViewCenter.layer.masksToBounds = YES;
    }
    return _dotViewCenter;
}
- (UIImageView *)dotViewRight{
    if (_dotViewRight == nil) {
        _dotViewRight = [[UIImageView alloc]init];
        _dotViewRight.layer.masksToBounds = YES;
    }
    return _dotViewRight;
}

@end
