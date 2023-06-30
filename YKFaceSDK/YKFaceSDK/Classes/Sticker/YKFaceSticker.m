//
//  YKFaceSticker.m
//  YKFaceSDK
//
//  Created by feng on 2016/12/5.
//  Copyright © 2016年 feng. All rights reserved.
//

#import "YKFaceSticker.h"
#import "YKFaceSDK.h"
#import "YKFacePoint.h"

#define StickerIconBaseURL @"https://stickers-thumb-cdn.kiwiar.com/"

@implementation YKFaceSticker

- (instancetype)initWithName:(NSString *)name
                   thumbName:(NSString *)thumb
                    download:(BOOL)download
                directoryURL:(NSURL *)dirurl {
    if (self = [super init]) {
        if (self.playStickerCount == 0) {
            self.playStickerCount = NSIntegerMax;
        }

        _stickerName = name;
        _stickerIcon = [NSString stringWithFormat:@"%@%@", StickerIconBaseURL, thumb];
        _isDownload = download;
        _downloadState = YKFaceStickerDownloadStateDownloadNot;
        _stickerDir = nil;
        _stickerSound = nil;
        _items = nil;
        //Unloaded items do not initialize items, stickerDir, stickerSound, and so on
        if (download == YES) {
            NSString *dir = dirurl.path;
            _stickerDir = dir;
            _downloadState = YKFaceStickerDownloadStateDownloadDone;
            NSString *configFile = [dir stringByAppendingPathComponent:@"config.json"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:configFile isDirectory:NULL]) {
                [YKFaceSticker resetSticker:self];
                return self;
            }

            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfFile:configFile];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if ([dict objectForKey:@"soundName"]) {
                _stickerSound = dict[@"soundName"];
            }
            if (error || !dict) {
                _isDownload = NO;
                return self;
            }

            NSArray *itemsDict = [dict objectForKey:@"itemList"];
            NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsDict.count];

            NSInteger itemsFrameNum = 0;
            YKFaceStickerItem *itemCopy;
            for (NSDictionary *itemDict in itemsDict) {
                YKFaceStickerItem *item = [[YKFaceStickerItem alloc] initWithJSONDictionary:itemDict];

                if (item.count >= itemsFrameNum) {
                    itemsFrameNum = item.count;
                    itemCopy = item;
                }
                item.itemDir = [_stickerDir stringByAppendingPathComponent:item.itemDir];
                item.loopCountdown = self.playStickerCount;
                NSArray *dirArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:item.itemDir error:NULL];
                NSInteger fileCount = dirArr.count;

                for (NSString *fileName in dirArr) {
                    if (![fileName hasSuffix:@".png"]) {
                        fileCount--;
                    }
                }

                //Check the sticker file for missing stickers
                if (fileCount != [[itemDict objectForKey:@"frameNum"] intValue]) {
                    [YKFaceSticker resetSticker:self];
//                    break;
                    return self;
                }

                [items addObject:item];
            }
            itemCopy.isLastItem = YES;

            _items = items;
        }
    }
    return self;
}

- (void)setSourceType:(YKFaceStickerSourceType)sourceType {
    _sourceType = sourceType;
    if (sourceType == YKFaceStickerSourceTypeFromRemote) {
        _downloadURL = nil;
    } else if (sourceType == YKFaceStickerSourceTypeFromLocal) {
        // you can set your own downURL here
        _downloadURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://127.0.0.1/sticker/%@.zip",
                _stickerName]];
    }
}

+ (void)updateStickerAfterDownload:(YKFaceSticker *)sticker directoryURL:(NSURL *)dirurl sucess:(void (^)
        (YKFaceSticker *))sucessed fail:(void (^)(YKFaceSticker *))failed {
    if (sticker.playStickerCount == 0) {
        sticker.playStickerCount = NSIntegerMax;
    }

    sticker.isDownload = YES;
    NSString *dir = dirurl.path;
    sticker.stickerDir = dir;
    NSString *configFile = [dir stringByAppendingPathComponent:@"config.json"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:configFile isDirectory:NULL]) {
        [self resetSticker:sticker];
        failed(sticker);
    }

    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:configFile];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ([dict objectForKey:@"soundName"]) {
        sticker.stickerSound = dict[@"soundName"];
    }
    if (error || !dict) {
        [self resetSticker:sticker];
        failed(sticker);
    }

    NSArray *itemsDict = [dict objectForKey:@"itemList"];
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:itemsDict.count];

    NSInteger itemsFrameNum = 0;
    YKFaceStickerItem *itemCopy;
    for (NSDictionary *itemDict in itemsDict) {
        YKFaceStickerItem *item = [[YKFaceStickerItem alloc] initWithJSONDictionary:itemDict];
        if (item.count >= itemsFrameNum) {
            itemsFrameNum = item.count;
            itemCopy = item;
        }
        item.itemDir = [sticker.stickerDir stringByAppendingPathComponent:item.itemDir];
        item.loopCountdown = sticker.playStickerCount;
        NSArray *dirArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:item.itemDir error:NULL];
        NSInteger fileCount = dirArr.count;

        for (NSString *fileName in dirArr) {
            if (![fileName hasSuffix:@".png"]) {
                fileCount--;
            }
        }

        //Check the sticker file for missing stickers
        if (fileCount != [[itemDict objectForKey:@"frameNum"] intValue]) {

            [self resetSticker:sticker];
            failed(sticker);

            break;
        }

        [items addObject:item];
    }
    itemCopy.isLastItem = YES;
    sticker.items = items;

    sucessed(sticker);
}

