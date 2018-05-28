//
//  GetNetWorkSpeed.h
//  Test
//
//  Created by lijz on 2018/5/15.
//  Copyright © 2018年 Mrli. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const DownloadNetworkSpeedNotificationKey;
// 2MB/s
extern NSString *const UploadNetworkSpeedNotificationKey;

@interface GetNetWorkSpeed : NSObject

@property (nonatomic, copy, readonly) NSString*downloadNetworkSpeed;
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;
+ (instancetype)shareNetworkSpeed;
- (void)start;
- (void)stop;


@end
