//
//  UIImageView+Loading.h
//  Live
//  UIImageView通用加载分类
//  Created by 戴奕 on 2017/3/31.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Loading)

/**
 通用加载图片
 
 @param imageUrl 图片url
 */
- (void)loadWithImageUrl:(NSString *)imageUrl;

+ (void)setLoadingImageBaseUrl:(NSString *)kBaseUrl loadImageStrUrl:(NSString *)loadImageStrUrl failImageStrUrl:(NSString *)failImageStrUrl backgroundColor:(UIColor *)bgColor;

@end
