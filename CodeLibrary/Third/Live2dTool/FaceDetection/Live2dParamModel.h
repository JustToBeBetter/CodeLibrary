//
//  Live2dParamModel.h
//  MurderMystery
//
//  Created by 李金柱 on 2021/1/27.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Live2dParamModel : NSObject

/**头部转动*/
@property (nonatomic, copy) NSString * hX;
@property (nonatomic, copy) NSString * hY;
@property (nonatomic, copy) NSString * hZ;
/**眼睛*/
@property (nonatomic, copy) NSString * eL;
@property (nonatomic, copy) NSString * eR;
/**眉毛*/
@property (nonatomic, assign) BOOL bw;
@property (nonatomic, copy) NSString * bLy;
@property (nonatomic, copy) NSString * bRy;
/**瞳孔 眼珠x 眼珠y*/
@property (nonatomic, copy) NSString * eBx;
@property (nonatomic, copy) NSString * eBy;
/**嘴巴开闭*/
@property (nonatomic, copy) NSString * mY;
/**口变形*/
@property (nonatomic, copy) NSString * mf;
/**脸部识别丢失*/
@property (nonatomic, assign) BOOL fl;
/**唇同步*/
@property (nonatomic, copy) NSString *ls;
@end

NS_ASSUME_NONNULL_END
