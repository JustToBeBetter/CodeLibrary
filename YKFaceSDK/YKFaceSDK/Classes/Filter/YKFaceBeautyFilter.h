//
//  YKFaceBeautyFitler.h
//  YKFaceSDK
//
//  Created by feng on 2018/8/31.
//  Copyright © 2018年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
#import "YKFaceSticker.h"

@interface YKFaceBeautyFilter : GPUImageFilterGroup

/** 人脸标点, 默认是NO */
@property (nonatomic, assign) BOOL showLandmark;
/** 美颜, 默认是NO */
@property (nonatomic, assign) BOOL beauty;
/** 瘦脸, 默认是NO */
@property (nonatomic, assign) BOOL slimFace;
/** 大眼, 默认是NO */
@property (nonatomic, assign) BOOL largeEyes;
/** 瘦脸, 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat slimFaceDelta;
/** 大眼, 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat enlargeEyesDelta;
/** 动态贴纸 */
@property (nonatomic, strong) YKFaceSticker *sticker;

@end
