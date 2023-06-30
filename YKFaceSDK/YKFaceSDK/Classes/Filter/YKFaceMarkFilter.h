//
//  YKFaceMarkFilter.h
//  YKFaceSDK
//
//  Created by feng on 2018/8/29.
//  Copyright © 2018年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GPUImage/GPUImage.h>
#import "YKGPUImagePicInput.h"

/**
 * 暂不可用
 */
@interface YKFaceMarkFilter : YKGPUImagePicInput <GPUImageInput>
/** 人脸信息 */
@property (nonatomic, strong) NSArray *faceInfoArray;
/** 是否标注人脸关键点, 默认为NO */
@property (nonatomic, assign) BOOL showLandmarkPoint;
/** 关键点回调 */
@property(nonatomic, copy) void(^faceCallBack)(const NSArray *faceInfoArray);

@end

