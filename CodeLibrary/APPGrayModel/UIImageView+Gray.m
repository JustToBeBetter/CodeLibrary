//
//  UIImageView+Gray.m
//  CodeLibrary
//
//  Created by lijinzhu on 2022/12/1.
//  Copyright © 2022 李金柱. All rights reserved.
//

#import "UIImageView+Gray.h"
#import <objc/runtime.h>

@implementation UIImageView (Gray)
+ (void)load {
    Method customMethod = class_getInstanceMethod([self class], @selector(setImage:));
    Method originMethod = class_getInstanceMethod([self class], @selector(gr_setImage:));
    method_exchangeImplementations(customMethod, originMethod);
}

- (void)gr_setImage:(UIImage *)image {
      //是否黑白化,1表示开启
    BOOL isOpenWhiteBlackModel = [[NSUserDefaults standardUserDefaults] boolForKey:@"kIsShowBlackWhiteModel"];
    isOpenWhiteBlackModel = 1;
    if (isOpenWhiteBlackModel == 1) {
        [self gr_setImage:[self gr_grayImage:image]];
    } else {
        [self gr_setImage:image];
    }
}

- (UIImage *)gr_grayImage:(UIImage *)image {
        //UIKBSplitImageView是为了键盘
    if (image == nil || [self.superview isKindOfClass:NSClassFromString(@"UIKBSplitImageView")]) {
        return image;
    }
    
    //滤镜处理
    //CIPhotoEffectNoir黑白
    //CIPhotoEffectMono单色
    NSString *filterName = @"CIPhotoEffectMono";
    CIFilter *filter = [CIFilter filterWithName:filterName];
    CIImage *inputImage = [[CIImage alloc] initWithImage:image];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CGImageRef cgImage = [self.filterContext createCGImage:filter.outputImage fromRect:[inputImage extent]];
    UIImage *resultImg = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    return resultImg;
}

- (CIContext *)filterContext {
    CIContext *context = objc_getAssociatedObject(self, @selector(filterContext));
    if (!context) {
        context = [[CIContext alloc] initWithOptions:nil];
        self.filterContext = context;
    }
    return context;
}

- (void)setFilterContext:(CIContext *)filterContext {
    objc_setAssociatedObject(self, @selector(filterContext), filterContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
