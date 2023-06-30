//
//  SKStickerFilter.h
//  YKFaceSDK
//
//  Created by feng on 2016/12/4.
//  Copyright © 2016年 feng. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "YKFaceSDK.h"

@class YKFaceSticker;

@interface YKFaceStickerFilter : GPUImageFilter

/**
 * 需要绘制的贴纸
 */
@property (nonatomic, strong) YKFaceSticker *sticker;

/**
 * 关键点，元素需为CGPoint数组
 */
@property (nonatomic, strong) NSArray<YKFaceInfo *> *faceInfoArray;

@end
