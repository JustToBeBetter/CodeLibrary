//
//  LJZDeveiceInfo.h
//  CodeLibrary
//
//  Created by 李金柱 on 2021/6/3.
//  Copyright © 2021 李金柱. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LJZDeveiceInfo : NSObject

@property (class, nonatomic, readonly) BOOL isLandScape;
@property (class, nonatomic, readonly) BOOL isIPad;
@property (class, nonatomic, readonly) BOOL isIPod;
@property (class, nonatomic, readonly) BOOL isIPhone;
@property (class, nonatomic, readonly) BOOL isSimulator;
@property (class, nonatomic, readonly) BOOL isMac;

// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
@property (class, nonatomic, readonly) BOOL isNotchedScreen;

// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）
@property (class, nonatomic, readonly) BOOL isRegularScreen;

/// iPhone 12 Pro Max
@property(class, nonatomic, readonly) BOOL is67InchScreen;

/// iPhone XS Max / 11 Pro Max
@property(class, nonatomic, readonly) BOOL is65InchScreen;

/// iPhone 12 / 12 Pro
@property(class, nonatomic, readonly) BOOL is61InchScreenAndiPhone12;

/// iPhone XR / 11
@property(class, nonatomic, readonly) BOOL is61InchScreen;

/// iPhone X / XS / 11Pro
@property(class, nonatomic, readonly) BOOL is58InchScreen;

/// iPhone 6，6s，7，8 Plus
@property(class, nonatomic, readonly) BOOL is55InchScreen;

/// iPhone 12 mini
@property(class, nonatomic, readonly) BOOL is54InchScreen;

/// iPhone 6，6s，7，8，SE2
@property(class, nonatomic, readonly) BOOL is47InchScreen;

/// iPhone 5，5s，5c，SE
@property(class, nonatomic, readonly) BOOL is40InchScreen;

/// iPhone 4
@property(class, nonatomic, readonly) BOOL is35InchScreen;

@property(class, nonatomic, readonly) CGSize screenSizeFor67Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor65Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor61InchAndiPhone12;
@property(class, nonatomic, readonly) CGSize screenSizeFor61Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor58Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor55Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor54Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor47Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor40Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor35Inch;

// 导航栏高度，包括竖屏，横屏，放大模式
// 机型\高度         尺寸        竖屏       横屏      放大模式
// 5,5s,5c,SE       4.0        44        32         不支持
// 6,6s,7,8,SE2     4.7        44        32          32
// 6,6s,7,8plus     5.5        44        44          32
// X,XS,11Pro       5.8        44        32          32
// XR,11            6.1        44        44          32
// XS MAX,11Pro Max 6.5        44        44          32
// 12mini           5.4        44        32          32
// 12,12Pro         6.1        44        32          32
// 12Pro Max        6.7        44        44          32
// iPad iOS12之前是44，之后是50
@property(class, nonatomic, readonly) CGFloat      navBarHeight;
@property(class, nonatomic, readonly) CGFloat      tabBarHeight;
@property(class, nonatomic, readonly) CGFloat      statusBarHeight;
@property(class, nonatomic, readonly) CGFloat      safe_top;//顶部安全区域高度
@property(class, nonatomic, readonly) CGFloat      safe_bottom;//底部安全区域高度
@property(class, nonatomic, readonly) UIEdgeInsets safeAreaInsets;
@property(class, nonatomic, readonly) CGRect       statusBarFrame;
@property(class, nonatomic, readonly) UIWindow     *keyWindow;
@property(class, nonatomic, readonly) NSString     *phoneType;
@property(class, nonatomic, readonly) CGFloat      systemVersion;

@end

NS_ASSUME_NONNULL_END
