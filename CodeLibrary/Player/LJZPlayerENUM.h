//
//  LJZPlayerENUM.h
//
//  Created by maopao on 2019/3/21.
//  Copyright © 2019 李金柱. All rights reserved.
//

#ifndef LJZPlayerENUM_h
#define LJZPlayerENUM_h

#define    WeakSelf(type)            __weak typeof(type) weak##type = type;

typedef NS_ENUM(NSInteger, LJZPlayerStatus) {
    //未知状态，只会作为 init 后的初始状态，开始播放之后任何情况下都不会再回到此状态。
    LJZPlayerStatusUnKnown = 0,
    //缓冲数据不为空
    LJZPlayerStatusEndCaching = 1,
    //播放组件准备完成，准备开始播放，在调用 -play 方法时出现。
    LJZPlayerStatusReady = 2,
    //缓冲数据为空状态。
    LJZPlayerStatusCaching = 3,
    //正在播放状态。
    LJZPlayerStatusPlaying = 4,
    //暂停状态
    LJZPlayerStatusPaused = 5,
    //停止播放状态
    LJZPlayerStatusStop = 6,
    //播放结束状态(播放状态)
    LJZPlayerStatusEnd = 7,
    //错误状态，播放出现错误时会出现此状态。
    LJZPlayerStatusError = 8,
};
typedef NS_ENUM(NSInteger,LJZPlayerViewStatus){
    LJZPlayerViewStatusFailed,//加载失败
    LJZPlayerViewStatusCannotPlayerNotInWiFi,//提示不在Wifi环境情况下，不能播放
    LJZPlayerViewStatusPrePare,//即将播放
    LJZPlayerViewStatusPrePareLastTime,//上次播放时间准备继续播放
    LJZPlayerViewStatusPlayingInWiFi,//在WiFi中播放
    LJZPlayerViewStatusPlayingInWWAN,//在蜂窝网络中播放
    LJZPlayerViewStatusCaching,// 播放时缓冲中
    LJZPlayerViewStatusEndCaching,// 停止缓冲
    LJZPlayerViewStatusPaused,//播放器暂停
    LJZPlayerViewStatusPlayEnd,//播放结束
    LJZPlayerViewStatusChangingBitRate,//切换码流中...
};



#endif /* LJZPlayerENUM_h */
