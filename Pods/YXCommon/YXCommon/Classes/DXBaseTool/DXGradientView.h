//
//  DXGradientView.h
//  Live
//
//  Created by wenjie hua on 2017/4/24.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
IB_DESIGNABLE
@interface DXGradientView : UIView

@property (nonatomic, strong) IBInspectable UIColor *bottomColor;
@property (nonatomic, strong) IBInspectable UIColor *topColor;

- (instancetype)initWithBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor;

@end
