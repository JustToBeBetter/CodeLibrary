//
//  UIImageView+Loading.m
//  Live
//  UIImageView通用加载分类
//  Created by 戴奕 on 2017/3/31.
//  Copyright © 2017年 daxiang. All rights reserved.
//

#import "UIImageView+Loading.h"
#import <objc/runtime.h>
#import "NSString+AddMethods.h"
#import "UIImageView+WebCache.h"

static const void * const kHadBackgroundKey = &kHadBackgroundKey;
static NSString * strImageBase;
static NSString * strLoadImageUrl;
static NSString * strFailImageUrl;
static UIColor * backgroundColor;

@interface UIImageView ()

@property (nonatomic, assign, getter=isHadBackground) BOOL hadBackground;

@end

@implementation UIImageView (Loading)

+ (void)setLoadingImageBaseUrl:(NSString *)kBaseUrl loadImageStrUrl:(NSString *)loadImageStrUrl failImageStrUrl:(NSString *)failImageStrUrl backgroundColor:(UIColor *)bgColor{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        strImageBase = kBaseUrl;
        strLoadImageUrl = loadImageStrUrl;
        strFailImageUrl = failImageStrUrl;
        backgroundColor = bgColor;
    });
}

- (void)loadWithImageUrl:(NSString *)imageUrl {
    // 背景色设置
    if (!self.isHadBackground) {
        if (backgroundColor == nil) {
            backgroundColor = [UIColor colorWithRed:242/255.0 green:243/255.0 blue:246/255.0 alpha:1.0];
        }
        [self setBackgroundColor:backgroundColor];
        self.hadBackground = YES;
    }
    
    // 前缀处理
    NSString *pathUrl = imageUrl;
    if (![imageUrl hasPrefix:@"http://"] && ![imageUrl hasPrefix:@"https://"]) {
        pathUrl = [NSString stringWithFormat:@"%@%@",strImageBase, imageUrl];
    }
    
    [self loadWithImageUrl:pathUrl loadingImage:[UIImage imageNamed:strLoadImageUrl] failImage:[UIImage imageNamed:strFailImageUrl]];
}

- (void)loadWithImageUrl:(NSString *)imageUrl loadingImage:(UIImage *)loadingImage failImage:(UIImage *)failImage {
    NSString *encodedUrl = [NSString urlEncodedByUrl:imageUrl];
    NSURL *urlImage = [NSURL URLWithString:encodedUrl];
    
    self.contentMode = UIViewContentModeCenter;
    
    __weak typeof(self) selfWeak = self;
    [self sd_setImageWithURL:urlImage placeholderImage:loadingImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            NSLog(@"加载图片失败 ： %@", error);
            selfWeak.image = failImage;
        }else {
            selfWeak.contentMode = UIViewContentModeScaleAspectFill;
        }
    }];
}

#pragma mark - setter and getter Methods
- (void)setHadBackground:(BOOL)hadBackground {
    objc_setAssociatedObject(self, kHadBackgroundKey, @(hadBackground), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isHadBackground {
    return [objc_getAssociatedObject(self, kHadBackgroundKey) boolValue];
}

@end
