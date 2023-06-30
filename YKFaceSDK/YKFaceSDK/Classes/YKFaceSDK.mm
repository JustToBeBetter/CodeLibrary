//
//  YKFaceSDK.m
//  YKFaceSDK
//
//  Created by feng on 2018/8/29.
//  Copyright © 2018年 feng. All rights reserved.
//
#ifdef __cplusplus
#undef NO
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#define NO __objc_no
#endif

#import "YKFaceSDK.h"
#import <tnn/tnn.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import "tnn_sdk_sample.h"
#import "pose_utils.h"
#import "YKTNNFaceAlignViewModel.h"

using namespace std;
using namespace TNN_NS;

@implementation YKFaceSDKConfig

- (instancetype)init {
    if (self = [super init]) {
        self.maxinumFace = 3;
        self.previewSize = CGSizeMake(720, 1280);
        self.useGPU = NO;
        self.mirror = NO;
        self.gravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

@end

@implementation YKFaceInfo

@end

@interface YKFaceSDK () {
    vector<shared_ptr<ObjectInfo>>  _object_list;
}

@property (nonatomic, strong) YKFaceSDKConfig *config;
@property (nonatomic, strong) YKTNNFaceAlignViewModel *viewModel;
@property (nonatomic, assign) BOOL initSuccess;

@property (nonatomic, assign) CGSize previewSize;
@property (nonatomic, assign) NSInteger maxinumFace;
@property (nonatomic, assign) BOOL mirror;
@property (nonatomic, assign) TNNComputeUnits computeUnit;
@property (nonatomic, assign) NSInteger videoGravity;

@property (nonatomic, strong) dispatch_semaphore_t inflightSemaphore;

@end

@implementation YKFaceSDK

+ (YKFaceSDK *)sharedManager {
    static YKFaceSDK * _instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YKFaceSDK alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _initSuccess = NO;
        _object_list = {};
        _inflightSemaphore = dispatch_semaphore_create(1);
        // 初始化网络
        _maxinumFace = 5;
        _previewSize = CGSizeMake(720, 1280);
        _mirror = NO;
        _showLandmark = NO;
        _showPointOrder = NO;
        // 模型
        self.viewModel = [[YKTNNFaceAlignViewModel alloc] init];
    }
    return self;
}

- (void)initWithConfig:(YKFaceSDKConfig *)config {
    // 初始化网络
    _maxinumFace = config.maxinumFace;
    _previewSize = config.previewSize;
    _mirror = config.mirror;
    _computeUnit = _config.useGPU ? TNNComputeUnitsGPU :TNNComputeUnitsCPU;
    _videoGravity = 0;
    if (config.gravity == AVLayerVideoGravityResizeAspectFill) {
        _videoGravity = 2;
    } else if(config.gravity == AVLayerVideoGravityResizeAspect) {
        _videoGravity = 1;
    }
    __weak typeof(self) ws = self;
    [self loadNeuralNetwork:_computeUnit callback:^(Status status) {
        if (status != TNN_OK) {
            NSLog(@"[YKFaceSDK] 加载模型失败, 错误详情: %s", status.description().c_str());
        } else {
            NSLog(@"[YKFaceSDK] 加载模型完成");
            ws.initSuccess = YES;
        }
    }];
}

- (void)loadNeuralNetwork:(TNNComputeUnits)units callback:(void (^) (Status status))callback {
    //异步加载模型
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Status status = [self.viewModel loadNeuralNetworkModel:units];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(status);
            }
        });
    });
}

- (void)detectFaceLandmarks:(CVPixelBufferRef)pixelBuffer
                    handler:(YKFaceSDKDetectHandler)handler {
    NSArray<YKFaceInfo *> *faceInfoArray = [self detectFaceLandmarks:pixelBuffer];
    if (handler) {
        handler(faceInfoArray);
    }
}

