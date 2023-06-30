//
//  Define.h
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#ifndef Define_h
#define Define_h

#import "LJZTool.h"
#import "UIView+LJZ.h"
#import "NSFileManager+path.h"
#import "NSDictionary+json.h"
#import "NSMutableArray+safe.h"
#import "NSArray+safe.h"
#import "NSString+Tools.h"
//Third
#import <SDWebImage/UIImage+GIF.h>
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import <Masonry.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <SDWebImageFLPlugin/SDWebImageFLPlugin.h>
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <AFNetworking/AFNetworking.h>
//#import <SSZipArchive/SSZipArchive.h>
#import "HTTPServer.h"
#import <MJExtension/MJExtension.h>
//tools
#import "LJZLogFormatter.h"
#import "MMAuthorizationHelper.h"

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
// 颜色 字体
#define HEXRGBA(RGBValue,a) [UIColor colorWithRed:((float)((RGBValue & 0xFF0000) >> 16))/255.0 green:((float)((RGBValue & 0x00FF00) >> 8))/255.0 blue:((float)(RGBValue & 0x0000FF))/255.0 alpha:a]
#define HEXRGB(RGBValue)  HEXRGBA(RGBValue,1.0f)

//当前系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
//版本判断语句,是否是version以后的
#define IOS(version) (([[[UIDevice currentDevice] systemVersion] intValue] >= version)?1:0)

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#endif


#endif /* Define_h */
