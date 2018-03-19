//
//  LJZFloatingView.h
//  CodeLibrary
//
//  Created by lijz on 2018/3/19.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LJZFloatingViewDelegate <NSObject>

-  (void)clickedWithXArray:(NSArray *)xArray yArray:(NSArray *)yArray;
-  (void)dragWithPoint:(CGPoint)center dragState:(UIGestureRecognizerState)state;

@end

@interface LJZFloatingView : UIView

@property(nonatomic,weak)id <LJZFloatingViewDelegate>delegate;


@end
