//
//  UIImage+AddMethods.h
//  Easybao
//
//  Created by wenjie hua on 2016/10/19.
//  Copyright © 2016年 gold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (AddMethods)

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius
                             andSize:(CGSize)size
                         borderWidth:(CGFloat)borderWidth
                     backgroundColor:(UIColor *)backgroundColor
                         borderColor:(UIColor *)borderColor;

+(UIImage *)imageWithBase64:(NSString *) imgSrc;

- (UIImage *)renderColor:(UIColor *)color;
- (UIImage *)renderAlpha:(CGFloat)alpha;

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size;

@end
