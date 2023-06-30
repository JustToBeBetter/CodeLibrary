//
//  YKFacePoint.h
//  YKFaceSDK
//
//  Created by feng on 2020/3/10.
//

#import <Foundation/Foundation.h>

typedef enum {
    YKFacePositionHair = 1,
    YKFacePositionEye = 2,
    YKFacePositionEar,
    YKFacePositionNose,
    YKFacePositionNostril,
    YKFacePositionUperMouth,
    YKFacePositionMouth,
    YKFacePositionLip,
    YKFacePositionChin,
    YKFacePositionEyebrow,
    YKFacePositionCheek,
    YKFacePositionNeck,
    YKFacePositionFace,
    YKFacePositionLeftEyebrow,
    YKFacePositionRightEyebrow,
    YKFacePositionLeftEye,   // 左眼
    YKFacePositionRightEye,  // 右眼
    YKFacePositionLeftEyeBall,   // 左眼球
    YKFacePositionRightEyeBall,  // 右眼球
} YKFacePosition;

/**
 * 返回某位置对应的点
 */
@interface YKFacePoint : NSObject

@property (nonatomic, assign) int top;   //左侧点索引
@property (nonatomic, assign) int left;   //左侧点索引
@property (nonatomic, assign) int center; //中间点索引
@property (nonatomic, assign) int right;  //右侧点索引
@property (nonatomic, assign) int bottom;  //右侧点索引

@property (nonatomic, strong) NSArray *points;  // 轮廓点

+ (instancetype)facePointForPosition:(YKFacePosition)position;

@end
