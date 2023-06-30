//
//  YKFaceBeautyFitler.m
//  YKFaceSDK
//
//  Created by feng on 2018/8/31.
//  Copyright © 2018年 feng. All rights reserved.
//
#import "YKFaceSDK.h"
#import "YKFaceBeautyFilter.h"
#import "YKFaceMarkFilter.h"
#import "YKBeautyPlusFilter.h"
#import "YKSlimFaceFilter.h"
#import "YKFaceStickerFilter.h"

@interface YKFaceBeautyFilter ()

@property (nonatomic, strong) YKFaceMarkFilter *faceMarkFilter;

@property (nonatomic, strong) YKBeautyPlusFilter *beautyFilter;

@property (nonatomic, strong) YKSlimFaceFilter *slimFaceFilter;

@property (nonatomic, strong) YKFaceStickerFilter *stickerFilter;

@end

@implementation YKFaceBeautyFilter

- (id)init {
    if (!(self = [super init])) {
        return nil;
    }
   
    self.beautyFilter = [[YKBeautyPlusFilter alloc] init];
    [self addFilter:self.beautyFilter];
    
    self.faceMarkFilter = [[YKFaceMarkFilter alloc] init];
    [self addFilter:self.faceMarkFilter];
    
    self.slimFaceFilter = [[YKSlimFaceFilter alloc] init];
    [self addFilter:self.slimFaceFilter];
    
    self.stickerFilter = [[YKFaceStickerFilter alloc] init];
    [self addFilter:self.stickerFilter];
    
    __weak typeof(self) weakSelf = self;
    self.faceMarkFilter.faceCallBack = ^(const NSArray *faceInfoArray) {
        weakSelf.slimFaceFilter.faceInfoArray = [faceInfoArray copy];
        weakSelf.stickerFilter.faceInfoArray = [faceInfoArray copy];
    };
    
    [self.beautyFilter addTarget:self.faceMarkFilter];
    [self.faceMarkFilter addTarget:self.slimFaceFilter];
    [self.slimFaceFilter addTarget:self.stickerFilter];
    
    [self setInitialFilters:[NSArray arrayWithObject:self.beautyFilter]];
    [self setTerminalFilter:self.stickerFilter];
    
    return self;
}

- (void)setShowLandmark:(BOOL)showLandmark {
    _showLandmark = showLandmark;
    self.faceMarkFilter.showLandmarkPoint = showLandmark;
};

- (void)setBeauty:(BOOL)beauty {
    _beauty = beauty;
    self.beautyFilter.beauty = self.beauty;
}

- (void)setSlimFace:(BOOL)slimFace {
    _slimFace = slimFace;
    self.slimFaceFilter.slimFace = self.slimFace;
}

- (void)setLargeEyes:(BOOL)largeEyes {
    _largeEyes = largeEyes;
    self.slimFaceFilter.largeEyes = self.largeEyes;
}

- (void)setEnlargeEyesDelta:(CGFloat)enlargeEyesDelta {
    _enlargeEyesDelta = enlargeEyesDelta;
    self.slimFaceFilter.enlargeEyesDelta = enlargeEyesDelta;
}

- (void)setSlimFaceDelta:(CGFloat)slimFaceDelta {
    _slimFaceDelta = slimFaceDelta;
    self.slimFaceFilter.slimFaceDelta = slimFaceDelta;
}

- (void)setSticker:(YKFaceSticker *)sticker {
    _sticker = sticker;
    self.stickerFilter.sticker = sticker;
}

@end
