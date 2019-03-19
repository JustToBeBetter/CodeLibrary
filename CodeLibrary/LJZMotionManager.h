//
//  LJZMotionManager.h
//  CodeLibrary
//
//  Created by maopao on 2019/3/19.
//  Copyright © 2019 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol LJZMotionManagerDeviceOrientationDelegate<NSObject>

@optional
- (void)motionManagerDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
@end


@interface LJZMotionManager : NSObject


@property (nonatomic ,assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic ,assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic ,weak) id<LJZMotionManagerDeviceOrientationDelegate>delegate;

+ (instancetype)sharedManager;

/**
 开始方向监测
 */
- (void)startDeviceMotionUpdates;

/**
 结束方向监测
 */
- (void)stopDeviceMotionUpdates;

/**
 设置设备取向
 
 @return 返回视频捕捉方向
 */
- (AVCaptureVideoOrientation)currentVideoOrientation;

@end
