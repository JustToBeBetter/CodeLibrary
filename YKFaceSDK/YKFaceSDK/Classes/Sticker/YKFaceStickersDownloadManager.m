//
//  YKFaceStickersDownloadManager.m
//  YKFaceSDK
//
//  Created by feng on 17/1/20.
//  Copyright © 2017年 feng. All rights reserved.
//

#import "YKFaceSticker.h"
#import "SSZipArchive.h"
#import "YKFaceStickersManager.h"
#import "YKFaceStickersDownloadManager.h"

#define StickerDownloadBaseURL @"https://stickers-cdn.kiwiar.com"

@interface YKFaceStickersDownloader : NSObject <SSZipArchiveDelegate, NSURLSessionDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, copy) void (^successedBlock)(YKFaceSticker *, NSInteger, NSString *, YKFaceStickersDownloader *);

@property (nonatomic, copy) void (^failedBlock)(YKFaceSticker *, NSInteger, YKFaceStickersDownloader *);

@property (nonatomic, strong) YKFaceSticker *sticker;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithSticker:(YKFaceSticker *)sticker url:(NSURL *)url index:(NSInteger)index;

- (void)downloadSuccessed:(void (^)(YKFaceSticker *sticker, NSInteger index, NSString *downloadPath, YKFaceStickersDownloader *downloader))success
                   failed:(void (^)(YKFaceSticker *sticker, NSInteger index, YKFaceStickersDownloader *downloader))failed;

@end

@implementation YKFaceStickersDownloader

- (instancetype)initWithSticker:(YKFaceSticker *)sticker url:(NSURL *)url index:(NSInteger)index {
    if (self = [super init]) {

        self.sticker = sticker;
        self.index = index;
        self.url = url;
    }

    return self;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session =
                [NSURLSession sessionWithConfiguration:config delegate:self
                                         delegateQueue:[[NSOperationQueue alloc] init]];
    }
    return _session;
}

- (void)downloadSuccessed:(void (^)(YKFaceSticker *sticker, NSInteger index, NSString *downloadPath, YKFaceStickersDownloader *downloader))success
                   failed:(void (^)(YKFaceSticker *sticker, NSInteger index, YKFaceStickersDownloader *downloader))
                           failed {
    self.task = [self.session downloadTaskWithURL:self.url
                                completionHandler:^(NSURL *_Nullable location, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                    if (error) {
                                        failed(self.sticker, self.index, self);
                                    } else {
                                        self.successedBlock = success;
                                        self.failedBlock = failed;

                                        [SSZipArchive unzipFileAtPath:location.path
                                                        toDestination:[[YKFaceStickersManager sharedManager]
                                                                getStickerPath]
                                                             delegate:self];
                                    }
                                }];

    [self.task resume];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *_Nullable))completionHandler {
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;

    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];

        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

//#pragma mark - Unzip complete callback
//
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path
                                zipInfo:(unz_global_info)zipInfo
                           unzippedPath:(NSString *)unzippedPath {
    // update sticker's download config
    [[YKFaceStickersManager sharedManager] updateConfigJSON];

    NSString *dir =
            [NSString stringWithFormat:@"%@/%@/", [[YKFaceStickersManager sharedManager] getStickerPath],
                                       self.sticker.stickerName];
    NSURL *url = [NSURL fileURLWithPath:dir];

    [YKFaceSticker updateStickerAfterDownload:self.sticker directoryURL:url sucess:^(YKFaceSticker *sucessSticker) {
        self.successedBlock(sucessSticker, self.index, @"", self);
    } fail:^(YKFaceSticker *failSticker) {
        self.failedBlock(failSticker, self.index, self);
    }];
}


@end

@interface YKFaceStickersDownloadManager()
/**
 *   下载缓冲池
 */
@property (nonatomic, strong) NSMutableDictionary *downloadCache;

@end

@implementation YKFaceStickersDownloadManager

+ (instancetype)sharedInstance {
    static id _sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [YKFaceStickersDownloadManager new];
    });

    return _sharedManager;
}

- (NSMutableDictionary *)downloadCache {
    if (_downloadCache == nil) {
        _downloadCache = [[NSMutableDictionary alloc] init];
    }
    return _downloadCache;
}

- (void)downloadSticker:(YKFaceSticker *)sticker
                  index:(NSInteger)index
          withAnimation:(void (^)(NSInteger index))animating
              successed:(void (^)(YKFaceSticker *sticker, NSInteger index))success
                 failed:(void (^)(YKFaceSticker *sticker, NSInteger index))failed {
    NSString *zipName = [NSString stringWithFormat:@"%@.zip", sticker.stickerName];

    NSURL *downloadUrl = sticker.downloadURL;

    if (sticker.sourceType == YKFaceStickerSourceTypeFromRemote) {

        downloadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", StickerDownloadBaseURL, zipName]];
    }

    // 判断是否存在对应的下载操作
    if (self.downloadCache[downloadUrl] != nil) {
        return;
    }

    animating(index);

    YKFaceStickersDownloader *downloader = [[YKFaceStickersDownloader alloc] initWithSticker:sticker url:downloadUrl
            index:index];

    [self.downloadCache setObject:downloader forKey:downloadUrl];

    [downloader downloadSuccessed:^(YKFaceSticker *sticker, NSInteger index, NSString *downloadPath,
            YKFaceStickersDownloader *downloader) {
        [self.downloadCache removeObjectForKey:downloadUrl];
        downloader = nil;
        if (success) {
            success(sticker, index);
        }
    }  failed:^(YKFaceSticker *sticker, NSInteger index, YKFaceStickersDownloader *downloader) {
        [self.downloadCache removeObjectForKey:downloadUrl];
        downloader = nil;
        if (failed) {

            failed(sticker, index);
        }
    }];
}

- (void)downloadStickers:(NSArray *)stickers
           withAnimation:(void (^)(NSInteger index))animating
               successed:(void (^)(YKFaceSticker *sticker, NSInteger index))success
                  failed:(void (^)(YKFaceSticker *sticker, NSInteger index))failed {

    for (YKFaceSticker *sticker in stickers) {
        if (sticker.isDownload == NO && sticker.downloadState == YKFaceStickerDownloadStateDownloadNot) {
            sticker.downloadState = YKFaceStickerDownloadStateDownloading;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self downloadSticker:sticker index:[stickers indexOfObject:sticker] withAnimation:^(NSInteger index) {
                    animating([stickers indexOfObject:sticker]);
                } successed:^(YKFaceSticker *sticker, NSInteger index) {
                    success(sticker, index);
                } failed:^(YKFaceSticker *sticker, NSInteger index) {
                    failed(sticker, index);
                }];
            });
        }
    }
}

- (void)clearDownloadCache {
    if (self.downloadCache.count > 0) {
        [self.downloadCache enumerateKeysAndObjectsUsingBlock:^(NSURL *downloadURL, YKFaceStickersDownloader *downloader, BOOL *_Nonnull stop) {
            if (downloader.task.state == 0) {
                [downloader.task cancel];
                [self.downloadCache removeObjectForKey:downloadURL];
                downloader = nil;
            }
        }];
    }
}


@end
