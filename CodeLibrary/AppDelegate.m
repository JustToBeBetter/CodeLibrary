//
//  AppDelegate.m
//  CodeLibrary
//
//  Created by 李金柱 on 2017/4/12.
//  Copyright © 2017年 李金柱. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self configLogInfo];
    DDLogInfo(@"1");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogInfo(@"2");
    });
    
    DDLogDebug(@"3");

    return YES;
}

- (void)configLogInfo{
    // 日志
    [DDOSLogger sharedInstance].logFormatter = [[LJZLogFormatter alloc] init];
    // 添加DDOSLogger，日志被打印到Xcode控制台
    [DDLog addLogger:[DDOSLogger sharedInstance]];
    // 添加DDASLLogger，日志将被打印到Console.app 同时也会在xcode打印
//    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    //一周内日志
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;//24小时创建一个文件
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;//7个日志文件
    [fileLogger setLogFormatter:[[LJZLogFormatter alloc] init]];
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}
void UncaughtExceptionHandler(NSException *exception) {
  NSArray *arr = [exception callStackSymbols];//当前调用栈信息
  NSString *reason = [exception reason];//崩溃的原因
  NSString *name = [exception name];//异常类型
  DDLogError(@"exception type : %@ \n crash reason : %@ \n call stack info : %@", name, reason, arr);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
