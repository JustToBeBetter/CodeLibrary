//
//  MMPlayerManager.h
//  Created by 李金柱 on 2021/3/11.
//  Copyright © 2021 YoKa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPlayerManager : NSObject

/**开关麦回调*/
@property (nonatomic, copy) void(^audioPlayerDidFinishPlayingCallBack)(AVAudioPlayer *player, BOOL successfully);

+ (instancetype)shareManager;

- (void)playAudioWithData:(NSData*)data
             imgAnimation:(UIImageView *)imgAnimation
               completion:(void(^)(NSError * _Nullable error))completon;

- (void)playAudioWithAudioUrl:(NSString *)audioUrl
                 imgAnimation:(UIImageView *)imgAnimation
                   completion:(void(^)(NSError * _Nullable error))completon;

- (void)playAudioWithData:(NSData*)data
               completion:(void(^)(NSError * _Nullable error))completon;

- (void)playAudioWithAudioUrl:(NSString *)audioUrl
                   completion:(void(^)(NSError * _Nullable error))completon;

- (void)play;

- (void)pause;

- (void)stopPlay;

/**默认最长 15s*/
- (void)startRecordWithFilePath:(NSString *)filePath
                  completeBlock:(void (^)(CGFloat time))complete;

- (void)startRecordWithFilePath:(NSString *)filePath
                  maxDuration:(CGFloat)maxDuration
                  completeBlock:(void (^)(CGFloat time))complete;

- (void)stopRecording;

- (void)cancelRecording;

/** pcm 转 mp3*/
- (void)encodePCM2MP3:(NSString *)pcmFilePath outPutFile:(void (^)(NSString *mp3FilePath, NSData *outData))callBack;

@end

NS_ASSUME_NONNULL_END
