//
//  LJZPhotoMaker.h
//  CodeLibrary
//
//  Created by 李金柱 on 2019/2/16.
//  Copyright © 2019年 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJZPhotoMaker : NSObject

+ (UIImage *)makePhtoWithImages:(NSArray *)images;
+ (UIView *)makeImageViewWithImages:(NSArray *)images;
@end
