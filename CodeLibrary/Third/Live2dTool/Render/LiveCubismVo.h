//
//  LiveCubismVo.h


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveCubismVo : NSObject

/** 头部转动 x */
@property(nonatomic, readwrite) float hX;

/** 头部转动 Y */
@property(nonatomic, readwrite) float hY;

/** 头部转动 Z */
@property(nonatomic, readwrite) float hZ;

/** 左眼睁开系数 */
@property(nonatomic, readwrite) float eL;

/** 右眼睁开系数 */
@property(nonatomic, readwrite) float eR;

/** 左边眉毛高度 */
@property(nonatomic, readwrite) float bLy;

/** 右边眉毛高度 */
@property(nonatomic, readwrite) float bRy;

/** 瞳孔 x */
@property(nonatomic, readwrite) float eBx;

/** 瞳孔 y */
@property(nonatomic, readwrite) float eBy;

/** 嘴巴张开系数 */
@property(nonatomic, readwrite) float mY;

/** 人脸是否丢失 */
@property(nonatomic, readwrite) BOOL fl;

/** 口变形 */
@property(nonatomic, readwrite) float mf;

/** 唇同步 */
@property(nonatomic, readwrite) float ls;

@end

NS_ASSUME_NONNULL_END
