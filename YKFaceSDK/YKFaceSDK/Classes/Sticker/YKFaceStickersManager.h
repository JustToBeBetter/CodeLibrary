//
//  SKStickerManager.h
//  YKFaceSDK
//
//  Created by feng on 2016/10/13.
//  Copyright © 2016年 feng. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "YKFaceStickerItem.h"
#import "YKFaceSticker.h"

/**
 * 贴纸管理，加载等
 */
@interface YKFaceStickersManager : NSObject

/**
 * 单例
 */
+ (instancetype)sharedManager;

/*
 * 是否加载远程贴纸
 */
@property(nonatomic, assign) BOOL isLoadStickersFromServer;

/**
 * 异步方式从文件读取所有贴纸的信息
 * @param completion 读取完成后的回调
 */
- (void)loadStickersWithCompletion:(void (^)(NSMutableArray<YKFaceSticker *> *stickers))completion;

/*
 * 获取帖子路径
 */
- (NSString *)getStickerPath;

/**
 * 更新贴纸配置
 */
- (void)updateConfigJSON;

/**
 * Update the Json file and get new Json
 */
- (NSMutableDictionary *)updateConfigJSONForDict;

/**
 * Update the json file of local stickers from the server
 * completion:After the completion of the block of callback  {【isSuccess：Whether the update is successful】，【dic：The
 * updated new json】}
 * serverJson:The new stickers array from the server
 */
- (void)updateStickersJSONWithCompletion:(void (^)(BOOL isSuccess, NSMutableDictionary *dict))completion serverJson:
        (NSArray *)serverJson;


@end


