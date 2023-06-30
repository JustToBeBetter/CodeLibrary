//
//  YKFaceSticker.h
//  YKFaceSDK
//
//  Created by feng on 2016/10/14.
//  Copyright © 2016年 feng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YKFaceSDK.h"
#import "YKFacePoint.h"

typedef enum {
    YKFaceStickerItemTypeFullScreen,  // full-screen display
    YKFaceStickerItemTypeFace,        // 脸部
    YKFaceStickerItemTypeEdge,        // 边框
} YKFaceStickerItemType;

typedef enum {
    YKFaceStickerItemAlignPositionTop,
    YKFaceStickerItemAlignPositionLeft,
    YKFaceStickerItemAlignPositionBottom,
    YKFaceStickerItemAlignPositionRight,
    YKFaceStickerItemAlignPositionCenter
    // ...
} YKFaceStickerItemAlignPosition;

typedef enum {
    YKFaceStickerItemTriggerTypeNormal,     // 始终
    YKFaceStickerItemTriggerTypeFace,       // 有人脸
    YKFaceStickerItemTriggerTypeMouthOpen,  // 张嘴
    YKFaceStickerItemTriggerTypeBlink,      // 眨眼
    YKFaceStickerItemTriggerTypeFrown,      // 皱眉
    YKFaceStickerItemTriggerTypeHeadYaw,    // 摇头
    YKFaceStickerItemTriggerTypeHeadPitch,  // 点头
} YKFaceStickerItemTriggerType;


/**
 * 一套贴纸中，某一部件（如鼻子）的所有信息。
 */
@interface YKFaceStickerItem : NSObject

typedef void(^YKFaceStickerItemPlayOver)(void);

/**
 * 播放完成回调
 */
@property(nonatomic, copy) YKFaceStickerItemPlayOver stickerItemPlayOver;

/**
 * 显示的位置类型
 */
@property (nonatomic, assign) YKFaceStickerItemType type;

/**
 * 触发条件，默认0，始终显示
 */
@property (nonatomic, assign) YKFaceStickerItemTriggerType triggerType;

/**
 * 资源的目录（包含一组图片序列帧）
 */
@property(nonatomic, copy) NSString *itemDir;

/**
 * 帧数（一组序列帧组成一个动画效果）
 */
@property (nonatomic, assign) NSUInteger count;

/**
 * 每帧的持续时间，秒
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * 图片的宽
 */
@property (nonatomic, assign) float width;

/**
 * 图片的高
 */
@property (nonatomic, assign) float height;

/**
 * 目标位置
 */
@property(nonatomic, assign) YKFacePosition position;

/**
 * 边缘item参数
 * 边缘位置（top、bottom、left、right）
 */
@property (nonatomic) YKFaceStickerItemAlignPosition alignPosition;

/**
 * 宽度缩放系数（对于脸部的item，以眼间距为参考；对于边缘的item则以屏幕的宽高作为参考，下同）
 */
@property (nonatomic) float scaleWidthOffset;

/**
 * 高度缩放系数
 */
@property (nonatomic) float scaleHeightOffset;

/**
 * 水平方向偏移系数
 */
@property (nonatomic) float scaleXOffset;

/**
 * 垂直方向偏移系数
 */
@property (nonatomic) float scaleYOffset;


/**
 * 已触发
 */
@property (nonatomic) BOOL triggered;

/**
 * 是否是最后一个
 */
@property (nonatomic, assign) BOOL isLastItem;

/**
 * 累计数量
 */
@property (nonatomic, assign) NSTimeInterval accumulator;

/**
 * 当前帧的索引
 */
@property (nonatomic) NSUInteger currentFrameIndex;

/**
 * 剩余循环次数
 */
@property (nonatomic) NSUInteger loopCountdown;

/**
 * 初始化
 * @param dict 包含item数据的字典
 * @return item实例
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;

/**
 * 根据时间间隔及当前帧的位置，获取下一帧图片，以此适应不同帧率的视频流，保证动画的效果。
 * @param interval 如视频流每帧的间隔
 * @return 此图片可以加到当前的视频帧中
 */
- (UIImage *)nextImageForInterval:(NSTimeInterval)interval;

/**
 * 根据时间间隔及当前帧的位置，获取下一帧纹理，以此适应不同帧率的视频流，保证动画的效果。
 * @return 纹理
 */
- (GLuint)nextTextureForInterval:(NSTimeInterval)interval;

/**
 * 删除纹理信息
 */
- (void)deleteTextures;

@end
