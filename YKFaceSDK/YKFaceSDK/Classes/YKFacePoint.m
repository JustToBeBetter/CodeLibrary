//
//  YKFacePoint.m
//  YKFaceSDK
//
//  Created by feng on 2020/3/10.
//

#import "YKFacePoint.h"

@interface YKFacePoint()

@end

@implementation YKFacePoint

+ (instancetype)facePointForPosition:(YKFacePosition)position {
    YKFacePoint *point = [YKFacePoint new];
    if (position == YKFacePositionHair) {
        point.left = 76;
        point.center = 32;
        point.right = 116;
    } else if (position == YKFacePositionEye) {
        point.left = 16;
        point.center = 36;
        point.right = 24;
    } else if (position == YKFacePositionLeftEye) {
        point.top = 22;
        point.left = 16;
        point.center = 269;
        point.right = 20;
        point.bottom = 18;
    } else if (position == YKFacePositionRightEye) {
        point.top = 30;
        point.left = 28;
        point.center = 270;
        point.right = 24;
        point.bottom = 26;
    } else if (position == YKFacePositionLeftEyeBall) {
        point.left = 271;
        point.center = 269;
        point.right = 272;
    } else if (position == YKFacePositionRightEyeBall) {
        point.left = 274;
        point.center = 270;
        point.right = 273;
    } else if (position == YKFacePositionNose) {
        point.left = 40;
        point.center = 32;
        point.right = 46;
    } else if (position == YKFacePositionNostril) {
        point.left = 42;
        point.center = 43;
        point.right = 44;
    } else if (position == YKFacePositionMouth) {
        point.top = 73;
        point.left = 54;
        point.center = 58;
        point.right = 60;
        point.bottom = 68;
    } else if (position == YKFacePositionEyebrow) {
        point.left = 117;
        point.center = 32;
        point.right = 133;
    } else if (position == YKFacePositionLeftEyebrow) {
        point.left = 117;
        point.center = 122;
        point.right = 125;
    } else if (position == YKFacePositionRightEyebrow) {
        point.left = 141;
        point.center = 138;
        point.right = 133;
    }
    return point;
}

@end
