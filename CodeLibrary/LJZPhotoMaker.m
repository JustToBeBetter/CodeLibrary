//
//  LJZPhotoMaker.m
//  CodeLibrary
//
//  Created by 李金柱 on 2019/2/16.
//  Copyright © 2019年 李金柱. All rights reserved.
//

#import "LJZPhotoMaker.h"

@implementation LJZPhotoMaker

+ (UIImage *)makePhtoWithImages:(NSArray *)images{
    UIView *contentView = [self makeImageViewWithImages:images];
    
    if(UIGraphicsBeginImageContextWithOptions != NULL)
    {
       UIGraphicsBeginImageContextWithOptions(contentView.frame.size, NO, 2.0);
    } else {
           UIGraphicsBeginImageContext(contentView.frame.size);
    }
    
    [contentView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (UIView *)makeImageViewWithImages:(NSArray *)images{
    
    CGFloat containerViewW = 215;
    CGFloat containerViewH = containerViewW;
    CGFloat space = 5;
    UIView *containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, containerViewW, containerViewH)];
    
    CGFloat imgW = 100 ;
    CGFloat imgH = imgW;
    
    if (images.count>=4) {
        for (int i = 0 ; i < 4; i ++) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(space+(imgW + space)*(i%2), space+(imgH+space)*(i/2), imgW, imgH)];
            imageView.image = images[i];
            [containerView addSubview:imageView];
        }
        
    }else if(images.count == 3){
       for (int i = 0 ; i < 3; i ++) {
           UIImageView *imageView = [[UIImageView alloc]init];
            if (i == 0) {
                imageView.frame = CGRectMake(space+(containerViewW-imgW)/2, space+0, imgW, imgH);
            }else{
                imageView.frame = CGRectMake(space+(imgW+ space)*((i+1)%2), space+(imgH+ space)*((i+1)/2), imgW, imgH);
            }
           imageView.image = images[i];
           [containerView addSubview:imageView];
       }
    }
    return containerView;
}

@end
