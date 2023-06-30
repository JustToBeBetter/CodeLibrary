//
//  YKFaceStickersDownloadManager.h
//  YKFaceSDK
//
//  Created by feng on 17/1/20.
//  Copyright © 2017年 feng. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YKFaceSticker;

@interface YKFaceStickersDownloadManager : NSObject

+ (instancetype)sharedInstance;

- (void)clearDownloadCache;

/**
 Download a single sticker
 
 @param sticker the sticker to download
 @param index the index of the sticker in the array
 @param animating the animation when downloading
 @param success download successed callback
 @param failed download failed callback
 */

- (void)downloadSticker:(YKFaceSticker *)sticker
                  index:(NSInteger)index
          withAnimation:(void (^)(NSInteger index))animating
              successed:(void (^)(YKFaceSticker *sticker, NSInteger index))success
                 failed:(void (^)(YKFaceSticker *sticker, NSInteger index))failed;

/**
 Download all unsaved stickers
 
 @param stickers the array of all stickers
 @param animating the animation when downloading
 @param success the sticker download successed
 @param failed the sticker download failed
 */

- (void)downloadStickers:(NSArray *)stickers
           withAnimation:(void (^)(NSInteger index))animating
               successed:(void (^)(YKFaceSticker *sticker, NSInteger index))success
                  failed:(void (^)(YKFaceSticker *sticker, NSInteger index))failed;

@end
