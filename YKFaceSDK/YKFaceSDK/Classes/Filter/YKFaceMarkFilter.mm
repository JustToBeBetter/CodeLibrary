//
//  YKFaceMarkFilter.m
//  YKFaceSDK
//
//  Created by feng on 2018/8/29.
//  Copyright © 2018年 feng. All rights reserved.
//
#import "YKFaceSDK.h"
#import "YKFaceMarkFilter.h"

@interface YKFaceMarkFilter() {
}

@property GPUImageFilter *pipOut;

@end

@implementation YKFaceMarkFilter

- (instancetype)init {
    self = [super init];
    if (self) {
        _showLandmarkPoint = NO;
        _pipOut = [[GPUImageFilter alloc] init];
        __weak YKFaceMarkFilter *ws = self;
        _pipOut.frameProcessingCompletionBlock = ^(GPUImageOutput *output, CMTime timeInfo) {
            [output.framebufferForOutput lock];
//            [ws trackFace:output.framebufferForOutput.pixelBuffer time:timeInfo];
            [output.framebufferForOutput unlock];
        };
    }
    return self;
}

- (void)trackFace:(CVPixelBufferRef)pixelBuffer time:(CMTime)timeInfo {
    // Do some OpenCV stuff with the image
    self.faceInfoArray = [[YKFaceSDK sharedManager] detectFaceLandmarks:pixelBuffer];
    if (self.faceCallBack) {
        self.faceCallBack(self.faceInfoArray);
    }
    [self processPixelBuffer:pixelBuffer time:timeInfo];
}

- (void)dealloc {
    _pipOut = nil;
}

#pragma GPUImageInput

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [_pipOut newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex {
    [_pipOut setInputFramebuffer:newInputFramebuffer atIndex:textureIndex];
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    [_pipOut setInputSize:newSize atIndex:textureIndex];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation
                 atIndex:(NSInteger)textureIndex {
    [_pipOut setInputRotation:newInputRotation atIndex:textureIndex];
}

- (CGSize)maximumOutputSize {
    return [_pipOut maximumOutputSize];
}

- (void)endProcessing {
}

- (BOOL)shouldIgnoreUpdatesToThisTarget {
    return NO;
}

- (BOOL)wantsMonochromeInput {
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue {
}

@end