- (void)setPlayCount:(NSUInteger)count {
    self.playStickerCount = count;
    for (YKFaceStickerItem *item in _items) {
        item.loopCountdown = count;
        if (count == 0) {
            item.accumulator = 0;
            item.currentFrameIndex = 0;
        }
    }
}

+ (void)resetSticker:(YKFaceSticker *)sticker {
    [[NSFileManager defaultManager] removeItemAtPath:sticker.stickerDir error:NULL];
    sticker.stickerDir = nil;
    sticker.downloadState = YKFaceStickerDownloadStateDownloadNot;
    sticker.isDownload = NO;
    sticker.stickerSound = nil;
    sticker.items = nil;
}

- (void)dealloc {
    for (YKFaceStickerItem *item in _items) {
        [item deleteTextures];
    }
    _items = nil;
}

- (BOOL)isFaceActionTrigger:(long )faceAction
                triggerType:(YKFaceStickerItemTriggerType)triggerType {
//    if (triggerType == YKFaceStickerItemTriggerTypeBlink) {
//        return (faceAction & EYE_BLINK) != 0;
//    } else if (triggerType == YKFaceStickerItemTriggerTypeMouthOpen) {
//        return (faceAction & MOUTH_AH) != 0;
//    } else if (triggerType == YKFaceStickerItemTriggerTypeFrown) {
//        return (faceAction & BROW_JUMP) != 0;
//    } else if (triggerType == YKFaceStickerItemTriggerTypeHeadYaw) {
//        return (faceAction & HEAD_YAW) != 0;
//    } else if (triggerType == YKFaceStickerItemTriggerTypeHeadPitch) {
//        return (faceAction & HEAD_PITCH) != 0;
//    }
    return NO;
}

