//
//  UIImage+AddMethods.m
//  Easybao
//
//  Created by wenjie hua on 2016/10/19.
//  Copyright © 2016年 gold. All rights reserved.
//

#import "UIImage+AddMethods.h"

@implementation UIImage (AddMethods)

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius
                             andSize:(CGSize)size
                         borderWidth:(CGFloat)borderWidth
                     backgroundColor:(UIColor *)backgroundColor
                         borderColor:(UIColor *)borderColor{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    [path setLineWidth:borderWidth];
    [backgroundColor setFill];
    [borderColor setStroke];
    CGContextAddPath(ctx,path.CGPath);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(ctx, (CGRect){{0, 0}, size});
    UIImage *imgNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgNew;
}

- (UIImage *)renderColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    CGContextClipToMask(ctx, (CGRect){{0, 0}, self.size}, self.CGImage);
    [color setFill];
    CGContextFillRect(ctx, (CGRect){{0, 0}, self.size});
    UIImage *imgNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgNew;
}

- (UIImage *)renderAlpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -self.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, (CGRect){{0, 0}, self.size}, self.CGImage);
    UIImage *imgNew = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imgNew;
}

#pragma Base64图片 -> UIImage
+(UIImage *)imageWithBase64:(NSString *) imgSrc
{
    NSURL *url = [NSURL URLWithString: imgSrc];
    NSData *data = [NSData dataWithContentsOfURL: url];
    UIImage *image = [UIImage imageWithData: data];
    
    return image;
}

@end
