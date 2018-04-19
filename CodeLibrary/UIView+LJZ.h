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

@end