- (void)drawItemsWithFace:(YKFaceInfo *)faceInfo
                faceIndex:(NSInteger)faceIndex
          framebufferSize:(CGSize)size
             timeInterval:(NSTimeInterval)interval
               usingBlock:(void (^)(GLfloat *, GLuint))block {
    if (!faceInfo || faceInfo.landmark.count <= 0) {
        return;
    }
    // 顶点坐标
    static GLfloat vertices[8] = {0};

    // 计算眼间距，以此作为调整item大小的参考
    YKFacePoint *eyePoint = [YKFacePoint facePointForPosition:YKFacePositionEye];
    CGPoint eye_left = [self convertLandmarkPointByIndex:eyePoint.left faceInfo:faceInfo size:size];
    CGPoint eye_right = [self convertLandmarkPointByIndex:eyePoint.right faceInfo:faceInfo size:size];

    int eye_dist = distance(eye_left, eye_right);
    float signx = 1.0 * (eye_right.y - eye_left.y) / eye_dist;
    float cosignx = 1.0 * (eye_right.x - eye_left.x) / eye_dist;
    unsigned long faceAction = faceInfo.action;
    
    for (YKFaceStickerItem *item in self.items) {
        // 有触发条件的贴纸
        if (item.triggerType != YKFaceStickerItemTriggerTypeNormal && item.triggerType !=
                YKFaceStickerItemTriggerTypeFace) {
            // 未触发
            if (!item.triggered) {
                // 现在触发
                if ([self isFaceActionTrigger:faceAction triggerType:item.triggerType]) {
                    __weak YKFaceStickerItem *weakItem = item;
                    item.triggered = YES;
//                    NSLog(@"现在触发%ld", item.triggerType);
                    item.stickerItemPlayOver = ^(void) {
                        weakItem.triggered = NO;
                    };
                } else {
                    NSLog(@"跳过，未触发");
                    continue;
                }
            }
        }

        switch (item.type) {
            case YKFaceStickerItemTypeFace:
            {
                YKFacePoint *itemPos = [YKFacePoint facePointForPosition:item.position];
               
                CGPoint left_point = [self convertLandmarkPointByIndex:itemPos.left faceInfo:faceInfo size:size];
                CGPoint center_point = [self convertLandmarkPointByIndex:itemPos.center faceInfo:faceInfo size:size];
                CGPoint right_point = [self convertLandmarkPointByIndex:itemPos.right faceInfo:faceInfo size:size];
                
                CGFloat dist = distance(left_point, right_point);
                
                // 计算item的宽高及顶点坐标
                float itemWidth = dist + eye_dist * item.scaleWidthOffset;
                float itemHeight = itemWidth * item.height / item.width;
                
                CGFloat left = center_point.x - itemWidth / 2. + eye_dist * item.scaleXOffset;
                CGFloat right = center_point.x + itemWidth / 2. + eye_dist * item.scaleXOffset;
                CGFloat top = center_point.y + itemHeight / 2. + eye_dist * item.scaleYOffset;
                CGFloat bottom = center_point.y - itemHeight / 2. + eye_dist * item.scaleYOffset;
                
                // 旋转
                vertices[0] = ((left - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[1] = ((left - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[2] = ((right - center_point.x) * cosignx - (bottom - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[3] = ((right - center_point.x) * signx + (bottom - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[4] = ((left - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[5] = ((left - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
                vertices[6] = ((right - center_point.x) * cosignx - (top - center_point.y) * signx + center_point.x) / size.width * 2. - 1;
                vertices[7] = ((right - center_point.x) * signx + (top - center_point.y) * cosignx + center_point.y) / size.height * 2. - 1;
            }
                break;
                
            case YKFaceStickerItemTypeFullScreen:
            {
                // 多张人脸只画一次
                if (faceIndex > 0) {
                    continue;
                }
                
                CGFloat left, right, top, bottom;
                CGFloat itemWidth, itemHeight;

                itemWidth = size.width * item.scaleWidthOffset;
                itemHeight = ceil(itemWidth * (item.height / item.width));
                
                switch (item.alignPosition) {
                    case YKFaceStickerItemAlignPositionTop:
                    {
                        left = (size.width - itemWidth) / 2 + size.width * item.scaleXOffset;
                        right = left + itemWidth;
                        
                        bottom = size.width * item.scaleYOffset;
                        top = bottom + itemHeight;
                    }
                        break;
                        
                    case YKFaceStickerItemAlignPositionLeft:
                    {
                        left = size.width * item.scaleXOffset;
                        right = left + itemWidth;

                        top = (size.height - itemHeight) / 2 + size.height * item.scaleYOffset;
                        bottom = top + itemHeight;
                    }
                    case YKFaceStickerItemAlignPositionBottom: {
                        left = (size.width - itemWidth) / 2 + size.width * item.scaleXOffset;
                        right = left + itemWidth;

                        bottom = size.height + size.height * item.scaleYOffset;
                        top = bottom + itemHeight;
                    }
                    case YKFaceStickerItemAlignPositionRight:
                    {
                        right = size.width  - itemWidth + size.width * item.scaleXOffset;
                        left = right - itemWidth;

                        top = (size.height - itemHeight) / 2 + size.height * item.scaleYOffset;
                        bottom = top + itemHeight;
                    }
                    case YKFaceStickerItemAlignPositionCenter:
                    {
                        left = (size.width - itemWidth) / 2 + size.width * item.scaleXOffset;
                        right = left + itemWidth;

                        top = (size.height - itemHeight) / 2 + size.height * item.scaleYOffset;
                        bottom = top + itemHeight;
                    }
                        break;
                        
                    default:
                        break;
                }
                
                vertices[0] = left / size.width * 2 -1;
                vertices[1] = top / size.height * 2 -1;
                vertices[2] = right / size.width * 2 -1;
                vertices[3] = vertices[1];
                vertices[4] = vertices[0];
                vertices[5] = bottom / size.height * 2 -1;
                vertices[6] = vertices[2];
                vertices[7] = vertices[5];
            }
                break;
            case YKFaceStickerItemTypeEdge:
            {
                CGFloat left, right, top, bottom;
                CGFloat itemWidth, itemHeight;

                itemWidth = size.width * item.scaleWidthOffset;
                itemHeight = ceil(itemWidth * (item.height / item.width));

                left = (size.width - itemWidth) / 2 + size.width * item.scaleXOffset;
                right = left + itemWidth;

                top = (size.height - itemHeight) / 2 + size.height * item.scaleYOffset;
                bottom = top + itemHeight;

                vertices[0] = left / size.width * 2 -1;
                vertices[1] = top / size.height * 2 -1;
                vertices[2] = right / size.width * 2 -1;
                vertices[3] = vertices[1];
                vertices[4] = vertices[0];
                vertices[5] = bottom / size.height * 2 -1;
                vertices[6] = vertices[2];
                vertices[7] = vertices[5];
            }
            default:
                break;
        }
        
        GLuint texture = [item nextTextureForInterval:interval];
        !block ?: block(vertices, texture);
    }
}

- (void)reset {
    for (YKFaceStickerItem *item in self.items) {
        [item deleteTextures];
    }
}

- (CGPoint)convertLandmarkPointByIndex:(NSInteger)index faceInfo:(YKFaceInfo *)faceInfo size:(CGSize)size {
    CGPoint pt = [[faceInfo.normalizationLandmarks objectAtIndex:index] CGPointValue];
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        return CGPointMake(pt.x * size.width, pt.y * size.height);
    } else {
        return CGPointZero;
    }
}

static CGFloat distance(CGPoint first, CGPoint second) {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}

@end
