//
//  UIView+LJZ.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/20.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LJZ)

@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGFloat top;
@property CGFloat left;
@property CGFloat right;
@property CGFloat bottom;
@property CGFloat width;
@property CGFloat height;
@property CGFloat centerX;
@property CGFloat centerY;
@property CGPoint origin;

@property (nonatomic) CGSize size;

//找到自己的vc
- (UIViewController *)viewController;


- (void)removeAllSubViews;
- (void)setBackgroundImage:(UIImage*)image;

- (void)setRoundedCorners:(UIRectCorner)corners radius:(CGSize)size;
- (void)setCornerRadius:(CGFloat)radius;

/**
 给view添加透明度渐变颜色
 透明度自0到1
 @param color 颜色
 @param topToDown 是否是自上而下渐变
 */
- (CAGradientLayer *)gradientLayerWithColor:(UIColor *)color maxAlpha:(CGFloat)alpha topToDown:(BOOL)topToDown;
- (void)makeCornerRadiusWithBezierPath:(CGFloat)cornerRadius;
//Top的圆角
- (void)topCornerRadius:(CGFloat)radius;
//Bottom的圆角
- (void)bottomCornerRadius:(CGFloat)radius;
//left的圆角
- (void)leftCornerRadius:(CGFloat)radius;
//right的圆角
- (void)rightCornerRadius:(CGFloat)radius;
//rightbottom的圆角
- (void)rightBottomCornerRadius:(CGFloat)radius;

-(void)cornerTopLeft:(CGFloat)topLeft topRight:(CGFloat)topRight bottomLeft:(CGFloat)bottomLeft bottomRight:(CGFloat)bottomRight;

@end
