//
//  YKGPUImagePicInput.h
//  YKFaceSDK
//
//  Created by feng on 2018/9/5.
//  Copyright © 2018年 duanhai. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface YKGPUImagePicInput : GPUImageOutput

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime;

- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime completion:(void (^)(void))completion;

@end
