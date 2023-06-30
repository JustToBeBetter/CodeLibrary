//
//  YKFaceSticker.h
//  YKFaceSDK
//
//  Created by feng on 2016/12/5.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "YKFaceStickerItem.h"

@class YKFaceInfo;

typedef NS_ENUM(NSInteger, YKFaceStickerDownloadState) {
    YKFaceStickerDownloadStateDownloadNot = 0, //Not downloaded
    YKFaceStickerDownloadStateDownloadDone, //Downloaded
    YKFaceStickerDownloadStateDownloading, //downloading
};

typedef NS_ENUM(NSInteger, YKFaceStickerSourceType) {
    YKFaceStickerSourceTypeFromRemote = 0,      //0  Remote downloadURL
    YKFaceStickerSourceTypeFromLocal,       //1 your own downloadURL
};

/**
 * 一套贴纸
 */
@interface YKFaceSticker : NSObject

typedef void(^YKFaceStickerPlayOver)(void);

@property(nonatomic, copy) YKFaceStickerPlayOver stickerPlayOver;

/**
 * 包含的所有部件
 */
@property (nonatomic, strong) NSArray<YKFaceStickerItem *> *items;

/**
 * 贴纸的目录
 */
@property (nonatomic, copy) NSString *stickerDir;

/**
 * 贴纸的名称
 */
@property (nonatomic, copy) NSString *stickerName;

/**
 * 预览图文件名
 */
@property (nonatomic, copy) NSString *stickerIcon;

/**
 * 音效的文件名
 */
@property (nonatomic, copy) NSString *stickerSound;

/**
 * 是否下载
 */
@property (nonatomic, assign) BOOL isDownload;

/**
 * 当前循环次数
 */
@property(nonatomic, assign) NSUInteger playStickerCount;

/**
 * 下载状态
 */
@property(nonatomic, assign) YKFaceStickerDownloadState downloadState;

/**
 * 贴纸来源
 */
@property(nonatomic, assign) YKFaceStickerSourceType sourceType;

/**
 * 下载地址
 */
@property(nonatomic, strong) NSURL *downloadURL;

- (instancetype)initWithName:(NSString *)name
                   thumbName:(NSString *)thumb
                    download:(BOOL)download
                directoryURL:(NSURL *)dirurl;

+ (void)updateStickerAfterDownload:(YKFaceSticker *)sticker
                      directoryURL:(NSURL *)dirurl
                            sucess:(void (^)(YKFaceSticker *))sucessed
                              fail:(void (^)(YKFaceSticker *))failed;

- (void)drawItemsWithFace:(YKFaceInfo *)face
                faceIndex:(NSInteger)faceIndex
          framebufferSize:(CGSize)size
             timeInterval:(NSTimeInterval)interval
               usingBlock:(void (^)(GLfloat *, GLuint))block;

- (void)setPlayCount:(NSUInteger)count;

- (void)reset;

@end
