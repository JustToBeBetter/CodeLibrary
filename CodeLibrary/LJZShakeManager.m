//
//  LJZShakeManager.m
//  CodeLibrary
//
//  Created by 李金柱 on 2018/12/8.
//  Copyright © 2018年 李金柱. All rights reserved.
//

#import "LJZShakeManager.h"

#import<AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
SystemSoundID sound;


@implementation LJZShakeManager

//震动回调 保持一直震动
void systemVibrateCallback (SystemSoundID soundID, void* clientData) {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
//音效回调 一直播放
void systemAudioCallback (SystemSoundID soundID, void* clientData) {
    AudioServicesPlaySystemSound(sound);
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static LJZShakeManager *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[LJZShakeManager alloc] init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(applicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
    });
    return _instance;
}
+ (void)applicationDidFinishLaunching{
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
}
+ (void)applicationDidEnterBackground{
    UIApplication*   app = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}
- (void)beginShake{
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemVibrateCallback, NULL);
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}
- (void)stopShake{
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}
- (void)stopPlaySound{
    AudioServicesRemoveSystemSoundCompletion(sound);
}
- (void)playSound{
    //自定义系统音效
    NSString *path = [[NSBundle mainBundle] pathForResource:@"voice" ofType:@"m4a"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &sound);
    AudioServicesAddSystemSoundCompletion(sound, NULL, NULL, systemAudioCallback, NULL);
    AudioServicesPlaySystemSound(sound);
}


@end
