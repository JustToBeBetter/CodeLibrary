//
//  YKSlimFaceFilter.h
//  YKFaceSDK
//
//  Created by feng on 2018/8/31.
//  Copyright © 2018年 duanhai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageFilter.h"

@interface YKSlimFaceFilter : GPUImageFilter

/** 人脸信息 */
@property (nonatomic, strong) NSArray *faceInfoArray;
/** 瘦脸, 默认是NO */
@property (nonatomic, assign) BOOL slimFace;
/** 大眼, 默认是NO */
@property (nonatomic, assign) BOOL largeEyes;
/** 瘦脸, 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat slimFaceDelta;
/** 大眼, 0.0 ~ 1.0 */
@property (nonatomic, assign) CGFloat enlargeEyesDelta;

@end