- (NSArray<YKFaceInfo *> *)detectFaceLandmarks:(CVPixelBufferRef)pixelBuffer {
    if (dispatch_semaphore_wait(self.inflightSemaphore, DISPATCH_TIME_NOW) != 0) {
        return nil;
    }
    if (!self.viewModel || !self.viewModel.predictor || !pixelBuffer) {
        return nil;
    }
    //lock
    CVBufferRetain(pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
    
    CGSize imageSize = CGSizeMake(width, height);
    void *bufferAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    const auto target_dims = self.viewModel.predictor->GetInputShape();
    auto predictor_async_thread = self.viewModel.predictor;
    
    Status status = TNN_OK;
    shared_ptr<char> image_data = nullptr;
    shared_ptr<Mat> image_mat = nullptr;
    auto origin_dims = {1, 3, height, width};
    
    image_mat = make_shared<Mat>(DEVICE_ARM, N8UC4, origin_dims, bufferAddress);
    
    // 开始预测人脸
    shared_ptr<TNNSDKOutput> output = nullptr;
    if (image_mat->GetData() != nullptr && image_mat->GetWidth() > 0) {
        status = predictor_async_thread->Predict(make_shared<TNNSDKInput>(image_mat), output);
    }

    NSArray<YKFaceInfo *> *faceInfoArray = [self outputFaceInfo:output imageSize:imageSize status:status];
    if (self.showLandmark) {
        // delegate image processing to the delegate
        cv::Mat cvImage((int)height, (int)width, CV_8UC4, bufferAddress, bytesPerRow);
        for (int i = 0; i < faceInfoArray.count; i++) {
            YKFaceInfo *faceInfo = [faceInfoArray objectAtIndex:i];
            if (faceInfo.normalizationLandmarks.count > 0) {
                [faceInfo.normalizationLandmarks enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CGPoint pt = [obj CGPointValue];
                    cv::circle(cvImage, cv::Point(int(pt.x * width), int(pt.y * height)), 3, cv::Scalar(0, 255, 0), -1);

                    if (self.showPointOrder) {
                        cv::putText(cvImage,  [[@(idx) stringValue] UTF8String], cv::Point(pt.x * width, pt.y * height + 20), cv::FONT_ITALIC, 0.3, cv::Scalar(255, 255, 0));
                    }
                }];
            }
        }
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVBufferRelease(pixelBuffer);
    
    dispatch_semaphore_signal(self.inflightSemaphore);
    return faceInfoArray;
}

- (void)drawLandmark:(CVPixelBufferRef)pixelBuffer faceInfo:(NSArray<YKFaceInfo *> *)faceInfoArray {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    int width = (int)CVPixelBufferGetWidth(pixelBuffer);
    int height = (int)CVPixelBufferGetHeight(pixelBuffer);
    OSType format = CVPixelBufferGetPixelFormatType(pixelBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);

    CGSize imageSize = CGSizeMake(width, height);
    void *bufferAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
        
    if (self.showLandmark) {
        // delegate image processing to the delegate
        cv::Mat cvImage((int)height, (int)width, CV_8UC4, bufferAddress, bytesPerRow);
        for (int i = 0; i < faceInfoArray.count; i++) {
            YKFaceInfo *faceInfo = [faceInfoArray objectAtIndex:i];
            if (faceInfo.normalizationLandmarks.count > 0) {
                [faceInfo.normalizationLandmarks enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (idx < 145) {
                        CGPoint pt = [obj CGPointValue];
                        cv::circle(cvImage, cv::Point(int(pt.x * width), int(pt.y * height)), 3, cv::Scalar(0, 255, 0), -1);

                        if (self.showPointOrder) {
                            cv::putText(cvImage,  [[@(idx) stringValue] UTF8String], cv::Point(pt.x * width, pt.y * height + 20), cv::FONT_ITALIC, 0.3, cv::Scalar(255, 255, 0));
                        }
                    }
                }];
            }
        }
        memcpy(bufferAddress, cvImage.data, cvImage.total() * 4);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

- (NSArray<YKFaceInfo *> *)outputFaceInfo:(shared_ptr<TNNSDKOutput>)output
             imageSize:(CGSize)size
                status:(Status)status {
    NSMutableArray<YKFaceInfo *> *faceInfoArray = [NSMutableArray array];
    auto face_info = [self.viewModel getObjectList:output];
    if (status != TNN_OK) {
        NSLog(@"[YKFaceSDK] 未识别到人脸位置, 详情: %s", status.description().c_str());
        return nil;
    }
    
    face_info = [self reOrder:face_info];
    if (face_info.size() > 0) {
        for (int i = 0; i < MIN(face_info.size(), self.maxinumFace); i ++) {
            YKFaceInfo *faceInfo = [[YKFaceInfo alloc] init];
            auto object = face_info[i];
            float view_width = self.previewSize.width;
            float view_height = self.previewSize.height;
            auto view_face = object->AdjustToImageSize(size.height, size.width);
            
            Quaterniond q = estimateHeadPose(view_face.key_points, size.width, size.height);
            faceInfo.yaw = q.yaw;
            faceInfo.roll = q.roll;
            faceInfo.pitch = q.pitch;
            faceInfo.faceBox = CGRectMake(view_face.x1, view_face.y1, view_face.x2 - view_face.x1, view_face.y2 - view_face.y1);
            
            // 归一化的点
            NSMutableArray *normalizationLandmarks = [NSMutableArray array];
            size_t numLandmarks = view_face.key_points.size();
            if (numLandmarks > 0) {
                for (int j = 0; j < numLandmarks; j++) {
                  double x = view_face.key_points[j].first / size.width;
                  double y = view_face.key_points[j].second / size.height;
                  [normalizationLandmarks addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }
                faceInfo.normalizationLandmarks = normalizationLandmarks;
                
                // scale point
                view_face = view_face.AdjustToViewSize(view_height, view_width, _videoGravity);
                if (self.mirror) {
                    view_face = view_face.FlipX();
                }
               
                NSMutableArray *landmark = [NSMutableArray array];
                for (int j = 0; j < numLandmarks; j++) {
                  double x = view_face.key_points[j].first;
                  double y = view_face.key_points[j].second;
                  [landmark addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }

                faceInfo.landmark = landmark;
                
                [faceInfoArray addObject:faceInfo];
            }
        }
        return faceInfoArray;
    }
    return faceInfoArray;
}

- (std::vector<std::shared_ptr<ObjectInfo> >)reOrder:(std::vector<std::shared_ptr<ObjectInfo> >) object_list {
    if (_object_list.size() > 0 && object_list.size() > 0) {
        std::vector<std::shared_ptr<ObjectInfo> > object_list_reorder;
        //按照原有排序插入object_list中原先有的元素
        for (int index_last = 0; index_last < _object_list.size(); index_last++) {
            auto object_last = _object_list[index_last];
            //寻找最匹配元素
            int index_target = 0;
            float area_target = -1;
            for (int index=0; index<object_list.size(); index++) {
                auto object = object_list[index];
                auto area = object_last->IntersectionRatio(object.get());
                if (area > area_target) {
                    area_target = area;
                    index_target = index;
                }
            }

            if (area_target > 0) {
                object_list_reorder.push_back(object_list[index_target]);
                //删除指定下标元素
                object_list.erase(object_list.begin() + index_target);
            }
        }

        //插入原先没有的元素
        if (object_list.size() > 0) {
            object_list_reorder.insert(object_list_reorder.end(), object_list.begin(), object_list.end());
        }

        _object_list = object_list_reorder;
        return object_list_reorder;
    } else {
        _object_list = object_list;
        return object_list;
    }
}

@end
