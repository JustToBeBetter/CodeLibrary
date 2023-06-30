//
//  YKFaceSDK.h
//  YKFaceSDK
//
//  Created by feng on 2018/8/29.
//  Copyright © 2018年 feng. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

// 行为检测
typedef NS_ENUM(NSInteger, YKFaceLivingnessAction) {
    YKFaceLivingnessActionNodHead,      // 点头
    YKFaceLivingnessActionShakeHead,    // 摇头
    YKFaceLivingnessActionShakeEyes,    // 眨眼
};

// 人脸关键点，角度信息
@interface YKFaceInfo : NSObject

@property (nonatomic, assign) NSInteger faceId;
// 人脸框位置
@property (nonatomic, assign) CGRect faceBox;
// 归一化的关键点信息
@property (nonatomic, strong) NSArray<NSValue *>* normalizationLandmarks;
// 人脸关键点位置 275 points (NSValue <-> CGPoint)
@property (nonatomic, strong) NSArray<NSValue *>* landmark;
// 左右转动幅度 yaw
@property (nonatomic, assign) CGFloat yaw;
// 上下点头幅度 pitch
@property (nonatomic, assign) CGFloat pitch;
// 左右摇头幅度 roll
@property (nonatomic, assign) CGFloat roll;
// 暂不支持
@property (nonatomic, assign) YKFaceLivingnessAction action;

@end

// SDK初始化信息
@interface YKFaceSDKConfig : NSObject

// 检测人脸数量, 默认:3
@property (nonatomic, assign) NSInteger maxinumFace;
// 预览窗口大小, 默认:720*1280
@property (nonatomic, assign) CGSize previewSize;
// 是否需要进行镜像视频, 默认:NO
@property (nonatomic, assign) BOOL mirror;
// 计算方式 CPU/GPU, 默认:NO
@property (nonatomic, assign) BOOL useGPU;
// 画面拉伸方式, 默认: AVLayerVideoGravityResizeAspectFill
@property (nonatomic, copy) AVLayerVideoGravity gravity;

@end


typedef void(^YKFaceSDKDetectHandler)(NSArray<YKFaceInfo *> *faces);

// SDK信息
@interface YKFaceSDK : NSObject

// 是否开启标点
@property (nonatomic, assign) BOOL showLandmark;

// 是否显示点序
@property (nonatomic, assign) BOOL showPointOrder;

+ (YKFaceSDK *)sharedManager;

/**
 * 初始化配置SDK
 */
- (void)initWithConfig:(YKFaceSDKConfig *)config;

/**
 * 异步检测人脸关键点
 */
- (void)detectFaceLandmarks:(CVPixelBufferRef)pixelBuffer handler:(YKFaceSDKDetectHandler)handler;

/**
 * 同步检测人脸关键点
 */
- (NSArray<YKFaceInfo *> *)detectFaceLandmarks:(CVPixelBufferRef)pixelBuffer;

/**
 * 绘制关键点
 */
- (void)drawLandmark:(CVPixelBufferRef)pixelBuffer faceInfo:(NSArray<YKFaceInfo *> *)faceInfoArray;


@end
