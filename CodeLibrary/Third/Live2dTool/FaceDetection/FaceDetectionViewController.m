//
//  FaceDetectionViewController.m
//  MNNKitDemo
//
//  Created by tsia on 2019/12/24.
//  Copyright © 2019 tsia. All rights reserved.
//

#import "FaceDetectionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import <YKFaceSDK/YKFaceSDK.h>
#import "FaceDetectView.h"
#include "L2DCubism.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface FaceDetectionViewController ()

@property (strong, nonatomic) UILabel *lbPointOrder;
@property (strong, nonatomic) UISwitch *pointOrder;
@property (strong, nonatomic) UILabel *lbCostTime;

@end

@implementation FaceDetectionViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    // 点序
//    _lbPointOrder = [[UILabel alloc] initWithFrame:CGRectMake(10, self.navigationbarHeight+4, 40, 40)];
//    _lbPointOrder.textColor = [UIColor greenColor];
//    _lbPointOrder.text = @"点序";
//    [self.view addSubview:_lbPointOrder];
//    _pointOrder = [[UISwitch alloc] initWithFrame:CGRectMake(10+40, self.navigationbarHeight+8, 100, 40)];
//    [self.view addSubview:_pointOrder];
//
//    // 耗时ms
//    _lbCostTime = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_lbPointOrder.frame)+8, 100, 40)];
//    _lbCostTime.textColor = [UIColor greenColor];
//    [self.view addSubview:_lbCostTime];

}

#pragma mark - mnn face
- (void)createKitInstance {
    //tnn
    YKFaceSDKConfig *config = [[YKFaceSDKConfig alloc] init];
    config.previewSize = self.view.frame.size;
    config.gravity = AVLayerVideoGravityResizeAspectFill;
    config.maxinumFace = 1;
    config.useGPU = YES;
    [[YKFaceSDK sharedManager] initWithConfig:config];
    
}


#pragma mark - ui
- (VideoBaseDetectView *)createDetectView {
    FaceDetectView *detectView = [[FaceDetectView alloc]init];
    return detectView;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 1);
    
    __weak typeof(self) ws = self;
    [[YKFaceSDK sharedManager] detectFaceLandmarks:pixelBuffer handler:^(NSArray<YKFaceInfo *> *faces) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (faces.count > 0) {
                    [ws.live2dView setFaceDetectionData:[faces firstObject]];
                    ws.live2dView.detectResult = faces;
                }else{
                    ws.live2dView.detectResult = @[];
                }

            });
    }];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 1);
}


- (Live2DView *)live2dView{
    if (!_live2dView) {
        _live2dView =  [[Live2DView alloc] init];
        WeakObj(self)
        _live2dView.sendDataWithDataArrayCallBack = ^(NSArray * _Nonnull dataArray) {
            !selfWeak.sendL2dDataCallBack ? : selfWeak.sendL2dDataCallBack(dataArray);
        };
    }
    return _live2dView;
}

@end
