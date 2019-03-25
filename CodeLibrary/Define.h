//
//  Define.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#ifndef Define_h
#define Define_h

#define WeakObj(o) @autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) @autoreleasepool{} __strong typeof(o) o = o##Weak;

#define kScreenSize  [UIScreen mainScreen].bounds.size
#define kScreenWidth  kScreenSize.width
#define kScreenHeight kScreenSize.height

#define SCREEN_WIDTH		([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT		([UIScreen mainScreen].bounds.size.height)

#define kProportion [[UIScreen mainScreen] bounds].size.width /375//缩放因子
#define kStatusHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kFont(a) [UIFont systemFontOfSize:a];
#define kMediumFont(a) [UIFont fontWithName:@"PingFangSC-Medium" size:a]
#define kRegularFont(a) [UIFont fontWithName:@"PingFangSC-Regular" size:a]
#define kSemiboldFont(a) [UIFont fontWithName:@"PingFangSC-Semibold" size:a]
#define kBoldFont(a) [UIFont fontWithName:@"Helvetica-Bold" size:a]


#import "LJZTool.h"
#import "UIView+LJZ.h"
#import <SDWebImage/UIImage+GIF.h>
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import <Masonry.h>

#endif /* Define_h */
